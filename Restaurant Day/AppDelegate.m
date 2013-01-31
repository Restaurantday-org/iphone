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
#import "Restaurant.h"
#import "RestaurantDataProvider.h"
#import "RestaurantDayViewController.h"
#import "GAI.h"

@interface CustomNavigationBar : UINavigationBar
@end

@interface AppDelegate () <RestaurantDataProviderDelegate> {
    BOOL networkFailureAlertShown;
}

@property (strong, nonatomic) RestaurantDataProvider *dataProvider;
@property (strong, nonatomic) NSMutableArray *allRestaurants;
@property (strong, nonatomic) NSMutableArray *favoriteRestaurants;
@property (strong, nonatomic) CLLocation *referenceLocation;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize mapViewer, listViewer, favoritesViewer, infoViewer;

@synthesize dataProvider;

static BOOL todayIsRestaurantDay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-28510102-3"];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    self.allRestaurants = [NSMutableArray array];
    self.favoriteRestaurants = [NSMutableArray array];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.infoViewer = [[RestaurantDayViewController alloc] init];
    
    self.mapViewer = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    mapViewer.dataSource = self;
    mapViewer.title = NSLocalizedString(@"Tabs.Map", nil);
    
    self.listViewer = [[ListViewController alloc] init];
    listViewer.dataSource = self;
    listViewer.displaysOnlyFavorites = NO;
    listViewer.title = NSLocalizedString(@"Tabs.List", nil);
    
    self.favoritesViewer = [[ListViewController alloc] init];
    favoritesViewer.dataSource = self;
    favoritesViewer.displaysOnlyFavorites = YES;
    favoritesViewer.title = NSLocalizedString(@"Tabs.Favorites", nil);
    
    UINavigationController *infoNavigationController = [self.class navigationControllerWithRootViewController:infoViewer];
    infoNavigationController.title = NSLocalizedString(@"Tabs.About", nil);
    infoNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-home"];
    
    UINavigationController *mapNavigationController = [self.class navigationControllerWithRootViewController:mapViewer];
    mapNavigationController.title = NSLocalizedString(@"Tabs.Map", nil);
    mapNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-map"];
    
    UINavigationController *listNavigationController = [self.class navigationControllerWithRootViewController:listViewer];
    listNavigationController.title = NSLocalizedString(@"Tabs.List", nil);
    listNavigationController.tabBarItem.image = [UIImage imageNamed:@"footer-section"];
    
    UINavigationController *favoritesNavigationController = [self.class navigationControllerWithRootViewController:favoritesViewer];
    favoritesNavigationController.title = NSLocalizedString(@"Tabs.Favorites", nil);
    favoritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-star-full"];
        
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mapNavigationController, listNavigationController, favoritesNavigationController, infoNavigationController, nil];
    self.tabBarController.selectedIndex = 0;
    self.tabBarController.delegate = self;
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    self.dataProvider = [[RestaurantDataProvider alloc] init];
    dataProvider.delegate = self;
    // [dataProvider startLoadingRestaurantsBetweenMinLat:59 maxLat:71 minLon:20 maxLon:32]; WTF!?!?!!? -JK
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.tabBarController.selectedIndex != 0) {
        [mapViewer loadView];
        [mapViewer viewDidLoad];
    }
    if (self.tabBarController.selectedIndex != 1) {
        [listViewer loadView];
        [listViewer viewDidLoad];
    }
    if (self.tabBarController.selectedIndex != 3) {
        [infoViewer loadView];
        [infoViewer viewDidLoad];
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

- (void)refreshRestaurantsWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius
{
    [self.dataProvider startLoadingRestaurantsWithCenter:center distanceInKilometers:(radius / 1000)];
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
    
    [mapViewer reloadData];
    [listViewer reloadData];
}

- (void)gotFavoriteRestaurants:(NSArray *)favorites
{
    for (Restaurant *favorite in favorites) {
        if (![self.favoriteRestaurants containsObject:favorite]) {
            [self.favoriteRestaurants addObject:favorite];
        }
    }
    
    [favoritesViewer reloadData];
}

- (void)failedToGetRestaurants
{
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
    [favoriteRestaurants addObject:restaurant.restaurantId];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurants forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Add favorite, favorites: %@", favoriteRestaurants);
    
    [self.favoriteRestaurants addObject:restaurant];
    
    [mapViewer reloadViewForRestaurant:restaurant];
    [listViewer reloadData];
    [favoritesViewer reloadData];
}

- (void)removeFavorite:(Restaurant *)restaurant
{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRestaurants = [[defaults objectForKey:@"favoriteRestaurants"] mutableCopy];
    for (NSString *restaurantId in favoriteRestaurants) {
        if ([restaurantId isEqualToString:restaurant.restaurantId]) {
            [removeObjects addObject:restaurantId];
        }
    }
    [favoriteRestaurants removeObjectsInArray:removeObjects];
    [[NSUserDefaults standardUserDefaults] setValue:favoriteRestaurants forKey:@"favoriteRestaurants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Remove favorite, favorites: %@", favoriteRestaurants);
    
    [self.favoriteRestaurants removeObject:restaurant];
    
    [mapViewer reloadViewForRestaurant:restaurant];
    [listViewer reloadData];
    [favoritesViewer reloadData];
}

- (void)referenceLocationUpdated:(CLLocation *)location
{
    for (Restaurant *restaurant in self.allRestaurants) {
        [restaurant updateDistanceWithLocation:location];
    }
    
    self.referenceLocation = location;
    
    if (self.favoriteRestaurants.count == 0) {
        [self.dataProvider startLoadingFavoriteRestaurantsWithLocation:location];
    }
    
    [listViewer reloadData];    
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