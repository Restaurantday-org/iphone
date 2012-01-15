//
//  RestaurantDayViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDayViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation RestaurantDayViewController
@synthesize dateLabel;
@synthesize textBackgroundBox;

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = YES;
    dateLabel.layer.cornerRadius = 4.0f;
    textBackgroundBox.layer.cornerRadius = 4.0f;
}

- (void)viewDidUnload {
    [self setDateLabel:nil];
    [self setTextBackgroundBox:nil];
    [super viewDidUnload];
}
@end
