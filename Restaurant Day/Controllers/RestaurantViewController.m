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
    dataProvider = [[RestaurantDataProvider alloc] init];
    [mapView setCenterCoordinate:restaurant.coordinate];
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.002f, 0.002f))];
    [mapView addAnnotation:restaurant];
    mapView.userInteractionEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Star" style:UIBarButtonItemStyleDone target:self action:@selector(favoriteButtonPressed)];
    if (restaurant.favorite) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Unstar"];
    }
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)favoriteButtonPressed
{
    if (restaurant.favorite) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Star"];
        [dataProvider unfavoriteRestaurant:[NSNumber numberWithInt:restaurant.restaurantId]];
        restaurant.favorite = NO;
    } else {
        [self.navigationItem.rightBarButtonItem setTitle:@"Unstar"];
        [dataProvider favoriteRestaurant:[NSNumber numberWithInt:restaurant.restaurantId]];
        restaurant.favorite = YES;
    }
}

@end
