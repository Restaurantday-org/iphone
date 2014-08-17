//
//  RestaurantCluster.h
//  RestaurantDay
//
//  Created by Janne Käki on 15/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RestaurantCluster : NSObject <MKAnnotation>

+ (instancetype)clusterWithRestaurants:(NSArray *)restaurants;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSArray *restaurants;
@property (nonatomic, readonly) BOOL isAlreadyClosed;

@end
