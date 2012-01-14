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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    for (NSDictionary *restaurantDict in parsedData) {
        Restaurant *restaurant = [[Restaurant alloc] init];
        restaurant.name = [restaurantDict objectForKey:@"name"];
        restaurant.address = [restaurantDict objectForKey:@"address"];
        restaurant.restaurantId = [[restaurantDict objectForKey:@"id"] intValue];
        NSDictionary *coordinateDict = [restaurantDict objectForKey:@"coordinates"];
        restaurant.coordinate = CLLocationCoordinate2DMake([[coordinateDict objectForKey:@"latitude"] floatValue], [[coordinateDict objectForKey:@"longitude"] floatValue]);
        restaurant.type = [restaurantDict objectForKey:@"type"];
        restaurant.openingSeconds = [[[restaurantDict objectForKey:@"openingTimes"] objectForKey:@"start"] intValue];
        restaurant.closingSeconds = [[[restaurantDict objectForKey:@"openingTimes"] objectForKey:@"end"] intValue];
        NSInteger openingHours = restaurant.openingSeconds/3600;
        NSInteger openingMinutes = (restaurant.openingSeconds/60)-openingHours*60;
        NSString *openingString = [NSString stringWithFormat:@"2012-02-04 %d:%d", openingHours, openingMinutes];
        restaurant.openingTime = [dateFormatter dateFromString:openingString];
        
        NSInteger closingHours = restaurant.closingSeconds/3600;
        NSInteger closingMinutes = (restaurant.closingSeconds/60)-closingHours*60;
        NSString *closingString = [NSString stringWithFormat:@"2012-02-04 %d:%d", closingHours, closingMinutes];
        restaurant.closingTime = [dateFormatter dateFromString:closingString];
        
        [returnArray addObject:restaurant];
    }
    
    return returnArray;
}

@end
