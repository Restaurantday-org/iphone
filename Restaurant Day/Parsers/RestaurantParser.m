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
#import "NSDictionary+Parsing.h"

@implementation RestaurantParser

- (NSArray *)createArrayFromRestaurantJson:(NSString *)json
{
    NSArray *favoriteRestaurants = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteRestaurants"];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSArray *parsedData = [[parser objectWithString:json] objectOrNilForKey:@"restaurants"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    for (NSDictionary *restaurantDict in parsedData) {
        NSLog(@"%@", restaurantDict);
        Restaurant *restaurant = [[Restaurant alloc] init];
        restaurant.name = [restaurantDict objectOrNilForKey:@"name"];
        restaurant.address = [restaurantDict objectOrNilForKey:@"address"];
        NSUInteger commaLocation = [restaurant.address rangeOfString:@","].location;
        if (commaLocation != NSNotFound) {
            restaurant.address = [restaurant.address substringToIndex:commaLocation];
        }
        restaurant.fullAddress = [restaurantDict objectOrNilForKey:@"address"];
        NSUInteger  countryLocation = [restaurant.fullAddress rangeOfString:@", Finland"].location;
        if (countryLocation != NSNotFound) {
            restaurant.fullAddress = [restaurant.fullAddress substringToIndex:countryLocation];
        }
        restaurant.restaurantId = [[restaurantDict objectOrNilForKey:@"id"] intValue];
        NSDictionary *coordinateDict = [restaurantDict objectOrNilForKey:@"coordinates"];
        restaurant.coordinate = CLLocationCoordinate2DMake([[coordinateDict objectOrNilForKey:@"latitude"] floatValue], [[coordinateDict objectOrNilForKey:@"longitude"] floatValue]);
        restaurant.type = [restaurantDict objectOrNilForKey:@"type"];
        
        NSInteger openingUnixtime = [[[restaurantDict objectOrNilForKey:@"openingTimes"] objectOrNilForKey:@"start"] intValue];
        NSInteger closingUnixtime = [[[restaurantDict objectOrNilForKey:@"openingTimes"] objectOrNilForKey:@"end"] intValue];
        
        restaurant.price = [restaurantDict objectOrNilForKey:@"typicalPrice"];
        restaurant.capacity = [restaurantDict objectOrNilForKey:@"capacity"];
        
        restaurant.openingTime = [NSDate dateWithTimeIntervalSince1970:openingUnixtime];
        restaurant.closingTime = [NSDate dateWithTimeIntervalSince1970:closingUnixtime];
        
        NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
        [secondFormatter setDateFormat:@"A"];
        restaurant.openingSeconds = [[secondFormatter stringFromDate:restaurant.openingTime] intValue] / 1000;
        restaurant.closingSeconds = [[secondFormatter stringFromDate:restaurant.closingTime] intValue] / 1000;
        
        if (restaurant.closingSeconds < 3*60*60) {
            restaurant.closingSeconds += 24*60*60;
        }
        
        restaurant.shortDesc = [restaurantDict objectOrNilForKey:@"shortDescription"];
        
        for (NSNumber *favoriteId in favoriteRestaurants) {
            if ([favoriteId intValue] == restaurant.restaurantId) {
                restaurant.favorite = YES;
                NSLog(@"faivorit!");
                break;
            }
        }
        
        if (restaurant.name == nil) restaurant.name = @"";
        if (restaurant.address == nil) restaurant.address = @"";
        if (restaurant.fullAddress == nil) restaurant.fullAddress = @"";
        if ([restaurant.shortDesc isKindOfClass:[NSNull class]]) restaurant.shortDesc = @"";
        
        restaurant.distance = [[restaurantDict objectOrNilForKey:@"distanceTo"] doubleValue];
        
        [returnArray addObject:restaurant];
    }
    
    return returnArray;
}

@end
