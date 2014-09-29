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

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *fullAddress;
@property (nonatomic, copy) NSString *shortDesc;
@property (nonatomic) NSDate *openingTime;
@property (nonatomic, assign) NSInteger openingSeconds;
@property (nonatomic) NSDate *closingTime;
@property (nonatomic, assign) NSInteger closingSeconds;
@property (nonatomic, copy) NSArray *type;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, copy) NSString *capacity;

@property (nonatomic, readonly) NSString *openingDateText;
@property (nonatomic, readonly) NSString *openingHoursText;
@property (nonatomic, readonly) NSString *openingHoursAndMinutesText;
@property (nonatomic, readonly) NSString *distanceText;

@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic, readonly) BOOL isAlreadyClosed;

+ (Restaurant *)restaurantFromMaplantisDict:(NSDictionary *)dict;
+ (NSArray *)restaurantsFromArrayOfMaplantisDicts:(NSArray *)dicts;

- (void)updateDistanceWithLocation:(CLLocation *)location;

NSComparisonResult compareRestaurantsByName(id restaurant1, id restaurant2, void *context);
NSComparisonResult compareRestaurantsByDistance(id restaurant1, id restaurant2, void *context);
NSComparisonResult compareRestaurantsByOpeningTime(id restaurant1, id restaurant2, void *context);

@end