//
//  RestaurantMapViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantMapViewController.h"

@implementation RestaurantMapViewController

@synthesize restaurant;

- (void)loadView
{
    self.view = [[MKMapView alloc] init];
    [((MKMapView *)self.view) addAnnotation:restaurant];
}

- (void)viewWillAppear:(BOOL)animated
{
    MKMapView *mapView = (MKMapView *)self.view;
    mapView.showsUserLocation = YES;
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.01f, 0.01f))];
}

@end
