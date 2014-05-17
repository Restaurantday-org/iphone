//
//  AppDelegate.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantsDataSource.h"

@class MapViewController;
@class ListViewController;
@class SplashViewController;
@class InfoViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, RestaurantsDataSource>

@property (nonatomic) UIWindow *window;

@property (nonatomic) UITabBarController *tabBarController;

@property (nonatomic) MapViewController *mapViewer;
@property (nonatomic) ListViewController *listViewer;
@property (nonatomic) ListViewController *favoritesViewer;
@property (nonatomic) InfoViewController *infoViewer;

+ (BOOL)todayIsRestaurantDay;
+ (void)setTodayIsRestaurantDay:(BOOL)todayIsRestaurantDay;

+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController;

@end
