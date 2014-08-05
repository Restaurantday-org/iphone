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
@class RestaurantDay;

@protocol RestaurantsDataSource <NSObject>

@property (nonatomic, readonly) RestaurantDay *nextRestaurantDay;
@property (nonatomic, readonly) NSArray *allRestaurants;
@property (nonatomic, readonly) NSArray *favoriteRestaurants;

- (void)refreshAllRestaurants;

- (void)addFavorite:(Restaurant *)restaurant;
- (void)removeFavorite:(Restaurant *)restaurant;

- (void)referenceLocationUpdated:(CLLocation *)location;

@end
