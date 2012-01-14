//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize name, restaurantId, coordinate, address, shortDesc, openingTime, openingSeconds, closingTime, closingSeconds, type, distance, favorite;

@dynamic openingHoursText, openingHoursAndMinutesText, distanceText, isOpen, isAlreadyClosed;

- (NSString *)title
{
    return name;
}

- (NSString *)subtitle
{
    return self.openingHoursAndMinutesText;
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
    } else {
        return [NSString stringWithFormat:@"%.1f km", distance/1000];
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

@end
