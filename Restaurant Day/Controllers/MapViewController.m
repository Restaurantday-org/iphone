//
//  FirstViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController
@synthesize mapView;

- (void)viewDidLoad
{
    mapView.delegate = self;
    mapView.userTrackingMode = MKUserTrackingModeFollow;
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

@end
