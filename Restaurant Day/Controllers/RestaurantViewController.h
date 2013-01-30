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
#import "RestaurantDetailDataProvider.h"
#import "GAI.h"

@interface RestaurantViewController : GAITrackedViewController <UIWebViewDelegate, RestaurantDetailDataProviderDelegate> {
    RestaurantDataProvider *dataProvider;
    RestaurantDetailDataProvider *detailDataProvider;
}

@property (strong, nonatomic) Restaurant *restaurant;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *restaurantShortDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantCategoriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantDistanceLabel;
@property (weak, nonatomic) IBOutlet UIView *lowerContent;

@property (weak, nonatomic) IBOutlet UIImageView *mapBoxShadowView;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

- (IBAction)mapButtonPressed:(id)sender;

@end
