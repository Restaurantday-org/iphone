//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize name, restaurantId, coordinates, address, description, openingTime, openingSeconds, closingTime, closingSeconds, venue, type;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Restaurant: %@", name];
}

@end
