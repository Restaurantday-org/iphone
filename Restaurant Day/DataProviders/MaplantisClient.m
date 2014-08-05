//
//  MaplantisClient.m
//  RestaurantDay
//
//  Created by Janne Käki on 05/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "MaplantisClient.h"

#import "Restaurant.h"

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
            
            NSArray *restaurants = [Restaurant restaurantsFromArrayOfMaplantisDicts:restaurantDicts];
            if (success) success(restaurants);
            
            NSDate *restaurantsRefreshedAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"restaurantsRefreshedAt"];
            
            if (fabs([restaurantsRefreshedAt timeIntervalSinceNow]) < 6 * 60 * 60) {
                return;
            }
        }
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"limit"] = @5000;
    
    [self GET:@"events" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *restaurantDicts = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        // NSLog(@"got restaurants: %@", restaurantDicts);
        
        NSArray *restaurants = [Restaurant restaurantsFromArrayOfMaplantisDicts:restaurantDicts];
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

@end
