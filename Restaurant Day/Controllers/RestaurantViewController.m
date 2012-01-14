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

@synthesize restaurant;

@synthesize mapView;

@synthesize restaurantAddressLabel;
@synthesize restaurantSubtitle;
@synthesize restaurantNameLabel;
@synthesize restaurantShortDescLabel;
@synthesize scrollView;

@synthesize mapBoxShadowView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataProvider = [[RestaurantDataProvider alloc] init];
    
    [mapView setCenterCoordinate:restaurant.coordinate];
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.002f, 0.002f))];
    [mapView addAnnotation:restaurant];
    mapView.userInteractionEnabled = NO;
    scrollView.alwaysBounceVertical = YES;
    
    restaurantNameLabel.text = restaurant.name;
    restaurantShortDescLabel.text = restaurant.shortDesc;
    restaurantAddressLabel.text = restaurant.fullAddress;
    restaurantSubtitle.text = restaurant.subtitle;
    
    mapBoxShadowView.image = [[UIImage imageNamed:@"box-shadow"] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(favoriteButtonPressed)];
    if (restaurant.favorite) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-full"];
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-empty"];
    }
}

- (void)viewDidUnload {
    
    [self setMapView:nil];
    [self setRestaurantNameLabel:nil];
    [self setRestaurantShortDescLabel:nil];
    [self setScrollView:nil];
    [self setRestaurantAddressLabel:nil];
    [self setRestaurantSubtitle:nil];
    [super viewDidUnload];
}

- (void)favoriteButtonPressed
{
    if (restaurant.favorite) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-empty"];
        [dataProvider unfavoriteRestaurant:[NSNumber numberWithInt:restaurant.restaurantId]];
        restaurant.favorite = NO;
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-full"];
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
