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
#import "RestaurantDataProvider.h"

@interface RestaurantViewController : UIViewController {
    RestaurantDataProvider *dataProvider;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) Restaurant *restaurant;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantShortDescLabel;
- (IBAction)mapButtonPressed:(id)sender;

@end
