//
//  AppDelegate.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantDataProvider.h"

@class MapViewController;
@class ListViewController;
@class SplashViewController;
@class RestaurantDayViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, RestaurantDataProviderDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) MapViewController *mapViewer;
@property (strong, nonatomic) ListViewController *listViewer;
@property (strong, nonatomic) ListViewController *favoritesViewer;
@property (strong, nonatomic) RestaurantDayViewController *infoViewer;

@property (strong, nonatomic) RestaurantDataProvider *dataProvider;

@end
