//
//  CompanyViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "CompanyViewController.h"

@implementation CompanyViewController
@synthesize mapView, restaurant;

- (void)viewDidLoad
{
    [mapView setCenterCoordinate:restaurant.coordinate];
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.002f, 0.002f))];
    [mapView addAnnotation:restaurant];
    mapView.userInteractionEnabled = NO;
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

@end
