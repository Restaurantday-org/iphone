//
//  RestaurantDetailDataProvider.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDetailDataProvider.h"

@interface RestaurantDetailDataProvider ()
- (void)gotDetails:(ASIHTTPRequest *)request;
- (void)failedToGetDetails:(ASIHTTPRequest *)request;
@end

@implementation RestaurantDetailDataProvider

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
    }
    return self;
}

- (void)startGettingDetailsForRestaurantId:(NSString *)restaurantId
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kURLForRestaurantById, restaurantId]]];
    request.delegate = self;
    request.didFinishSelector = @selector(gotDetails:);
    request.didFailSelector = @selector(failedToGetDetails:);

    [queue addOperation:request];
    [queue go];
}

- (void)gotDetails:(ASIHTTPRequest *)request
{
    NSLog(@"url: %@", request.url);
    [delegate gotDetails:request.responseString];
}

- (void)failedToGetDetails:(ASIHTTPRequest *)request
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:@"Failed to get restaurant details"
                                                              withFatal:@NO] build]];
}

@end
