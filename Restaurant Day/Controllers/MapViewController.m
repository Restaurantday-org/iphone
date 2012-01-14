//
//  FirstViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "MapViewController.h"
#import "Restaurant.h"
#import "RestaurantViewController.h"

@implementation MapViewController

@synthesize map;

@dynamic restaurants;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    map.delegate = self;
    map.showsUserLocation = YES;
    
    updatedToUserLocation = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = [[UIView alloc] init];
    
    [map removeAnnotations:map.annotations];
    [map addAnnotations:restaurants];
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

- (void)setRestaurants:(NSArray *)newRestaurants
{
    restaurants = newRestaurants;
    
    if (map.userLocation != nil) {
        for (Restaurant *restaurant in restaurants) {
            [restaurant updateDistanceWithLocation:map.userLocation.location];
        }
    }
        
    [map removeAnnotations:map.annotations];
    [map addAnnotations:newRestaurants];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!updatedToUserLocation) {
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000) animated:YES];
        updatedToUserLocation = YES;
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
            restaurantView.canShowCallout = YES;
            restaurantView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            restaurantView.annotation = annotation;
        }
        
        Restaurant *restaurant = (Restaurant *) annotation;
        if (restaurant.isOpen) {
            restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-open-star" : @"pin-open"];
        } else if (restaurant.isAlreadyClosed) {
            restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-closed-star" : @"pin-closed"];
        } else {
            restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-generic-star" : @"pin-generic"];
        }
                
        return restaurantView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[Restaurant class]]) {
        RestaurantViewController *restaurantViewController = [[RestaurantViewController alloc] init];
        restaurantViewController.restaurant = view.annotation;
        [self.navigationController pushViewController:restaurantViewController animated:YES];
    }
}

@end
