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

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.trackedViewName = @"Map";
        
    map.delegate = self;
    map.showsUserLocation = YES;
    
    CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(60.1695, 24.9388);
    [map setRegion:MKCoordinateRegionMakeWithDistance(defaultCoordinate, 4000, 4000) animated:NO];
    
    updatedToUserLocation = NO;
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

- (void)reloadData
{
    NSArray *allRestaurants = [self.dataSource allRestaurants];
    for (Restaurant *restaurant in allRestaurants) {
        if (![map.annotations containsObject:restaurant]) {
            [map addAnnotation:restaurant];
        }
    }
}

- (void)reloadViewForRestaurant:(Restaurant *)restaurant
{
    [map removeAnnotation:restaurant];
    [map addAnnotation:restaurant];
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
    [self.dataSource userLocationUpdated:userLocation.location];
    
    if (!updatedToUserLocation || [userLocation.location distanceFromLocation:currentLocation] > 1000 || [userLocation.location distanceFromLocation:currentLocation] < 0) {
        if (userLocation.coordinate.latitude > -180 && userLocation.coordinate.latitude < 180 && userLocation.coordinate.longitude > -180 && userLocation.coordinate.longitude < 180) {
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000) animated:YES];
        }
        updatedToUserLocation = YES;
        currentLocation = userLocation.location;
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
        
        RestaurantViewController *restaurantViewController = [[RestaurantViewController alloc] init];
        restaurantViewController.restaurant = restaurant;
        restaurantViewController.dataSource = self.dataSource;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            [self.navigationController pushViewController:restaurantViewController animated:YES];
            
        } else {
            
            UINavigationController *navigator = [AppDelegate navigationControllerWithRootViewController:restaurantViewController];
            navigator.modalPresentationStyle = UIModalPresentationFormSheet;
            navigator.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController.tabBarController presentViewController:navigator animated:YES completion:nil];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationDistance radius = (mapView.region.span.latitudeDelta * 111000) + 1000;
    [self.dataSource refreshRestaurantsWithCenter:mapView.region.center radius:radius];
}

@end
