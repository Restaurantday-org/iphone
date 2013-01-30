//
//  Info.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Info.h"

#import "Bulletin.h"
#import "SBJson.h"
#import "NSDictionary+Parsing.h"

@implementation Info

@synthesize nextDate, bulletins;

+ (Info *)infoFromJson:(NSString *)json
{
    Info *info = [[Info alloc] init];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *items = [parser objectWithString:json];
    
    NSInteger nextDateTimestamp = [[items objectOrNilForKey:@"nextRestaurantDate"] intValue];
    info.nextDate = [NSDate dateWithTimeIntervalSince1970:nextDateTimestamp];
    
    NSMutableArray *bulletins = [[NSMutableArray alloc] init];
    for (NSDictionary *bulletin in [items objectOrNilForKey:@"bulletins"]) {
        Bulletin *newBulletin = [[Bulletin alloc] init];
        newBulletin.text = [bulletin objectOrNilForKey:@"bulletin"];
        newBulletin.date = [NSDate dateWithTimeIntervalSince1970:[[bulletin objectOrNilForKey:@"date"] intValue]];
        newBulletin.lang = [bulletin objectOrNilForKey:@"lang"];
        [bulletins addObject:newBulletin];
    }
    info.bulletins = bulletins;
    
    return info;
}

@end
