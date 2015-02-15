//
//  MaplantisClient.m
//  RestaurantDay
//
//  Created by Janne Käki on 05/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "MaplantisClient.h"

#import "Restaurant.h"
#import "RestaurantDay.h"

@interface MaplantisClient ()

@end

@implementation MaplantisClient

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://www.maplantis.com/api/public/"]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (void)getNextRestaurantDay:(void (^)(RestaurantDay *restaurantDay))success
                     failure:(void (^)(NSError *error))failure
{
    [self getAllRestaurantDays:^(NSArray *restaurantDays) {
        
        NSArray *openDays = rd_filter(restaurantDays, ^BOOL(RestaurantDay *rd) {
            return rd.isOpen;
        });
        
        RestaurantDay *nextOpenDay = [openDays sortedArrayUsingComparator:^NSComparisonResult(RestaurantDay *rd1, RestaurantDay *rd2) {
            return [rd1.date compare:rd2.date];
        }].firstObject;
        
        if (success) success(nextOpenDay);
        
    } failure:^(NSError *error) {
        
        if (failure) failure(error);
    }];
}

- (void)getAllRestaurantDays:(void (^)(NSArray *restaurantDays))success
                     failure:(void (^)(NSError *error))failure
{
    [self GET:@"organization-name/restaurantday/maps" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"got restaurant days: %@", responseObject);
        
        NSArray *restaurantDayDicts = [NSArray cast:responseObject];
        NSArray *restaurantDays = [RestaurantDay restaurantDaysFromArrayOfMaplantisDicts:restaurantDayDicts];
        if (success) success(restaurantDays);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failed to load restaurant days: %@", error);
        if (failure) failure(error);
    }];
}

- (void)getAllRestaurantsForEventId:(NSString *)eventId
                            success:(void (^)(NSArray *restaurants))success
                            failure:(void (^)(NSError *error))failure
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *restaurantsPath = [paths.firstObject stringByAppendingFormat:@"/restaurants-%@.json", eventId];
    NSArray *restaurantDicts = [NSArray arrayWithContentsOfFile:restaurantsPath];
    
    NSString *defaultsKeyForRefreshDate = [NSString stringWithFormat:@"restaurants-%@-refreshedAt", eventId];
    
    if (restaurantDicts.count) {
        
        NSArray *restaurants = [Restaurant restaurantsFromArrayOfMaplantisDicts:restaurantDicts];
        if (success) success(restaurants);
        
        NSDate *restaurantsRefreshedAt = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKeyForRefreshDate];
        
        if (fabs([restaurantsRefreshedAt timeIntervalSinceNow]) < 60 * 60) {
            return;
        }
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"event-map"] = eventId ?: @"";
    params[@"limit"] = @5000;
    
    [self GET:@"events" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *restaurantDicts = [NSArray cast:responseObject];
        NSLog(@"got restaurants: %@", restaurantDicts);
        
        NSArray *restaurants = [Restaurant restaurantsFromArrayOfMaplantisDicts:restaurantDicts];
        if (success) success(restaurants);
        
        if (restaurants.count) {
            [restaurantDicts writeToFile:restaurantsPath atomically:YES];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:defaultsKeyForRefreshDate];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failed to get restaurants: %@", error);
        if (failure) failure(error);
    }];
}

@end
