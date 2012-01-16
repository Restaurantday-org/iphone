//
//  RestaurantDetailDataProvider.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDetailDataProvider.h"

@interface RestaurantDetailDataProvider (hidden)
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

- (void)startGettingDetailsForRestaurantId:(NSInteger)restaurantId
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://golf-174.srv.hosting.fi:8080/mobileapi/restaurant/%d", restaurantId]]];
    request.delegate = self;
    request.didFinishSelector = @selector(gotDetails:);
    request.didFailSelector = @selector(failedToGetDetails:);

    [queue addOperation:request];
    [queue go];
}

- (void)gotDetails:(ASIHTTPRequest *)request
{
    [delegate gotDetails:request.responseString];
}

- (void)failedToGetDetails:(ASIHTTPRequest *)request
{
    
}

@end
