//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

//{
//    "last-edited": "2014-08-05T16:03:47.185Z",
//    "event-map": "53d37cd003648c17ba381ef4",
//    "event-map-name": "August 2014",
//    "org-short-name": "restaurantday",
//    "organization": "53d37cd003648c17ba381ef0",
//    "owner": "53de2858e4b02f9a899f2edb",
//    "owner-name": "annemakinen906",
//    "org-name": "Restaurant Day",
//    "_id": "53e0fd6de4b07a8cb10c3827",
//    "fields": {
//        "date": "2014-08-17",
//        "time-duration": {
//            "start": "2014-08-17T08:00:00.000Z",
//            "end": "2014-08-17T16:00:00.000Z"
//        },
//        "address": "Mikkelintie 29, Anttola, Mikkeli, Suomi",
//        "coordinates": [
//            27.266666999999984,
//            61.683333
//        ],
//        "description": "Kasvispainotteisia herkkuja: keittoa, salaattia, suolaisia ja makeita leivonnaisia, raikkaita juomia.",
//        "title": "Kahvila Kesän Sato"
//    },
//    "tags": []
//}

+ (Restaurant *)restaurantFromMaplantisDict:(NSDictionary *)dict
{
    Restaurant *restaurant = [[Restaurant alloc] init];
    
    restaurant.id = [dict stringForKey:@"_id"];
    
    // restaurant.type = [dict arrayForKey:@"tags"];
    
    NSDictionary *fields = [dict dictionaryForKey:@"fields"];
    
    restaurant.name = [fields stringForKey:@"title"];
    
    NSString *address = [fields stringForKey:@"address"];
    NSArray *addressFields = [address componentsSeparatedByString:@", "];
    restaurant.address = addressFields.firstObject;
    restaurant.fullAddress = address;
    
    NSArray *coordinates = [fields arrayForKey:@"coordinates"];
    if (coordinates.count >= 2) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [coordinates[1] doubleValue];
        coordinate.longitude = [coordinates[0] doubleValue];
        restaurant.coordinate = coordinate;
    }
    
    NSDictionary *timesDict = [fields dictionaryForKey:@"time-duration"];
    restaurant.openingTime = [timesDict dateForKey:@"start"];
    restaurant.closingTime = [timesDict dateForKey:@"end"];
    
    NSDateFormatter *secondsFormatter = [NSDateFormatter dateFormatterWithFormat:@"A"];
    restaurant.openingSeconds = [[secondsFormatter stringFromDate:restaurant.openingTime] intValue] / 1000;
    restaurant.closingSeconds = [[secondsFormatter stringFromDate:restaurant.closingTime] intValue] / 1000;
    
    // NSLog(@"%@ %ld -> %ld", restaurant.name, (long) restaurant.openingSeconds, (long) restaurant.closingSeconds);
    
    if (restaurant.closingSeconds < 3 * 60 * 60) {
        restaurant.closingSeconds += 24 * 60 * 60;
    }
    
    restaurant.shortDesc = [fields stringForKey:@"description"];
    
    return restaurant;
}

+ (NSArray *)restaurantsFromArrayOfMaplantisDicts:(NSArray *)dicts
{
    return rd_map(dicts, ^Restaurant *(NSDictionary *dict, NSInteger _) {
        return [self restaurantFromMaplantisDict:dict];
    });
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.openingHoursAndMinutesText;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[Restaurant class]]) {
        return [self.id isEqual:[object id]];
    }
    return NO;
}

- (NSUInteger)hash
{
    return self.id.hash;
}

- (NSString *)openingDateText
{
    static NSDateFormatter *daysFormatter = nil;
    if (daysFormatter == nil) {
        daysFormatter = [[NSDateFormatter alloc] init];
        daysFormatter.dateFormat = @"d.M.yyyy";
    }
    
    return [daysFormatter stringFromDate:self.openingTime];
}

- (NSString *)openingHoursText
{
    static NSDateFormatter *hoursFormatter = nil;
    if (hoursFormatter == nil) {
        hoursFormatter = [[NSDateFormatter alloc] init];
        hoursFormatter.dateFormat = @"H";
    }

    NSString *openingTimeString = [hoursFormatter stringFromDate:self.openingTime];
    NSString *closingTimeString = [hoursFormatter stringFromDate:self.closingTime];
    if ([closingTimeString isEqualToString:@"0"]) {
        closingTimeString = @"24";
    }

    return [NSString stringWithFormat:@"%@-%@", openingTimeString, closingTimeString];
}

- (NSString *)openingHoursAndMinutesText
{
    if (!self.openingTime && !self.closingTime) return nil;
    
    NSDateFormatter *hoursAndMinutesFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
    NSString *openingTimeString = [hoursAndMinutesFormatter stringFromDate:self.openingTime];
    NSString *closingTimeString = [hoursAndMinutesFormatter stringFromDate:self.closingTime];
    if ([closingTimeString isEqualToString:@"00:00"]) {
        closingTimeString = @"24:00";
    }
    return [NSString stringWithFormat:@"%@-%@", openingTimeString, closingTimeString];
}

- (NSString *)distanceText
{
    if (self.distance < 100) {
        self.distance = (((int) self.distance) / 10) * 10;
        return [NSString stringWithFormat:@"%.0f m", self.distance];
    } else if (self.distance < 100000) {
        return [NSString stringWithFormat:@"%.1f km", self.distance / 1000];
    } else {
        return [NSString stringWithFormat:@"%.0f km", self.distance / 1000];
    }
}

- (void)updateDistanceWithLocation:(CLLocation *)location
{
    CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    self.distance = [restaurantLocation distanceFromLocation:location];
}

- (BOOL)isOpen
{
    return [self.openingTime timeIntervalSinceNow] <= 0 && [self.closingTime timeIntervalSinceNow] >= 0;
}

- (BOOL)isAlreadyClosed
{
    return [self.closingTime timeIntervalSinceNow] < 0;
}

NSComparisonResult compareRestaurantsByName(id restaurant1, id restaurant2, void *context)
{
    return [[restaurant1 name] compare:[restaurant2 name]];
}

NSComparisonResult compareRestaurantsByDistance(id restaurant1, id restaurant2, void *context)
{
    if ([restaurant1 distance] < [restaurant2 distance]) {
        return NSOrderedAscending;
    } else if ([restaurant1 distance] > [restaurant2 distance]) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

NSComparisonResult compareRestaurantsByOpeningTime(id restaurant1, id restaurant2, void *context)
{
    BOOL isAlreadyClosed1 = [restaurant1 isAlreadyClosed];
    BOOL isAlreadyClosed2 = [restaurant2 isAlreadyClosed];
    if (isAlreadyClosed1 != isAlreadyClosed2) {
        return (isAlreadyClosed1 - isAlreadyClosed2);
    }
    
    NSComparisonResult openingTimeResult = [[restaurant1 openingTime] compare:[restaurant2 openingTime]];
    if (openingTimeResult != NSOrderedSame) {
        return openingTimeResult;
    } else {
        return [[restaurant1 closingTime] compare:[restaurant2 closingTime]];
    }
}

@end