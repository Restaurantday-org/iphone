//
//  AppDelegate.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "AppDelegate.h"

#import "MaplantisClient.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import "Restaurant.h"
#import "InfoViewController.h"
#import "GAI.h"

@interface CustomNavigationBar : UINavigationBar
@end

@interface AppDelegate () {
    BOOL networkFailureAlertShown;
}

@property (nonatomic) NSMutableArray *allRestaurants;
@property (nonatomic) NSMutableArray *favoriteRestaurants;
@property (nonatomic) CLLocation *referenceLocation;

@end

@implementation AppDelegate

static BOOL todayIsRestaurantDay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-28510102-3"];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    self.allRestaurants = [NSMutableArray array];
    self.favoriteRestaurants = [NSMutableArray array];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.infoViewer = [[InfoViewController alloc] init];
    
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
    
    UINavigationController *infoNavigationController = [self.class navigationControllerWithRootViewController:self.infoViewer];
    infoNavigationController.title = NSLocalizedString(@"Tabs.About", nil);
    infoNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-home"];
    
    UINavigationController *mapNavigationController = [self.class navigationControllerWithRootViewController:self.mapViewer];
    mapNavigationController.title = NSLocalizedString(@"Tabs.Map", nil);
    mapNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-map"];
    
    UINavigationController *listNavigationController = [self.class navigationControllerWithRootViewController:self.listViewer];
    listNavigationController.title = NSLocalizedString(@"Tabs.List", nil);
    listNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-section"];
    
    UINavigationController *favoritesNavigationController = [self.class navigationControllerWithRootViewController:self.favoritesViewer];
    favoritesNavigationController.title = NSLocalizedString(@"Tabs.Favorites", nil);
    favoritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-star-full"];
        
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mapNavigationController, listNavigationController, favoritesNavigationController, infoNavigationController, nil];
    self.tabBarController.selectedIndex = 0;
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
    if (self.tabBarController.selectedIndex != 3) {
        [self.infoViewer loadView];
        [self.infoViewer viewDidLoad];
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
    [[MaplantisClient sharedInstance] getAllRestaurants:^(NSArray *restaurants) {
        
        [self gotRestaurants:restaurants];
        
    } failure:^(NSError *error) {
        
        [self failedToGetRestaurants];
    }];    
}

- (void)gotRestaurants:(NSArray *)restaurants
{
    for (Restaurant *restaurant in restaurants) {
        if (![self.allRestaurants containsObject:restaurant]) {
            [self.allRestaurants addObject:restaurant];
            if ([self.favoriteRestaurants containsObject:restaurant]) {
                restaurant.favorite = YES;
            }
            [restaurant updateDistanceWithLocation:self.referenceLocation];
        }
    }
    
    [self.mapViewer reloadData];
    [self.listViewer reloadData];
}

- (void)gotFavoriteRestaurants:(NSArray *)favorites
{
    for (Restaurant *favorite in favorites) {
        if (![self.favoriteRestaurants containsObject:favorite]) {
            [self.favoriteRestaurants addObject:favorite];
        }
    }
    
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
    NSMutableArray *favoriteRestaurants = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    if (favoriteRestaurants == nil) {
        favoriteRestaurants = [[NSMutableArray alloc] init];
    }
    [favoriteRestaurants addObject:restaurant.id];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurants forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Add favorite, favorites: %@", favoriteRestaurants);
    
    [self.favoriteRestaurants addObject:restaurant];
    
    [self.mapViewer reloadViewForRestaurant:restaurant];
    [self.listViewer reloadData];
    [self.favoritesViewer reloadData];
}

- (void)removeFavorite:(Restaurant *)restaurant
{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurants = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    for (NSString *restaurantId in favoriteRestaurants) {
        if ([restaurantId isEqualToString:restaurant.id]) {
            [removeObjects addObject:restaurantId];
        }
    }
    [favoriteRestaurants removeObjectsInArray:removeObjects];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurants forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Remove favorite, favorites: %@", favoriteRestaurants);
    
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

//- (void)maximumDistanceChanged:(CLLocationDistance)distance
//{
//    if (distance > self.currentMaximumDistance) {
//        [self refreshRestaurantsWithCenter:self.referenceLocation.coordinate radius:distance];
//    }
//    self.currentMaximumDistance = distance;
//}

+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController
{
    UINavigationController *navigationController = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
    [navigationController setViewControllers:[NSArray arrayWithObject:rootViewController]];
    navigationController.navigationBar.tintColor = [UIColor grayColor];
    return navigationController;
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