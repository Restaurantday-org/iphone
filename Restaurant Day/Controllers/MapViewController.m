//
//  FirstViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "Restaurant.h"
#import "RestaurantViewController.h"

#define kRestaurantIconViewTag 1000

@interface MapViewController (hidden)
- (void)showSplash;
- (void)hideSplash;
@end

@implementation MapViewController

@synthesize map;
@synthesize splashViewer;

@dynamic restaurants;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataProvider = [[RestaurantDataProvider alloc] init];
    dataProvider.delegate = self;  
    
    self.trackedViewName = @"Map";
    
    // [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    map.delegate = self;
    map.showsUserLocation = YES;
    
    CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(60.1695, 24.9388);
    [map setRegion:MKCoordinateRegionMakeWithDistance(defaultCoordinate, 4000, 4000) animated:NO];
    
    updatedToUserLocation = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:kFavoriteAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteRemoved:) name:kFavoriteRemoved object:nil];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-locate"] style:UIBarButtonItemStyleBordered target:self action:@selector(focusOnUserLocation)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = [[UIView alloc] init];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasLaunchedBefore] == NO) {
        self.splashViewer = [[RestaurantDayViewController alloc] init];
        splashViewer.modalPresentation = YES;
        splashViewer.view.frame = self.view.bounds;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasLaunchedBefore];
        [self.view addSubview:splashViewer.view];
    }
}

- (void)viewDidUnload
{    
    self.map = nil;
    [super viewDidUnload];
}

- (NSArray *)restaurants
{
    return restaurants;
}

/*- (void)setRestaurants:(NSArray *)newRestaurants
{
    [map removeAnnotations:restaurants];
    restaurants = nil;
    
    [self addRestaurants:newRestaurants];
}*/

- (void)addRestaurants:(NSArray *)newRestaurants
{
    NSLog(@"number of new restaurants: %d", newRestaurants.count);
    if (restaurants == nil) {
        restaurants = [NSMutableArray arrayWithArray:newRestaurants];
        [map addAnnotations:restaurants];
    } else {
        for (Restaurant *restaurant in newRestaurants) {
            if (![restaurants containsObject:restaurant]) {
                [restaurants addObject:restaurant];
            }
            if (![map.annotations containsObject:restaurant]) {
                [map addAnnotation:restaurant];
            }
        }
    }
        
    if (map.userLocation != nil) {
        for (Restaurant *restaurant in restaurants) {
            [restaurant updateDistanceWithLocation:map.userLocation.location];
        }
    }
}

- (void)favoriteAdded:(NSNotification *)notification
{
    NSString *restaurantId = notification.object;
    for (Restaurant *mapRestaurant in map.annotations) {
        if ([mapRestaurant isMemberOfClass:[Restaurant class]] && [mapRestaurant.restaurantId isEqualToString:restaurantId]) {
            [map removeAnnotation:mapRestaurant];
            mapRestaurant.favorite = YES;
            [map addAnnotation:mapRestaurant];
        }
    }
}

- (void)favoriteRemoved:(NSNotification *)notification
{
    NSString *restaurantId = notification.object;
    for (Restaurant *mapRestaurant in map.annotations) {
        if ([mapRestaurant isMemberOfClass:[Restaurant class]] && [mapRestaurant.restaurantId isEqualToString:restaurantId]) {
            [map removeAnnotation:mapRestaurant];
            mapRestaurant.favorite = NO;
            [map addAnnotation:mapRestaurant];
        }
    }
}

- (IBAction)focusOnUserLocation
{
    if (map.userLocation != nil) {
        
        [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Map"
                                                           withAction:@"Center map"
                                                            withLabel:@""
                                                            withValue:nil];
        
        CLLocationCoordinate2D userCoordinate = map.userLocation.coordinate;
        if (userCoordinate.latitude != 0 && userCoordinate.longitude != 0) {
            [map setCenterCoordinate:map.userLocation.coordinate animated:YES];
        }
    }
}

