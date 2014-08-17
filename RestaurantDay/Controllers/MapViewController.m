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
#import "RestaurantCluster.h"
#import "RestaurantViewController.h"

#define kRestaurantLabelTag 1000

CLLocationDistance distanceFromLatitudeDelta(CLLocationDegrees delta);

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

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.screenName = @"Map";
    
    self.map.delegate = self;
    
    self.locationManager = [CLLocationManager new];
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
    
    self.map.showsUserLocation = YES;
    
    CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(60.1695, 24.9388);
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(defaultCoordinate, 4000, 4000) animated:NO];
    
    self.pin = [Pin new];
    self.pin.coordinate = defaultCoordinate;
    [self.map addAnnotation:self.pin];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.pin.coordinate.latitude longitude:self.pin.coordinate.longitude];
    [self.dataSource referenceLocationUpdated:location];
    
    updatedToUserLocation = NO;
    
    if (!IS_IOS_7_OR_LATER) {
        self.map.y = 0;
        self.map.height = self.view.height;
        self.pinButton.y -= 20;
        self.locateButton.y -= 20;
    }
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
    MKCoordinateRegion region = self.map.region;
    CLLocationDegrees minLatitude = region.center.latitude - region.span.latitudeDelta / 2;
    CLLocationDegrees maxLatitude = region.center.latitude + region.span.latitudeDelta / 2;
    CLLocationDegrees minLongitude = region.center.longitude - region.span.longitudeDelta / 2;
    CLLocationDegrees maxLongitude = region.center.longitude + region.span.longitudeDelta / 2;
    
    NSArray *allRestaurants = [self.dataSource allRestaurants];
    NSArray *visibleRestaurants = rd_filter(allRestaurants, ^BOOL(Restaurant *r) {
        return (r.coordinate.latitude >= minLatitude &&
                r.coordinate.latitude <= maxLatitude &&
                r.coordinate.longitude >= minLongitude &&
                r.coordinate.longitude <= maxLongitude);
    });
    
    if (region.span.latitudeDelta > 0.08 && region.span.longitudeDelta > 0.08) {
        
        [self.map removeAnnotations:rd_filter(self.map.annotations, ^BOOL(id<MKAnnotation> object) {
            return [Restaurant cast:object] || [RestaurantCluster cast:object];
        })];
        
        NSMutableDictionary *annotationsByRoughGridCoordinates = [NSMutableDictionary dictionary];
        for (Restaurant *restaurant in visibleRestaurants) {
            CGFloat x = 10 * restaurant.coordinate.longitude / region.span.longitudeDelta;
            CGFloat y = 10 * restaurant.coordinate.latitude / region.span.latitudeDelta;
            NSString *roughGridCoordinate = [NSString stringWithFormat:@"%.0f,%.0f", x, y];
            NSArray *annotations = annotationsByRoughGridCoordinates[roughGridCoordinate] ?: @[];
            annotationsByRoughGridCoordinates[roughGridCoordinate] = [annotations arrayByAddingObject:restaurant];
        }
        
        for (NSArray *annotations in annotationsByRoughGridCoordinates.allValues) {
            if (annotations.count == 1) {
                [self.map addAnnotations:annotations];
            } else {
                RestaurantCluster *cluster = [RestaurantCluster clusterWithRestaurants:annotations];
                [self.map addAnnotation:cluster];
            }
        }

    } else {
        
        [self.map removeAnnotations:rd_filter(self.map.annotations, ^BOOL(id<MKAnnotation> object) {
            return [RestaurantCluster cast:object] != nil;
        })];
        
        NSArray *existingAnnotations = self.map.annotations;
        for (Restaurant *restaurant in visibleRestaurants) {
            if (![existingAnnotations containsObject:restaurant]) {
                [self.map addAnnotation:restaurant];
            }
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self reloadData];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.pinButton.alpha = 1;
    }];
}

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
    if ([Restaurant cast:annotation] || [RestaurantCluster cast:annotation]) {
        
        NSString *cellId = @"RestaurantView";
        MKAnnotationView *restaurantView = [mapView dequeueReusableAnnotationViewWithIdentifier:cellId];
        
        if (restaurantView == nil) {
            
            restaurantView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:cellId];
            restaurantView.frame = CGRectMake(0, 0, 14, 22);
            restaurantView.canShowCallout = YES;
            restaurantView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            UILabel *restaurantLabel = [[UILabel alloc] init];
            restaurantLabel.frame = CGRectInset(restaurantView.bounds, 2, 0);
            restaurantLabel.font = [UIFont boldSystemFontOfSize:8];
            restaurantLabel.minimumScaleFactor = 0.4;
            restaurantLabel.adjustsFontSizeToFitWidth = YES;
            restaurantLabel.textColor = [UIColor whiteColor];
            restaurantLabel.textAlignment = NSTextAlignmentCenter;
            restaurantLabel.backgroundColor = [UIColor clearColor];
            restaurantLabel.tag = kRestaurantLabelTag;
            [restaurantView addSubview:restaurantLabel];
            
        } else {
            
            restaurantView.annotation = annotation;
        }
        
        UILabel *restaurantLabel = (UILabel *) [restaurantView viewWithTag:kRestaurantLabelTag];
        
        if ([Restaurant cast:annotation]) {
            
            Restaurant *restaurant = (Restaurant *) annotation;
            if (restaurant.isOpen) {
                restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-open-star" : @"pin-open"];
            } else if (restaurant.isAlreadyClosed) {
                restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-closed-star" : @"pin-closed"];
            } else {
                restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-generic-star" : @"pin-generic"];
            }
            restaurantLabel.text = nil;
            
        } else if ([RestaurantCluster cast:annotation]) {
            
            RestaurantCluster *cluster = (RestaurantCluster *) annotation;
            restaurantView.image = [UIImage imageNamed:(cluster.isAlreadyClosed) ? @"pin-closed" : @"pin-generic"];
            restaurantLabel.text = [NSString stringWithFormat:@"%ld", (long) cluster.restaurants.count];
        }
        
        return restaurantView;
    }
    
    if ([Pin cast:annotation]) {
        return [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([Restaurant cast:view.annotation] || [RestaurantCluster cast:view.annotation]) {
        view.alpha = 1;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([Restaurant cast:view.annotation] || [RestaurantCluster cast:view.annotation]) {
        view.alpha = 0.7;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([Restaurant cast:view.annotation]) {
        
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

@end

CLLocationDistance distanceFromLatitudeDelta(CLLocationDegrees delta) {
    return (delta * 111000);
}