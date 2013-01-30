//
//  Restaurant.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant.h"

#import "SBJson.h"
#import "NSDictionary+Parsing.h"

@implementation Restaurant

@synthesize name, restaurantId, coordinate, address, fullAddress, shortDesc, openingTime, openingSeconds, closingTime, closingSeconds, type, distance, capacity;

@dynamic openingDateText, openingHoursText, openingHoursAndMinutesText, distanceText, isOpen, isAlreadyClosed, favorite;

+ (NSArray *)restaurantsFromJson:(NSString *)json
{
    NSArray *favoriteRestaurants = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteRestaurants"];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSArray *parsedData = [[parser objectWithString:json] objectOrNilForKey:@"restaurants"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
    [secondFormatter setDateFormat:@"A"];
    
    for (NSDictionary *restaurantDict in parsedData) {
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
        restaurant.restaurantId = [restaurantDict objectOrNilForKey:@"id"];
        NSDictionary *coordinateDict = [restaurantDict objectOrNilForKey:@"coordinates"];
        restaurant.coordinate = CLLocationCoordinate2DMake([[coordinateDict objectOrNilForKey:@"latitude"] floatValue], [[coordinateDict objectOrNilForKey:@"longitude"] floatValue]);
        restaurant.type = [restaurantDict objectOrNilForKey:@"type"];
        
        NSInteger openingUnixtime = [[[restaurantDict objectOrNilForKey:@"openingTimes"] objectOrNilForKey:@"start"] intValue];
        NSInteger closingUnixtime = [[[restaurantDict objectOrNilForKey:@"openingTimes"] objectOrNilForKey:@"end"] intValue];
        
        restaurant.capacity = [restaurantDict objectOrNilForKey:@"capacity"];
        
        restaurant.openingTime = [NSDate dateWithTimeIntervalSince1970:openingUnixtime];
        restaurant.closingTime = [NSDate dateWithTimeIntervalSince1970:closingUnixtime];
        
        restaurant.openingSeconds = [[secondFormatter stringFromDate:restaurant.openingTime] intValue] / 1000;
        restaurant.closingSeconds = [[secondFormatter stringFromDate:restaurant.closingTime] intValue] / 1000;
        
        // NSLog(@"%@ %d -> %d", restaurant.name, restaurant.openingSeconds, restaurant.closingSeconds);
        
        if (restaurant.closingSeconds < 3*60*60) {
            restaurant.closingSeconds += 24*60*60;
        }
        
        restaurant.shortDesc = [restaurantDict objectOrNilForKey:@"shortDescription"];
        
        for (NSString *favoriteId in favoriteRestaurants) {
            if ([favoriteId isEqualToString:restaurant.restaurantId]) {
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

- (NSString *)title
{
    return name;
}

- (NSString *)subtitle
{
    if (self.openingHoursAndMinutesText == nil) return nil;
    return self.openingHoursAndMinutesText;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[Restaurant class]]) {
        return [self.restaurantId isEqual:[object restaurantId]];
    }
    return NO;
}

- (NSString *)openingDateText
{
    static NSDateFormatter *daysFormatter = nil;
    if (daysFormatter == nil) {
        daysFormatter = [[NSDateFormatter alloc] init];
        daysFormatter.dateFormat = @"d.M.yyyy";
    }
    
    return [daysFormatter stringFromDate:openingTime];
}

- (NSString *)openingHoursText
{
    static NSDateFormatter *hoursFormatter = nil;
    if (hoursFormatter == nil) {
        hoursFormatter = [[NSDateFormatter alloc] init];
        hoursFormatter.dateFormat = @"H";
    }

    NSString *openingTimeString = [hoursFormatter stringFromDate:openingTime];
    NSString *closingTimeString = [hoursFormatter stringFromDate:closingTime];
    if ([closingTimeString isEqualToString:@"0"]) {
        closingTimeString = @"24";
    }

    return [NSString stringWithFormat:@"%@-%@", openingTimeString, closingTimeString];
}

- (NSString *)openingHoursAndMinutesText
{
    if (openingTime == nil && closingTime == nil) return nil;
    static NSDateFormatter *hoursAndMinutesFormatter = nil;
    if (hoursAndMinutesFormatter == nil) {
        hoursAndMinutesFormatter = [[NSDateFormatter alloc] init];
        hoursAndMinutesFormatter.dateFormat = @"HH:mm";
    }
    
    NSString *openingTimeString = [hoursAndMinutesFormatter stringFromDate:openingTime];
    NSString *closingTimeString = [hoursAndMinutesFormatter stringFromDate:closingTime];
    if ([closingTimeString isEqualToString:@"00:00"]) {
        closingTimeString = @"24:00";
    }
    return [NSString stringWithFormat:@"%@-%@", openingTimeString, closingTimeString];
}

- (NSString *)distanceText
{
    if (distance < 100) {
        distance = (((int) distance) / 10) * 10;
        return [NSString stringWithFormat:@"%.0f m", distance];
    } else if (distance < 100000) {
        return [NSString stringWithFormat:@"%.1f km", distance/1000];
    } else {
        return [NSString stringWithFormat:@"%.0f km", distance/1000];
    }
}

- (void)updateDistanceWithLocation:(CLLocation *)location
{
    CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    self.distance = [restaurantLocation distanceFromLocation:location];
}

- (BOOL)isOpen
{
    return [openingTime timeIntervalSinceNow] <= 0 && [closingTime timeIntervalSinceNow] >= 0;
}

- (BOOL)isAlreadyClosed
{
    return [closingTime timeIntervalSinceNow] < 0;
}

- (BOOL)favorite
{
    return favorite;
}

- (void)setFavorite:(BOOL)isFavorite
{
    if (favorite == isFavorite) {
        return;
    }
    
    favorite = isFavorite;
    
    if (favorite) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteAdded object:self];
    } else {
        //[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteRemoved object:self];
    }
}

NSComparisonResult compareRestaurantsByName(id restaurant1, id restaurant2, void *context)
{
    return [[restaurant1 name] compare:[restaurant2 name]];
}

NSComparisonResult compareRestaurantsByDistance(id restaurant1, id restaurant2, void *context)
{
    if ([restaurant1 distance] < [restaurant2 distance]) {
        return NSOrderedAscending;
    } else if ([restaurant1 distance] > [restaurant2 distance]) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

NSComparisonResult compareRestaurantsByOpeningTime(id restaurant1, id restaurant2, void *context)
{
    BOOL isAlreadyClosed1 = [restaurant1 isAlreadyClosed];
    BOOL isAlreadyClosed2 = [restaurant2 isAlreadyClosed];
    if (isAlreadyClosed1 != isAlreadyClosed2) {
        return (isAlreadyClosed1 - isAlreadyClosed2);
    }
    
    NSComparisonResult openingTimeResult = [[restaurant1 openingTime] compare:[restaurant2 openingTime]];
    if (openingTimeResult != NSOrderedSame) {
        return openingTimeResult;
    } else {
        return [[restaurant1 closingTime] compare:[restaurant2 closingTime]];
    }
}

@end
