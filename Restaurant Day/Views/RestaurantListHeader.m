//
//  RestaurantListHeader.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantListHeader.h"

@implementation RestaurantListHeader

+ (RestaurantListHeader *)newInstance
{
    NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"RestaurantListHeader_iPhone" : @"RestaurantListHeader_iPad";
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    if (nibs.count > 0) {
        return [nibs objectAtIndex:0];
    }
    return nil;
}

@end
