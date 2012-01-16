//
//  InfoDataParser.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "InfoDataParser.h"
#import "SBJsonParser.h"
#import "Bulletin.h"

@implementation InfoDataParser

- (Info *)parseInfoDataFromJson:(NSString *)json
{
    Info *info = [[Info alloc] init];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *items = [parser objectWithString:json];
    
    NSInteger nextDateTimestamp = [[items objectForKey:@"nextRestaurantDate"] intValue];
    info.nextDate = [NSDate dateWithTimeIntervalSince1970:nextDateTimestamp];
    
    NSMutableArray *bulletins = [[NSMutableArray alloc] init];
    for (NSDictionary *bulletin in [items objectForKey:@"bulletins"]) {
        Bulletin *newBulletin = [[Bulletin alloc] init];
        newBulletin.text = [bulletin objectForKey:@"bulletin"];
        newBulletin.date = [NSDate dateWithTimeIntervalSince1970:[[bulletin objectForKey:@"date"] intValue]];
        newBulletin.lang = [bulletin objectForKey:@"lang"];
        [bulletins addObject:newBulletin];
    }
    info.bulletins = bulletins;
    
    return info;
}

@end
