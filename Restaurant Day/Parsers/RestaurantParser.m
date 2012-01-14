//
//  RestaurantParser.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantParser.h"
#import "SBJson.h"
#import "Restaurant.h"

@implementation RestaurantParser

- (NSArray *)createArrayFromRestaurantJson:(NSString *)json
{
    NSArray *favoriteRestaurants = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteRestaurants"];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSArray *parsedData = [[parser objectWithString:json] objectForKey:@"restaurants"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    for (NSDictionary *restaurantDict in parsedData) {
        Restaurant *restaurant = [[Restaurant alloc] init];
        restaurant.name = [restaurantDict objectForKey:@"name"];
        restaurant.address = [restaurantDict objectForKey:@"address"];
        NSUInteger commaLocation = [restaurant.address rangeOfString:@","].location;
        if (commaLocation != NSNotFound) {
            restaurant.address = [restaurant.address substringToIndex:commaLocation];
        }
        restaurant.restaurantId = [[restaurantDict objectForKey:@"id"] intValue];
        NSDictionary *coordinateDict = [restaurantDict objectForKey:@"coordinates"];
        restaurant.coordinate = CLLocationCoordinate2DMake([[coordinateDict objectForKey:@"latitude"] floatValue], [[coordinateDict objectForKey:@"longitude"] floatValue]);
        restaurant.type = [restaurantDict objectForKey:@"type"];
        
        NSInteger openingUnixtime = [[[restaurantDict objectForKey:@"openingTimes"] objectForKey:@"start"] intValue];
        NSInteger closingUnixtime = [[[restaurantDict objectForKey:@"openingTimes"] objectForKey:@"end"] intValue];
        
        restaurant.openingSeconds = openingUnixtime%86400 + 7200;
        restaurant.closingSeconds = closingUnixtime%86400 + 7200;

        restaurant.openingTime = [NSDate dateWithTimeIntervalSince1970:openingUnixtime];
        restaurant.closingTime = [NSDate dateWithTimeIntervalSince1970:closingUnixtime];
        
        restaurant.shortDesc = [restaurantDict objectForKey:@"shortDescription"];
        
        for (NSNumber *favoriteId in favoriteRestaurants) {
            if ([favoriteId intValue] == restaurant.restaurantId) {
                restaurant.favorite = YES;
                break;
            }
        }
        
        [returnArray addObject:restaurant];
    }
    
    return returnArray;
}

@end
