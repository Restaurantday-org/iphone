//
//  MyWebViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 17.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "MyWebViewController.h"

@implementation MyWebViewController

@synthesize request;

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    self.view = webView;
    [webView loadRequest:request];
}

@end
