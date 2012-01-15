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
#import "RestaurantDataProvider.h"
#import "SplashViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, RestaurantDataProviderDelegate> {

    NSArray *restaurants;
    BOOL updatedToUserLocation;
    RestaurantDataProvider *dataProvider;
    SplashViewController *splashController;
}

@property (nonatomic, strong) IBOutlet MKMapView *map;

@property (strong) NSArray *restaurants;

- (IBAction)focusOnUserLocation;

@end
