//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@dynamic openingDateText, openingHoursText, openingHoursAndMinutesText, distanceText, isOpen, isAlreadyClosed, favorite;

+ (Restaurant *)restaurantFromDict:(NSDictionary *)dict
{
    Restaurant *restaurant = [[Restaurant alloc] init];
    
    restaurant.id = [dict stringForKey:@"id"];
    restaurant.name = [dict stringForKey:@"name"];
    
    restaurant.address = [dict stringForKey:@"address"];
    NSUInteger commaLocation = [restaurant.address rangeOfString:@","].location;
    if (commaLocation != NSNotFound) {
        restaurant.address = [restaurant.address substringToIndex:commaLocation];
    }
    restaurant.fullAddress = [dict stringForKey:@"address"];
    NSUInteger countryLocation = [restaurant.fullAddress rangeOfString:@", Finland"].location;
    if (countryLocation != NSNotFound) {
        restaurant.fullAddress = [restaurant.fullAddress substringToIndex:countryLocation];
    }
    
    NSDictionary *coordinateDict = [dict dictionaryForKey:@"coordinates"];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [coordinateDict doubleForKey:@"latitude"];
    coordinate.longitude = [coordinateDict doubleForKey:@"longitude"];
    restaurant.coordinate = coordinate;
    
    restaurant.type = [dict arrayForKey:@"type"];
    
    NSDictionary *openingTimesDict = [dict dictionaryForKey:@"openingTimes"];
    NSInteger openingUnixtime = [openingTimesDict integerForKey:@"start"];
    NSInteger closingUnixtime = [openingTimesDict integerForKey:@"end"];
    
    restaurant.openingTime = [NSDate dateWithTimeIntervalSince1970:openingUnixtime];
    restaurant.closingTime = [NSDate dateWithTimeIntervalSince1970:closingUnixtime];
    
    NSDateFormatter *secondsFormatter = [NSDateFormatter dateFormatterWithFormat:@"A"];
    restaurant.openingSeconds = [[secondsFormatter stringFromDate:restaurant.openingTime] intValue] / 1000;
    restaurant.closingSeconds = [[secondsFormatter stringFromDate:restaurant.closingTime] intValue] / 1000;
    
    NSLog(@"%@ %ld -> %ld", restaurant.name, (long) restaurant.openingSeconds, (long) restaurant.closingSeconds);
    
    if (restaurant.closingSeconds < 3 * 60 * 60) {
        restaurant.closingSeconds += 24 * 60 * 60;
    }
    
    restaurant.capacity = [dict stringForKey:@"capacity"];
    
    restaurant.shortDesc = [dict stringForKey:@"shortDescription"];
    
//    for (NSString *favoriteId in favoriteRestaurants) {
//        if ([favoriteId isEqualToString:restaurant.id]) {
//            restaurant.favorite = YES;
//            // NSLog(@"faivorit!");
//            break;
//        }
//    }
    
    return restaurant;
}

+ (NSArray *)restaurantsFromArrayOfDicts:(NSArray *)dicts
{
    return rd_map(dicts, ^Restaurant *(NSDictionary *dict, NSInteger _) {
        return [self restaurantFromDict:dict];
    });
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    if (self.openingHoursAndMinutesText == nil) return nil;
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

- (BOOL)favorite
{
    return favorite;
}

- (void)setFavorite:(BOOL)isFavorite
{
    if (favorite == isFavorite) {
        return;
    }
    
    favorite = isFavorite;
    
    if (favorite) {
        // [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteAdded object:self];
    } else {
        // [[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteRemoved object:self];
    }
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