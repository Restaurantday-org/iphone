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
    
    CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(60.1695, 24.9388);
    [map setRegion:MKCoordinateRegionMakeWithDistance(defaultCoordinate, 4000, 4000) animated:NO];
    
    updatedToUserLocation = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:kFavoriteAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteRemoved:) name:kFavoriteRemoved object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = [[UIView alloc] init];    
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

- (void)favoriteAdded:(NSNotification *)notification
{
    Restaurant *restaurant = (Restaurant *) notification.object;
    [map removeAnnotation:restaurant];
    [map addAnnotation:restaurant];
}

- (void)favoriteRemoved:(NSNotification *)notification
{
    Restaurant *restaurant = (Restaurant *) notification.object;
    [map removeAnnotation:restaurant];
    [map addAnnotation:restaurant];
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
