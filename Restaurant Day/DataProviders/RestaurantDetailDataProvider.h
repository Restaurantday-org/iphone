//
//  RestaurantDetailDataProvider.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@protocol RestaurantDetailDataProviderDelegate
- (void)gotDetails:(NSString *)details;
@end

@interface RestaurantDetailDataProvider : NSObject {
    ASINetworkQueue *queue;
}

@property (nonatomic, strong) id<RestaurantDetailDataProviderDelegate> delegate;

- (void)startGettingDetailsForRestaurantId:(NSInteger)restaurantId;

@end
