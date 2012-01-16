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

@interface RestaurantViewController : UIViewController <UIWebViewDelegate, RestaurantDetailDataProviderDelegate> {
    RestaurantDataProvider *dataProvider;
    RestaurantDetailDataProvider *detailDataProvider;
}

@property (strong, nonatomic) Restaurant *restaurant;

@property (unsafe_unretained, nonatomic) IBOutlet MKMapView *mapView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantShortDescLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantAddressLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantSubtitle;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *mapBoxShadowView;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webview;

- (IBAction)mapButtonPressed:(id)sender;

@end
