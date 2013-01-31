//
//  FirstViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKMapView.h>
#import "RestaurantsDataSource.h"
#import "RestaurantDayViewController.h"
#import "GAI.h"

@interface MapViewController : GAITrackedViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, weak) IBOutlet UIButton *pinButton;
@property (nonatomic, weak) IBOutlet UIButton *locateButton;

@property (nonatomic, strong) RestaurantDayViewController *splashViewer;

@property (nonatomic, weak) id<RestaurantsDataSource> dataSource;

- (void)reloadData;
- (void)reloadViewForRestaurant:(Restaurant *)restaurant;

- (IBAction)focusOnUserLocation;
- (IBAction)repositionPin;

@end
