//
//  RestaurantParser.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantParser : NSObject

- (NSArray *)createArrayFromRestaurantJson:(NSString *)json;

@end
