//
//  CompanyViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantViewController.h"
#import "RestaurantMapViewController.h"

@implementation RestaurantViewController
@synthesize restaurantNameLabel;
@synthesize restaurantShortDescLabel;
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Star" style:UIBarButtonItemStyleDone target:self action:@selector(favoriteButtonPressed)];
    if (restaurant.favorite) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Unstar"];
    }
    
    restaurantNameLabel.text = restaurant.name;
    restaurantShortDescLabel.text = restaurant.shortDesc;
}

- (void)viewDidUnload {
    
    [self setMapView:nil];
    [self setRestaurantNameLabel:nil];
    [self setRestaurantShortDescLabel:nil];
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

- (IBAction)mapButtonPressed:(id)sender {
    RestaurantMapViewController *viewController = [[RestaurantMapViewController alloc] init];
    viewController.restaurant = restaurant;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
