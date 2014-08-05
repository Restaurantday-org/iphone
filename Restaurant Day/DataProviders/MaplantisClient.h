//
//  MaplantisClient.h
//  RestaurantDay
//
//  Created by Janne Käki on 05/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class RestaurantDay;

@interface MaplantisClient : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

- (void)getNextRestaurantDay:(void (^)(RestaurantDay *restaurantDay))success
                     failure:(void (^)(NSError *error))failure;

- (void)getAllRestaurantDays:(void (^)(NSArray *restaurantDays))success
                     failure:(void (^)(NSError *error))failure;

- (void)getAllRestaurantsForEventId:(NSString *)eventId
                            success:(void (^)(NSArray *restaurants))success
                            failure:(void (^)(NSError *error))failure;

@end
