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
#import <MapKit/MKMapView.h>

@protocol RestaurantDataProviderDelegate <NSObject>
- (void)gotRestaurants:(NSArray *)restaurants;
- (void)failedToGetRestaurants;
@end

@interface RestaurantDataProvider : NSObject <ASIHTTPRequestDelegate> {
    ASINetworkQueue *queue;
    BOOL reachabilityCheckFailed;
}

@property (nonatomic, unsafe_unretained) id delegate;

- (void)startLoadingRestaurantsBetweenMinLat:(CLLocationDegrees)minLat maxLat:(CLLocationDegrees)maxLat minLon:(CLLocationDegrees)minLon maxLon:(CLLocationDegrees)maxLon;
- (void)startLoadingRestaurantsWithCenter:(CLLocationCoordinate2D)center distance:(NSInteger)distance;
- (void)favoriteRestaurant:(NSNumber *)restaurantId;
- (void)unfavoriteRestaurant:(NSNumber *)removeId;
- (void)startLoadingFavoriteRestaurants;

@end
