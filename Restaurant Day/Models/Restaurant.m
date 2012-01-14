//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize name, restaurantId, coordinate, address, description, openingTime, openingSeconds, closingTime, closingSeconds, type, distanceText, favorite;

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
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
    }
    
    return [NSString stringWithFormat:@"%@-%@", [formatter stringFromDate:openingTime], [formatter stringFromDate:closingTime]];
}

- (void)updateDistanceTextWithLocation:(CLLocation *)location
{
    CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    CLLocationDistance distance = [restaurantLocation distanceFromLocation:location];
    if (distance < 100) {
        distance = (((int) distance) / 10) * 10;
        self.distanceText = [NSString stringWithFormat:@"%.0f m", distance];
    } else {
        self.distanceText = [NSString stringWithFormat:@"%.1f km", distance/1000];
    }
}

@end
