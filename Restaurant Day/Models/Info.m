//
//  Info.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Info.h"

#import "Bulletin.h"

@implementation Info

+ (Info *)infoFromDict:(NSDictionary *)dict
{
    Info *info = [[Info alloc] init];
    
    NSTimeInterval nextDateInterval = [dict integerForKey:@"nextRestaurantDate"];
    info.nextDate = (nextDateInterval) ? [NSDate dateWithTimeIntervalSince1970:nextDateInterval] : nil;
    
    info.bulletins = rd_map([dict arrayForKey:@"bulletins"], ^Bulletin *(NSDictionary *bulletinDict, NSInteger _) {
        Bulletin *bulletin = [[Bulletin alloc] init];
        bulletin.text = [bulletinDict stringForKey:@"bulletin"];
        bulletin.date = [NSDate dateWithTimeIntervalSince1970:[bulletinDict integerForKey:@"date"]];
        bulletin.lang = [bulletinDict stringForKey:@"lang"];
        return bulletin;
    });
    
    return info;
}

@end
