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
    }
    return self;
}

- (void)startLoadingRestaurantsBetweenMinLat:(CLLocationDegrees)minLat maxLat:(CLLocationDegrees)maxLat minLon:(CLLocationDegrees)minLon maxLon:(CLLocationDegrees)maxLon
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://golf-174.srv.hosting.fi:8080/mobileapi/restaurants?lat=%f&lon=%f&maxDistanceKm=%d", 60.15f, 24.7f, 200]]];
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (void)gotRestaurants:(ASIHTTPRequest *)request
{
    NSLog(@"request.responsedata: %@", request.responseString);
    NSLog(@"request.url: %@", request.url);
    RestaurantParser *parser = [[RestaurantParser alloc] init];
    [delegate gotRestaurants:[parser createArrayFromRestaurantJson:request.responseString]];
}

- (void)failedToGetRestaurants:(ASIHTTPRequest *)request
{
    [delegate failedToGetRestaurants];

}

- (void)startLoadingFavoriteRestaurants
{
    NSString *favoriteString = [[NSString alloc] init];
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteRestaurants"];
    for (NSNumber *favoriteId in favorites) {
        favoriteString = [favoriteString stringByAppendingFormat:@",%d", [favoriteId intValue]];
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://golf-174.srv.hosting.fi:8080/mobileapi/restaurants/%@?lat=%f&lon=%f", favoriteString, 60.165725f, 24.9441f]]];
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (void)favoriteRestaurant:(NSNumber *)restaurantId
{
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

- (void)unfavoriteRestaurant:(NSNumber *)removeId
{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurants = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    for (NSNumber *restaurantId in favoriteRestaurants) {
        if ([restaurantId isEqualToNumber:removeId]) {
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
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://golf-174.srv.hosting.fi:8080/mobileapi/restaurants?lat=%f&lon=%f&maxDistanceKm=%d", center.latitude, center.longitude, distance]]];
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

@end
