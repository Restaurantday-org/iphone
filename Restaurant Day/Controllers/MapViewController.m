//
//  FirstViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "MapViewController.h"
#import "Restaurant.h"

@implementation MapViewController

@synthesize map;

@dynamic restaurants;

- (void)viewDidLoad
{
    map.delegate = self;
    map.showsUserLocation = YES;
    
    updatedToUserLocation = NO;
}

- (void)viewDidUnload {
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
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Restaurant class]]) {
        
        static NSString *restaurantViewId = @"RestaurantView";
        MKPinAnnotationView *restaurantView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:restaurantViewId];
        if (restaurantView == nil) {
            restaurantView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:restaurantViewId];
            restaurantView.canShowCallout = YES;
        } else {
            restaurantView.annotation = annotation;
        }
        return restaurantView;
    }
    
    return nil;
}

@end
