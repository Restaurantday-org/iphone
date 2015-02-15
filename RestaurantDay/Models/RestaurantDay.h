//
//  RestaurantDay.h
//  RestaurantDay
//
//  Created by Janne Käki on 05/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantDay : NSObject

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *date;

@property (nonatomic, copy) NSDate *openFrom;
@property (nonatomic, copy) NSDate *openUntil;
@property (nonatomic) BOOL isOpen;

@property (nonatomic) NSInteger eventCount;

+ (RestaurantDay *)restaurantDayFromMaplantisDict:(NSDictionary *)dict;
+ (NSArray *)restaurantDaysFromArrayOfMaplantisDicts:(NSArray *)dicts;

@end
