//
//  MyWebViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 17.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic) NSURLRequest *request;

@property (nonatomic, readonly) UIWebView *webView;

@end
