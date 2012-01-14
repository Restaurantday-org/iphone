//
//  CompanyViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantViewController.h"

@implementation RestaurantViewController
@synthesize mapView, restaurant;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [mapView setCenterCoordinate:restaurant.coordinate];
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.002f, 0.002f))];
    [mapView addAnnotation:restaurant];
    mapView.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = restaurant.name;
}

- (void)viewDidUnload {
    
    [self setMapView:nil];
    [super viewDidUnload];
}

@end
