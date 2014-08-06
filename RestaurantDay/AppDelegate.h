//
//  AppDelegate.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantsDataSource.h"

@class InfoViewController;
@class MapViewController;
@class ListViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, RestaurantsDataSource>

@property (nonatomic) UIWindow *window;

@property (nonatomic) UITabBarController *tabBarController;

@property (nonatomic) MapViewController *mapViewer;
@property (nonatomic) ListViewController *listViewer;
@property (nonatomic) ListViewController *favoritesViewer;
@property (nonatomic) InfoViewController *infoViewer;

+ (BOOL)todayIsRestaurantDay;
+ (void)setTodayIsRestaurantDay:(BOOL)todayIsRestaurantDay;

@end
