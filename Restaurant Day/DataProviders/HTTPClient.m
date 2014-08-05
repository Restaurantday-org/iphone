//
//  HTTPClient.m
//  RestaurantDay
//
//  Created by Janne Käki on 16/05/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "HTTPClient.h"

#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>

@implementation HTTPClient

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
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://api.restaurantday.org/mobileapi/"]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)getAllRestaurants:(void (^)(NSArray *restaurants))success
                  failure:(void (^)(NSError *error))failure
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *restaurantsPath = [paths.firstObject stringByAppendingString:@"/restaurants.json"];
    {
        NSArray *restaurantDicts = [NSArray arrayWithContentsOfFile:restaurantsPath];
        if (restaurantDicts.count) {
            
            NSArray *restaurants = [Restaurant restaurantsFromArrayOfDicts:restaurantDicts];
            if (success) success(restaurants);
            
            NSDate *restaurantsRefreshedAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"restaurantsRefreshedAt"];
            
            if (fabs([restaurantsRefreshedAt timeIntervalSinceNow]) < 6 * 60 * 60) {
                return;
            }
        }
    }
        
    [self GET:@"v2/restaurants" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *restaurantDicts = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"got restaurants: %@", restaurantDicts);
        
        NSArray *restaurants = [Restaurant restaurantsFromArrayOfDicts:restaurantDicts];
        if (success) success(restaurants);
        
        if (restaurantDicts.count) {
            [restaurantDicts writeToFile:restaurantsPath atomically:YES];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"restaurantsRefreshedAt"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"failed to get restaurants: %@", error);
        if (failure) failure(error);
    }];
}

- (void)getDetailsForRestaurant:(Restaurant *)restaurant
                        success:(void (^)(NSString *details))success
                        failure:(void (^)(NSError *error))failure
{
    NSString *href = [NSString stringWithFormat:@"restaurant/%@", restaurant.id];
    
    [[HTTPClient sharedInstance] GET:href parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"got restaurant details: %@", operation.responseString);
        if (success) success(operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"failed to get restaurant details: %@", error);
        if (failure) failure(error);
    }];
}

- (void)getInfo:(void (^)(Info *info))success
        failure:(void (^)(NSError *error))failure
{
    [[HTTPClient sharedInstance] GET:@"info" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"got info: %@", responseDict);
        
        Info *info = [Info infoFromDict:responseDict];
        
        NSDateFormatter *dayFormatter = [NSDateFormatter dateFormatterWithFormat:@"dd.MM.yyyy"];
        NSString *dateToday = [dayFormatter stringFromDate:[NSDate date]];
        NSString *dateOnRestaurantDay = [dayFormatter stringFromDate:info.nextDate];
        [AppDelegate setTodayIsRestaurantDay:[dateToday isEqual:dateOnRestaurantDay]];
        
        if (success) success(info);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failed to get info: %@", error);
        if (failure) failure(error);
    }];
}

@end
