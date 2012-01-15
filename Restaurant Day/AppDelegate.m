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
#import "SplashViewController.h"
#import "RestaurantDayViewController.h"

@interface CustomNavigationBar : UINavigationBar
@end

@interface AppDelegate (hidden)
- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize mapViewer, listViewer, favoritesViewer, infoViewer;

@synthesize dataProvider;
@synthesize splashViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.infoViewer = [[RestaurantDayViewController alloc] init];
    
    self.mapViewer = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    mapViewer.title = NSLocalizedString(@"Map", nil);
    [mapViewer view];
    
    self.listViewer = [[ListViewController alloc] initWithStyle:UITableViewStylePlain displayOnlyFavorites:NO];
    listViewer.title = NSLocalizedString(@"List", nil);
    [listViewer view];
    
    self.favoritesViewer = [[ListViewController alloc] initWithStyle:UITableViewStylePlain displayOnlyFavorites:YES];
    favoritesViewer.title = NSLocalizedString(@"Favorites", nil);
    [favoritesViewer view];
    
    UINavigationController *infoNavigationController = [self navigationControllerWithRootViewController:infoViewer];
    infoNavigationController.title = NSLocalizedString(@"Restaurant Day", nil);
    infoNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-home"];
    
    UINavigationController *mapNavigationController = [self navigationControllerWithRootViewController:mapViewer];
    mapNavigationController.title = NSLocalizedString(@"Map", nil);
    mapNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-map"];
    
    UINavigationController *listNavigationController = [self navigationControllerWithRootViewController:listViewer];
    listNavigationController.title = NSLocalizedString(@"List", nil);
    listNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-section"];
    
    UINavigationController *favoritesNavigationController = [self navigationControllerWithRootViewController:favoritesViewer];
    favoritesNavigationController.title = NSLocalizedString(@"Favorites", nil);
    favoritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-star-full"];
        
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mapNavigationController, listNavigationController, favoritesNavigationController, infoNavigationController, nil];
    self.tabBarController.selectedIndex = 3;
    
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

- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController
{
    UINavigationController *navigationController = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
    [navigationController setViewControllers:[NSArray arrayWithObject:rootViewController]];
    navigationController.navigationBar.tintColor = [UIColor grayColor];
    return navigationController;
}

@end

@implementation CustomNavigationBar
- (void)drawRect:(CGRect)rect 
{
    UIImage *image = [UIImage imageNamed: @"navi-gradient"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(c, [UIColor darkGrayColor].CGColor);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 0, self.frame.size.height);
    CGContextAddLineToPoint(c, 320, self.frame.size.height);
    CGContextStrokePath(c);
}
@end