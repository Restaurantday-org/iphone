//
//  RestaurantDataProvider.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"

@protocol RestaurantDataProviderDelegate <NSObject>
- (void)gotRestaurants:(NSArray *)restaurants;
- (void)failedToGetRestaurants;
@end

@interface RestaurantDataProvider : NSObject <ASIHTTPRequestDelegate> {
    ASINetworkQueue *queue;
}

@property (nonatomic, unsafe_unretained) id delegate;

- (void)startLoadingRestaurantsBetweenMinLat:(CLLocationDegrees)minLat maxLat:(CLLocationDegrees)maxLat minLon:(CLLocationDegrees)minLon maxLon:(CLLocationDegrees)maxLon;

@end
