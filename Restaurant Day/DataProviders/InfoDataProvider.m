//
//  InfoDataProvider.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "InfoDataProvider.h"
#import "ASIHTTPRequest.h"
#import "InfoDataParser.h"
#import "Info.h"
#import "AppDelegate.h"

@interface InfoDataProvider (hidden)
- (void)gotInfo:(ASIHTTPRequest *)request;
- (void)failedToGetInfo:(ASIHTTPRequest *)request;
@end

@implementation InfoDataProvider

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
    }
    return self;
}

- (void)startLoadingInfo
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:kURLForInfo]];
    request.delegate = self;
    request.didFinishSelector = @selector(gotInfo:);
    request.didFailSelector = @selector(failedToGetInfo:);
    [queue addOperation:request];
    [queue go];
}

- (void)gotInfo:(ASIHTTPRequest *)request
{
    InfoDataParser *parser = [[InfoDataParser alloc] init];
    
    Info *info = [parser parseInfoDataFromJson:request.responseString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    NSString *dateToday = [dateFormatter stringFromDate:[NSDate date]];
    NSString *dateOnRestaurantDay = [dateFormatter stringFromDate:info.nextDate];
    [AppDelegate setTodayIsRestaurantDay:[dateToday isEqual:dateOnRestaurantDay]];
    
    [delegate gotInfo:info];
}

- (void)failedToGetInfo:(ASIHTTPRequest *)request
{
    [delegate failedToGetInfo];
}

@end
