//
//  RestaurantMapViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantMapViewController.h"
#import "UIView+Extras.h"

@implementation RestaurantMapViewController

@synthesize restaurant, displayRestaurant;

- (void)loadView
{
    self.view = [[MKMapView alloc] init];
    self.title = NSLocalizedString(@"Restaurant.LocationMap.Title", @"");
    displayRestaurant = [[Restaurant alloc] init];
    displayRestaurant.name = restaurant.address;
    displayRestaurant.coordinate = restaurant.coordinate;
    [((MKMapView *)self.view) addAnnotation:displayRestaurant];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = restaurant.name;
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width = 160;
    titleView.height = 44;
    titleView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    UILabel *titleNameLabel = [[UILabel alloc] init];
    titleNameLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    titleNameLabel.x = 0;
    titleNameLabel.y = 0;
    titleNameLabel.width = 160;
    titleNameLabel.height = 44;
    titleNameLabel.text = restaurant.name;
    titleNameLabel.textColor = [UIColor whiteColor];
    titleNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
    titleNameLabel.minimumFontSize = 13.0f;
    titleNameLabel.adjustsFontSizeToFitWidth = YES;
    titleNameLabel.textAlignment = UITextAlignmentCenter;
    titleNameLabel.numberOfLines = 2;
    [titleView addSubview:titleNameLabel];
    self.navigationItem.titleView = titleView;
        
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    
    MKMapView *mapView = (MKMapView *)self.view;
    mapView.mapType = MKMapTypeHybrid;
    mapView.showsUserLocation = YES;
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.01f, 0.01f))];
    [mapView setSelectedAnnotations:[NSArray arrayWithObject:displayRestaurant]];
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
