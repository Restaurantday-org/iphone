//
//  MyWebViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 17.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize request;

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    self.view = webView;
    [webView loadRequest:request];
}

- (UIWebView *)webView
{
    return [UIWebView cast:self.view];
}

@end
