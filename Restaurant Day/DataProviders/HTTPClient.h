//
//  HTTPClient.h
//  RestaurantDay
//
//  Created by Janne Käki on 16/05/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

#import "Info.h"
#import "Restaurant.h"

#import <CoreLocation/CoreLocation.h>

@interface HTTPClient : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

- (void)getAllRestaurants:(void (^)(NSArray *restaurants))success
                  failure:(void (^)(NSError *error))failure;

- (void)getDetailsForRestaurant:(Restaurant *)restaurant
                        success:(void (^)(NSString *details))success
                        failure:(void (^)(NSError *error))failure;

- (void)getInfo:(void (^)(Info *info))success
        failure:(void (^)(NSError *error))failure;

@end
