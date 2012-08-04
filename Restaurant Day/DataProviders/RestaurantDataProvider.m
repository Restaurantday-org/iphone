//
//  RestaurantDataProvider.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDataProvider.h"
#import "Restaurant.h"
#import "RestaurantParser.h"
#import "Reachability.h"

@interface RestaurantDataProvider (hidden)
- (void)gotRestaurants:(ASIHTTPRequest *)request;
- (void)failedToGetRestaurants:(ASIHTTPRequest *)request;
@end

@implementation RestaurantDataProvider

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
        reachabilityCheckFailed = NO;
    }
    return self;
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

- (void)startLoadingRestaurantsBetweenMinLat:(CLLocationDegrees)minLat maxLat:(CLLocationDegrees)maxLat minLon:(CLLocationDegrees)minLon maxLon:(CLLocationDegrees)maxLon
{
    if ([self reachabilityCheckFails]) { return; }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:kURLForRestaurantsWithCenterAndDistance, 60.15f, 24.7f, 200]]];
    request.timeOutSeconds = 30;
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (void)gotRestaurants:(ASIHTTPRequest *)request
{
    //NSLog(@"request.responsedata: %@", request.responseString);
    RestaurantParser *parser = [[RestaurantParser alloc] init];
    NSArray *restaurantArray = [parser createArrayFromRestaurantJson:request.responseString];
    [delegate gotRestaurants:restaurantArray];
}

- (void)failedToGetRestaurants:(ASIHTTPRequest *)request
{
    [delegate failedToGetRestaurants];
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
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (void)favoriteRestaurant:(NSString *)restaurantId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteAdded object:restaurantId];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurants = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    if (favoriteRestaurants == nil) {
        favoriteRestaurants = [[NSMutableArray alloc] init];
    }
    [favoriteRestaurants addObject:restaurantId];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurants forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Add favorite, favorites: %@", favoriteRestaurants);
}

- (void)unfavoriteRestaurant:(NSString *)removeId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteRemoved object:removeId];
    
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurants = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    for (NSString *restaurantId in favoriteRestaurants) {
        if ([restaurantId isEqualToString:removeId]) {
            [removeObjects addObject:restaurantId];
        }
    }
    [favoriteRestaurants removeObjectsInArray:removeObjects];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurants forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Remove favorite, favorites: %@", favoriteRestaurants);
}

- (void)startLoadingRestaurantsWithCenter:(CLLocationCoordinate2D)center distance:(NSInteger)distance
{
    if ([self reachabilityCheckFails]) { return; }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:kURLForRestaurantsWithCenterAndDistance, center.latitude, center.longitude, distance]]];
    request.timeOutSeconds = 30;
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

@end
