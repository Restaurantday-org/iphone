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
    
    self.infoViewer = [[UIViewController alloc] init];
    
    self.mapViewer = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    mapViewer.title = NSLocalizedString(@"Map", nil);
    [mapViewer view];
    
    self.listViewer = [[ListViewController alloc] init];
    listViewer.title = NSLocalizedString(@"List", nil);
    [listViewer view];
    
    self.favoritesViewer = [[ListViewController alloc] init];
    favoritesViewer.title = NSLocalizedString(@"Favorites", nil);
    [favoritesViewer view];
    
    UINavigationController *infoNavigationController = [[UINavigationController alloc] initWithRootViewController:infoViewer];
    infoNavigationController.title = NSLocalizedString(@"Ravintolapäivä", nil);
    infoNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-home.png"];
    
    UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewer];
    mapNavigationController.title = NSLocalizedString(@"Map", nil);
    mapNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-map.png"];
    
    UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:listViewer];
    listNavigationController.title = NSLocalizedString(@"List", nil);
    listNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-section.png"];
    
    UINavigationController *favoritesNavigationController = [[UINavigationController alloc] initWithRootViewController:favoritesViewer];
    favoritesNavigationController.title = NSLocalizedString(@"Favorites", nil);
    favoritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-favorites.png"];
        
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:infoNavigationController, mapNavigationController, listNavigationController, favoritesNavigationController, nil];
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
