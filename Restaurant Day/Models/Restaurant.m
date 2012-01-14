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

@dynamic openingHoursText, distanceText;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Restaurant: %@", name];
}

- (NSString *)title
{
    return name;
}

- (NSString *)subtitle
{
    return self.openingHoursText;
}

- (NSString *)openingHoursText
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
    }
    
    return [NSString stringWithFormat:@"%@-%@", [formatter stringFromDate:openingTime], [formatter stringFromDate:closingTime]];
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

@end
