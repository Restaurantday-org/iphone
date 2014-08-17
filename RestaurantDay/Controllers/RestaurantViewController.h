//
//  RestaurantViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

#import "Restaurant.h"
#import "RestaurantsDataSource.h"

#import "GAI.h"

@interface RestaurantViewController : GAITrackedViewController

@property (nonatomic) Restaurant *restaurant;
@property (nonatomic, weak) id <RestaurantsDataSource> dataSource;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UILabel *restaurantShortDescLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantAddressLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantCategoriesLabel;
@property (nonatomic, weak) IBOutlet UIView *lowerContent;

@property (nonatomic, weak) IBOutlet UIImageView *mapBoxShadowView;

- (IBAction)mapButtonPressed:(id)sender;

@end
