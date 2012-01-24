//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize name, restaurantId, coordinate, address, fullAddress, shortDesc, openingTime, openingSeconds, closingTime, closingSeconds, type, distance, price, capacity;

@dynamic openingHoursText, openingHoursAndMinutesText, distanceText, isOpen, isAlreadyClosed, favorite;

- (NSString *)title
{
    return name;
}

- (NSString *)subtitle
{
    if (self.openingHoursAndMinutesText == nil) return nil;
    return self.openingHoursAndMinutesText;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[Restaurant class]]) {
        return (self.restaurantId == [object restaurantId]);
    }
    return NO;
}

- (NSString *)openingHoursText
{
    static NSDateFormatter *hoursFormatter = nil;
    if (hoursFormatter == nil) {
        hoursFormatter = [[NSDateFormatter alloc] init];
        hoursFormatter.dateFormat = @"H";
    }
    
    return [NSString stringWithFormat:@"%@–%@", [hoursFormatter stringFromDate:openingTime], [hoursFormatter stringFromDate:closingTime]];
}

- (NSString *)openingHoursAndMinutesText
{
    if (openingTime == nil && closingTime == nil) return nil;
    static NSDateFormatter *hoursAndMinutesFormatter = nil;
    if (hoursAndMinutesFormatter == nil) {
        hoursAndMinutesFormatter = [[NSDateFormatter alloc] init];
        hoursAndMinutesFormatter.dateFormat = @"HH:mm";
    }
    
    return [NSString stringWithFormat:@"%@-%@", [hoursAndMinutesFormatter stringFromDate:openingTime], [hoursAndMinutesFormatter stringFromDate:closingTime]];
}

- (NSString *)distanceText
{
    if (distance < 100) {
        distance = (((int) distance) / 10) * 10;
        return [NSString stringWithFormat:@"%.0f m", distance];
    } else if (distance < 100000) {
        return [NSString stringWithFormat:@"%.1f km", distance/1000];
    } else {
        return [NSString stringWithFormat:@"%.0f km", distance/1000];
    }
}

- (void)updateDistanceWithLocation:(CLLocation *)location
{
    CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    self.distance = [restaurantLocation distanceFromLocation:location];
}

- (BOOL)isOpen
{
    return [openingTime timeIntervalSinceNow] <= 0 && [closingTime timeIntervalSinceNow] >= 0;
}

- (BOOL)isAlreadyClosed
{
    return [closingTime timeIntervalSinceNow] < 0;
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
        //[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteAdded object:self];
    } else {
        //[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteRemoved object:self];
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
    return [[restaurant1 openingTime] compare:[restaurant2 openingTime]];
}

@end
