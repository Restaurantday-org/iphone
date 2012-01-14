//
//  RestaurantListHeader.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantListHeader.h"

@implementation RestaurantListHeader

- (id)init {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"RestaurantListHeader" owner:self options:nil];
    if (nibs.count > 0) {
        self = [nibs objectAtIndex:0];
    }
    return self;
}

@end
