//
//  RestaurantDataProvider.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDataProvider.h"
#import "Restaurant.h"
#import "Reachability.h"
#import "GAI.h"

@interface RestaurantDataProvider ()
- (void)gotRestaurants:(ASIHTTPRequest *)request;
- (void)failedToGetRestaurants:(ASIHTTPRequest *)request;
@end

@implementation RestaurantDataProvider

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
        reachabilityCheckFailed = NO;
    }
    return self;
}

- (void)dealloc
{
    for (NSOperation *operation in queue.operations) {
        if ([operation isKindOfClass:ASIHTTPRequest.class]) {
            [(ASIHTTPRequest *) operation setDelegate:nil];
            NSLog(@"HO HUMM did reset delegate!");
        }
    }
}

- (void)startLoadingRestaurantsWithCenter:(CLLocationCoordinate2D)center distanceInKilometers:(NSInteger)distance
{
    if ([self reachabilityCheckFails]) { return; }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:kURLForRestaurantsWithCenterAndDistanceKm, center.latitude, center.longitude, (long) distance]]];
    request.timeOutSeconds = 30;
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (void)startLoadingFavoriteRestaurantsWithLocation:(CLLocation *)location
{
    if ([self reachabilityCheckFails]) { return; }
    
    NSString *favoriteString = [[NSString alloc] init];
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteRestaurants"];
    
    if (favorites.count == 0) {
        [delegate gotRestaurants:nil];
        return;
    }
    
    for (NSString *favoriteId in favorites) {
        favoriteString = [favoriteString stringByAppendingFormat:@",%@", favoriteId];
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:kURLForRestaurantsByIdListWithCoordinates, favoriteString, location.coordinate.latitude, location.coordinate.longitude]]];
    request.timeOutSeconds = 30;
    request.didFinishSelector = @selector(gotFavoriteRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (BOOL)reachabilityCheckFails
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if (reachability.isReachable) {
        reachabilityCheckFailed = NO;
    } else {
        if (reachabilityCheckFailed == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors.NoConnectivity.Title", @"") message:NSLocalizedString(@"Errors.NoConnectivity.Message", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Buttons.OK", @"") otherButtonTitles:nil];
            [alert show];
        }
        reachabilityCheckFailed = YES;
    }
    return reachabilityCheckFailed;
}

- (void)gotRestaurants:(ASIHTTPRequest *)request
{
    // NSLog(@"request.responsedata: %@", request.responseString);
    NSArray *restaurants = [Restaurant restaurantsFromJson:request.responseString];
    [delegate gotRestaurants:restaurants];
}

- (void)gotFavoriteRestaurants:(ASIHTTPRequest *)request
{
    NSArray *restaurants = [Restaurant restaurantsFromJson:request.responseString];
    [delegate gotFavoriteRestaurants:restaurants];
}

- (void)failedToGetRestaurants:(ASIHTTPRequest *)request
{
    [delegate failedToGetRestaurants];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:@"Failed to get restaurants"
                                                              withFatal:@NO] build]];
}

@end
