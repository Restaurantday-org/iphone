//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize name, restaurantId, coordinate, address, shortDesc, openingTime, openingSeconds, closingTime, closingSeconds, type, favorite;

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
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
    }
    
    return [NSString stringWithFormat:@"%@-%@", [formatter stringFromDate:openingTime], [formatter stringFromDate:closingTime]];
}

@end
