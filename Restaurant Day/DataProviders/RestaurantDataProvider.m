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
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://golf-174.srv.hosting.fi/mobileapi/restaurants.php"]];
    request.didFinishSelector = @selector(gotRestaurants:);
    request.didFailSelector = @selector(failedToGetRestaurants:);
    request.delegate = self;
    [queue addOperation:request];
    [queue go];
}

- (void)gotRestaurants:(ASIHTTPRequest *)request
{
    RestaurantParser *parser = [[RestaurantParser alloc] init];
    [delegate gotRestaurants:[parser createArrayFromRestaurantJson:request.responseString]];
}

- (void)failedToGetRestaurants:(ASIHTTPRequest *)request
{
    [delegate failedToGetRestaurants];

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

@end