#pragma mark - MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdated object:userLocation.location userInfo:nil];
    
    // NSLog(@"distance: %f", [userLocation.location distanceFromLocation:currentLocation]);
    // NSLog(@"%@, %@", userLocation.location, currentLocation);
    if (!updatedToUserLocation || [userLocation.location distanceFromLocation:currentLocation] > 1000 || [userLocation.location distanceFromLocation:currentLocation] < 0) {
        if (userLocation.coordinate.latitude > -180 && userLocation.coordinate.latitude < 180 && userLocation.coordinate.longitude > -180 && userLocation.coordinate.longitude < 180) {
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000) animated:YES];
        }
        updatedToUserLocation = YES;
        currentLocation = userLocation.location;
    }
    
    for (Restaurant *restaurant in restaurants) {
        [restaurant updateDistanceWithLocation:userLocation.location];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Restaurant class]]) {
        
        static NSString *restaurantViewId = @"RestaurantView";
        MKAnnotationView *restaurantView = [mapView dequeueReusableAnnotationViewWithIdentifier:restaurantViewId];
        
        if (restaurantView == nil) {
            
            restaurantView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:restaurantViewId];
            restaurantView.frame = CGRectMake(0, 0, 14, 22);
            restaurantView.canShowCallout = YES;
            restaurantView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            UIImageView *restaurantIconView = [[UIImageView alloc] init];
            restaurantIconView.alpha = 0.7;
            restaurantIconView.tag = kRestaurantIconViewTag;
            [restaurantView addSubview:restaurantIconView];
            
        } else {
            
            restaurantView.annotation = annotation;
        }
        
        Restaurant *restaurant = (Restaurant *) annotation;
        UIImageView *restaurantIconView = (UIImageView *) [restaurantView viewWithTag:kRestaurantIconViewTag];
        if (restaurant.isOpen) {
            restaurantIconView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-open-star" : @"pin-open"];
        } else if (restaurant.isAlreadyClosed) {
            restaurantIconView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-closed-star" : @"pin-closed"];
        } else {
            restaurantIconView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-generic-star" : @"pin-generic"];
        }
        
        restaurantIconView.frame = CGRectMake(0, 0, 14, 22);
        
        return restaurantView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[Restaurant class]]) {
        UIImageView *restaurantIconView = (UIImageView *) [view viewWithTag:kRestaurantIconViewTag];
        restaurantIconView.alpha = 1;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[Restaurant class]]) {
        UIImageView *restaurantIconView = (UIImageView *) [view viewWithTag:kRestaurantIconViewTag];
        restaurantIconView.alpha = 0.7;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[Restaurant class]]) {
        
        Restaurant *restaurant = (Restaurant *) view.annotation;
        
        [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Map"
                                                           withAction:@"Open restaurant"
                                                            withLabel:restaurant.name
                                                            withValue:nil];
        
        RestaurantViewController *companyViewController = [[RestaurantViewController alloc] init];
        companyViewController.restaurant = restaurant;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            [self.navigationController pushViewController:companyViewController animated:YES];
            
        } else {
            
            UINavigationController *navigator = [AppDelegate navigationControllerWithRootViewController:companyViewController];
            navigator.modalPresentationStyle = UIModalPresentationFormSheet;
            navigator.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController.tabBarController presentViewController:navigator animated:YES completion:nil];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSInteger kilometers = (mapView.region.span.latitudeDelta*111)+1;
    CLLocationCoordinate2D center = mapView.region.center;
    [dataProvider startLoadingRestaurantsWithCenter:center distance:kilometers];
    networkFailureAlertShown = NO;
}

- (void)gotRestaurants:(NSArray *)newRestaurants
{
    [self addRestaurants:newRestaurants];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMapLoadedNewRestaurants object:newRestaurants];
}

- (void)failedToGetRestaurants
{
    if (!networkFailureAlertShown) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors.LoadingRestaurantsFailed.Title", @"") message:NSLocalizedString(@"Errors.LoadingRestaurantsFailed.Message", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Buttons.OK", @"") otherButtonTitles:nil];
        [alert show];
        networkFailureAlertShown = YES;
    }
}

@end
