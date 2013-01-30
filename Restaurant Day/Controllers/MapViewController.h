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
#import "RestaurantDayViewController.h"
#import "GAI.h"

@interface MapViewController : GAITrackedViewController <MKMapViewDelegate, RestaurantDataProviderDelegate> {

    NSMutableArray *restaurants;
    BOOL updatedToUserLocation;
    RestaurantDataProvider *dataProvider;
    CLLocation *currentLocation;
    BOOL networkFailureAlertShown;
}

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, strong) RestaurantDayViewController *splashViewer;

@property (strong) NSArray *restaurants;

- (void)addRestaurants:(NSArray *)newRestaurants;
- (IBAction)focusOnUserLocation;

@end
