//
//  AppDelegate.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "AppDelegate.h"

#import "InfoViewController.h"
#import "MaplantisClient.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import "Restaurant.h"
#import "RestaurantDay.h"

#import "GAI.h"

#import <Crashlytics/Crashlytics.h>

@interface RDNavigationController : UINavigationController

@end

@interface AppDelegate () {
    BOOL networkFailureAlertShown;
}

@property (nonatomic) RestaurantDay *nextRestaurantDay;
@property (nonatomic) NSArray *allRestaurants;
@property (nonatomic) NSMutableArray *favoriteRestaurants;
@property (nonatomic) CLLocation *referenceLocation;

@end

@implementation AppDelegate

static BOOL todayIsRestaurantDay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-28510102-3"];
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    
    [Crashlytics startWithAPIKey:@"79e3d6b88a2384bac40ffee7eb8c847bb6121da2"];
    
    if (IS_IOS_7_OR_LATER) {
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    } else {
        [UINavigationBar appearance].tintColor = [UIColor blackColor];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.mapViewer = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    self.mapViewer.dataSource = self;
    self.mapViewer.title = NSLocalizedString(@"Tabs.Map", nil);
    
    self.listViewer = [[ListViewController alloc] init];
    self.listViewer.dataSource = self;
    self.listViewer.displaysOnlyFavorites = NO;
    self.listViewer.title = NSLocalizedString(@"Tabs.List", nil);
    
    self.favoritesViewer = [[ListViewController alloc] init];
    self.favoritesViewer.dataSource = self;
    self.favoritesViewer.displaysOnlyFavorites = YES;
    self.favoritesViewer.title = NSLocalizedString(@"Tabs.Favorites", nil);
    
    self.infoViewer = [[InfoViewController alloc] init];
    self.infoViewer.dataSource = self;
    self.infoViewer.title = NSLocalizedString(@"Info", nil);
    
    UINavigationController *mapNavigationController = [[RDNavigationController alloc] initWithRootViewController:self.mapViewer];
    mapNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-map"];
    
    UINavigationController *listNavigationController = [[RDNavigationController alloc] initWithRootViewController:self.listViewer];
    listNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-section"];
    
    UINavigationController *favoritesNavigationController = [[RDNavigationController alloc] initWithRootViewController:self.favoritesViewer];
    favoritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-star-full"];
    
    self.infoViewer.tabBarItem.image = [UIImage imageNamed:@"footer-home"];
    
//    [@[mapNavigationController, listNavigationController, favoritesNavigationController] enumerateObjectsUsingBlock:^(UINavigationController *navigator, NSUInteger idx, BOOL *stop) {
//        navigator.title = [[navigator.viewControllers firstObject] title];
//    }];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[mapNavigationController, listNavigationController, favoritesNavigationController, self.infoViewer];
    self.tabBarController.selectedIndex = 0;
    self.tabBarController.tabBar.tintColor = [UIColor blackColor];
    self.tabBarController.delegate = self;
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [self refreshAllRestaurants];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.tabBarController.selectedIndex != 0) {
        [self.mapViewer loadView];
        [self.mapViewer viewDidLoad];
    }
    if (self.tabBarController.selectedIndex != 1) {
        [self.listViewer loadView];
        [self.listViewer viewDidLoad];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    networkFailureAlertShown = NO;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) viewController;
        if (navigationController.viewControllers.count > 1) {
            [navigationController popToRootViewControllerAnimated:NO];
        }
    }
}

#pragma mark - RestaurantsDataSource

- (void)refreshAllRestaurants
{
    [[MaplantisClient sharedInstance] getNextRestaurantDay:^(RestaurantDay *restaurantDay) {
        
        self.nextRestaurantDay = restaurantDay;
        [self.infoViewer refreshInfo];
        
        [[MaplantisClient sharedInstance] getAllRestaurantsForEventId:restaurantDay.id success:^(NSArray *restaurants) {
            
            [self gotRestaurants:restaurants];
            
        } failure:^(NSError *error) {
            
            [self failedToGetRestaurants];
        }];
        
    } failure:^(NSError *error) {
        
        [self failedToGetRestaurants];
    }];
}

- (void)gotRestaurants:(NSArray *)restaurants
{
    self.allRestaurants = restaurants;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *favoriteRestaurantIds = [defaults objectForKey:@"favoriteRestaurants"];
    
    for (Restaurant *restaurant in restaurants) {
        if ([favoriteRestaurantIds containsObject:restaurant.id]) {
            restaurant.favorite = YES;
        }
        [restaurant updateDistanceWithLocation:self.referenceLocation];
    }
    
    self.favoriteRestaurants = rd_filter(restaurants, ^BOOL(Restaurant *restaurant) {
        return restaurant.favorite;
    }).mutableCopy;
    
    NSDateFormatter *dayFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    NSString *todayStamp = [dayFormatter stringFromDate:[NSDate date]];
    NSString *restaurantDayStamp = [dayFormatter stringFromDate:self.nextRestaurantDay.date];
    AppDelegate.todayIsRestaurantDay = [todayStamp isEqualToString:restaurantDayStamp];
    
    [self.mapViewer reloadData];
    [self.listViewer reloadData];
    [self.favoritesViewer reloadData];
}

- (void)failedToGetRestaurants
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:@"Failed to get restaurants"
                                                              withFatal:@NO] build]];
    
    if (!networkFailureAlertShown) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors.LoadingRestaurantsFailed.Title", @"") message:NSLocalizedString(@"Errors.LoadingRestaurantsFailed.Message", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Buttons.OK", @"") otherButtonTitles:nil];
        [alert show];
        networkFailureAlertShown = YES;
    }
}

- (void)addFavorite:(Restaurant *)restaurant
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurantIds = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    if (favoriteRestaurantIds == nil) {
        favoriteRestaurantIds = [NSMutableArray array];
    }
    if (![favoriteRestaurantIds containsObject:restaurant.id]) {
        [favoriteRestaurantIds addObject:restaurant.id];
    }
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurantIds forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Add favorite, favorites: %@", favoriteRestaurantIds);
    
    [self.favoriteRestaurants addObject:restaurant];
    
    [self.mapViewer reloadViewForRestaurant:restaurant];
    [self.listViewer reloadData];
    [self.favoritesViewer reloadData];
}

- (void)removeFavorite:(Restaurant *)restaurant
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurantIds = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    [favoriteRestaurantIds removeObject:restaurant.id];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurantIds forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Remove favorite, favorites: %@", favoriteRestaurantIds);
    
    [self.favoriteRestaurants removeObject:restaurant];
    
    [self.mapViewer reloadViewForRestaurant:restaurant];
    [self.listViewer reloadData];
    [self.favoritesViewer reloadData];
}

- (void)referenceLocationUpdated:(CLLocation *)location
{
    for (Restaurant *restaurant in self.allRestaurants) {
        [restaurant updateDistanceWithLocation:location];
    }
    
    self.referenceLocation = location;
    
    if (self.favoriteRestaurants.count == 0) {
        
        // TODO: do something
    }
    
    [self.listViewer reloadData];
}

+ (BOOL)todayIsRestaurantDay
{
    return todayIsRestaurantDay;
}

+ (void)setTodayIsRestaurantDay:(BOOL)isRestaurantDay
{
    todayIsRestaurantDay = isRestaurantDay;
}

@end

@implementation RDNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end