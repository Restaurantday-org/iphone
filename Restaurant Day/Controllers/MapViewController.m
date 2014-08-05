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

@interface Pin : NSObject <MKAnnotation>
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@end

@implementation Pin
@end

@interface MapViewController () {
    BOOL updatedToUserLocation;
    CLLocation *currentLocation;
}

@property (nonatomic) Pin *pin;

CLLocationDistance distanceFromLatitudeDelta(CLLocationDegrees delta);

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.screenName = @"Map";
        
    self.map.delegate = self;
    self.map.showsUserLocation = YES;
    
    CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(60.1695, 24.9388);
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(defaultCoordinate, 4000, 4000) animated:NO];
    
    self.pin = [Pin new];
    self.pin.coordinate = defaultCoordinate;
    [self.map addAnnotation:self.pin];
    
    self.pinButton.alpha = 0;
    
    updatedToUserLocation = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = [[UIView alloc] init];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidUnload
{    
    self.map = nil;
    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)reloadData
{
    NSArray *allRestaurants = [self.dataSource allRestaurants];
    for (Restaurant *restaurant in allRestaurants) {
        if (![self.map.annotations containsObject:restaurant]) {
            [self.map addAnnotation:restaurant];
        }
    }
}

- (void)reloadViewForRestaurant:(Restaurant *)restaurant
{
    [self.map removeAnnotation:restaurant];
    [self.map addAnnotation:restaurant];
}

- (IBAction)focusOnUserLocation
{
    if (self.map.userLocation != nil) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Map"
                                                              action:@"Center map"
                                                               label:@""
                                                               value:nil] build]];
        
        CLLocationCoordinate2D userCoordinate = self.map.userLocation.coordinate;
        if (userCoordinate.latitude != 0 && userCoordinate.longitude != 0) {
            
            [self.map setCenterCoordinate:self.map.userLocation.coordinate animated:YES];
            
            self.pin.coordinate = userCoordinate;
            
            [self.dataSource referenceLocationUpdated:self.map.userLocation.location];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.pinButton.alpha = 0;
        }];
    }
}

- (IBAction)repositionPin
{
    self.pin.coordinate = self.map.centerCoordinate;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.pin.coordinate.latitude longitude:self.pin.coordinate.longitude];
    [self.dataSource referenceLocationUpdated:location];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"first pin repositioning done"]) {
        [defaults setBool:YES forKey:@"first pin repositioning done"];
        [defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map.FirstPin.Title", @"") message:NSLocalizedString(@"Map.FirstPin.Message", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Buttons.OK", @"") otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{    
    if (!updatedToUserLocation || [userLocation.location distanceFromLocation:currentLocation] > 1000 || [userLocation.location distanceFromLocation:currentLocation] < 0) {
        if (userLocation.coordinate.latitude > -180 && userLocation.coordinate.latitude < 180 && userLocation.coordinate.longitude > -180 && userLocation.coordinate.longitude < 180) {
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000) animated:YES];
            self.pin.coordinate = userLocation.coordinate;
            [self.dataSource referenceLocationUpdated:userLocation.location];
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
    
    if ([annotation isKindOfClass:Pin.class]) {
        return [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
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
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Map"
                                                              action:@"Open restaurant"
                                                               label:restaurant.name
                                                               value:nil] build]];
        
        RestaurantViewController *restaurantViewController = [[RestaurantViewController alloc] init];
        restaurantViewController.restaurant = restaurant;
        restaurantViewController.dataSource = self.dataSource;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            [self.navigationController pushViewController:restaurantViewController animated:YES];
            
        } else {
            
            UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:restaurantViewController];
            navigator.modalPresentationStyle = UIModalPresentationFormSheet;
            navigator.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController.tabBarController presentViewController:navigator animated:YES completion:nil];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{    
    CLLocation *center = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    if ([center distanceFromLocation:mapView.userLocation.location] > 50) {
        [UIView animateWithDuration:0.5 animations:^{
            self.pinButton.alpha = 1;
        }];
    }
}

CLLocationDistance distanceFromLatitudeDelta(CLLocationDegrees delta) {
    return (delta * 111000);
}

@end
