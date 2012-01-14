//
//  Restaurant.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Restaurant : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger restaurantId;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *openingTime;
@property (nonatomic, assign) NSInteger openingSeconds;
@property (nonatomic, strong) NSDate *closingTime;
@property (nonatomic, assign) NSInteger closingSeconds;
@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, unsafe_unretained) BOOL favorite;

@end
