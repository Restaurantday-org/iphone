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

@interface MapViewController : UIViewController <MKMapViewDelegate> {

    NSArray *restaurants;
    BOOL updatedToUserLocation;
}

@property (nonatomic, strong) IBOutlet MKMapView *map;

@property (strong) NSArray *restaurants;

@end
