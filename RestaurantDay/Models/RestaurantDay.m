//
//  RestaurantDay.m
//  RestaurantDay
//
//  Created by Janne Käki on 05/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "RestaurantDay.h"

@implementation RestaurantDay

//    {
//        "org-short-name": "restaurantday",
//        "is-open": true,
//        "popularity": 1500000,
//        "cover-image-url": "/images/restaurantday-August2014.jpg",
//        "organization": "53d37cd003648c17ba381ef0",
//        "title": "August 2014",
//        "org-name": "Restaurant Day",
//        "event-count": 437,
//        "_id": "53d37cd003648c17ba381ef4",
//        "open-from": "2014-07-26T10:02:56.201Z",
//        "map-fields": [
//            {
//                "name": "Date",
//                "type": "date",
//                "id": "date",
//                "value": "2014-08-17"
//            }
//        ],
//        "open-until": "2014-08-18T00:00:00.000Z"
//    }

+ (RestaurantDay *)restaurantDayFromMaplantisDict:(NSDictionary *)dict
{
    RestaurantDay *rd = [RestaurantDay new];
    
    rd.id = [dict stringForKey:@"_id"];
    rd.title = [dict stringForKey:@"title"];
    
    NSArray *fields = [dict arrayForKey:@"map-fields"];
    NSDictionary *dateField = rd_filter(fields, ^BOOL(NSDictionary *dict) {
        return [[dict stringForKey:@"id"] isEqualToString:@"date"];
    }).firstObject;
    NSString *dateString = [dateField stringForKey:@"value"];
    rd.date = [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"] dateFromString:dateString];
    
    rd.openFrom = [dict dateForKey:@"open-from"];
    rd.openUntil = [dict dateForKey:@"open-until"];
    rd.isOpen = [dict boolForKey:@"is-open"];
    
    rd.eventCount = [dict integerForKey:@"event-count"];
    
    return rd;
}

+ (NSArray *)restaurantDaysFromArrayOfMaplantisDicts:(NSArray *)dicts
{
    return rd_map(dicts, ^id(NSDictionary *dict, NSInteger index) {
        return [self restaurantDayFromMaplantisDict:dict];
    });
}

@end
