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
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSArray *parsedData = [[parser objectWithString:json] objectForKey:@"restaurants"];
    
    for (NSDictionary *restaurantDict in parsedData) {
        Restaurant *restaurant = [[Restaurant alloc] init];
        restaurant.name = [restaurantDict objectForKey:@"name"];
        restaurant.address = [restaurantDict objectForKey:@"address"];
        restaurant.restaurantId = [[restaurantDict objectForKey:@"id"] intValue];
        NSDictionary *coordinateDict = [restaurantDict objectForKey:@"coordinates"];
        restaurant.coordinates = CLLocationCoordinate2DMake([[coordinateDict objectForKey:@"latitude"] floatValue], [[coordinateDict objectForKey:@"longitude"] floatValue]);
        restaurant.type = [restaurantDict objectForKey:@"type"];
        restaurant.venue = [restaurantDict objectForKey:@"venue"];
        restaurant.openingSeconds = [[[restaurantDict objectForKey:@"openingTimes"] objectForKey:@"start"] intValue];
        restaurant.closingSeconds = [[[restaurantDict objectForKey:@"openingTimes"] objectForKey:@"end"] intValue];
        
        [returnArray addObject:restaurant];
        NSLog(@"rest: %@", restaurant);
    }
    
    return returnArray;
}

@end
