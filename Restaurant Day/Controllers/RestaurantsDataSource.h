//
//  RestaurantsDataSource.h
//  RestaurantDay
//
//  Created by Janne Käki on 1/31/13.
//  Copyright (c) 2013 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Restaurant;

@protocol RestaurantsDataSource <NSObject>

- (NSArray *)allRestaurants;
- (NSArray *)favoriteRestaurants;
- (void)refreshRestaurantsWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius;
- (void)addFavorite:(Restaurant *)restaurant;
- (void)removeFavorite:(Restaurant *)restaurant;
- (void)referenceLocationUpdated:(CLLocation *)location;

@end
