//
//  AppDelegate.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "AppDelegate.h"

#import "MapViewController.h"
#import "ListViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize mapViewer, listViewer, favoritesViewer, infoViewer;

@synthesize dataProvider;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.mapViewer = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    self.listViewer = [[ListViewController alloc] init];

    self.favoritesViewer = [[ListViewController alloc] init];
    
    self.infoViewer = [[UIViewController alloc] init];
    
    UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewer];
    mapNavigationController.title = NSLocalizedString(@"Map", nil);

    UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:listViewer];
    listNavigationController.title = NSLocalizedString(@"List", nil);
    
    UINavigationController *favoritesNavigationController = [[UINavigationController alloc] initWithRootViewController:favoritesViewer];
    favoritesNavigationController.title = NSLocalizedString(@"Favorites", nil);

    UINavigationController *infoNavigationController = [[UINavigationController alloc] initWithRootViewController:infoViewer];
    infoNavigationController.title = NSLocalizedString(@"Info", nil);
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mapNavigationController, listNavigationController, favoritesNavigationController, infoNavigationController, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    self.dataProvider = [[RestaurantDataProvider alloc] init];
    dataProvider.delegate = self;
    [dataProvider startLoadingRestaurantsBetweenMinLat:59 maxLat:71 minLon:20 maxLon:32];
        
    return YES;
}

- (void)gotRestaurants:(NSArray *)restaurants
{
    mapViewer.restaurants = restaurants;
    listViewer.restaurants = restaurants;
}

- (void)failedToGetRestaurants
{
}

@end
