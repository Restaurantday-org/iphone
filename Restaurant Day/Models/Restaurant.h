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

@interface Restaurant : NSObject <MKAnnotation> {

    BOOL favorite;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSString *restaurantId;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *fullAddress;
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, strong) NSDate *openingTime;
@property (nonatomic, assign) NSInteger openingSeconds;
@property (nonatomic, strong) NSDate *closingTime;
@property (nonatomic, assign) NSInteger closingSeconds;
@property (nonatomic, strong) NSArray *type;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, strong) NSString *capacity;

@property (readonly) NSString *openingDateText;
@property (readonly) NSString *openingHoursText;
@property (readonly) NSString *openingHoursAndMinutesText;
@property (readonly) NSString *distanceText;

@property (readonly) BOOL isOpen;
@property (readonly) BOOL isAlreadyClosed;

+ (NSArray *)restaurantsFromJson:(NSString *)json;

- (void)updateDistanceWithLocation:(CLLocation *)location;

NSComparisonResult compareRestaurantsByName(id restaurant1, id restaurant2, void *context);
NSComparisonResult compareRestaurantsByDistance(id restaurant1, id restaurant2, void *context);
NSComparisonResult compareRestaurantsByOpeningTime(id restaurant1, id restaurant2, void *context);

@end
