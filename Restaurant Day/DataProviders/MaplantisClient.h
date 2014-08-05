//
//  MaplantisClient.h
//  RestaurantDay
//
//  Created by Janne Käki on 05/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface MaplantisClient : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

- (void)getAllRestaurants:(void (^)(NSArray *restaurants))success
                  failure:(void (^)(NSError *error))failure;

@end
