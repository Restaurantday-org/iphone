//
//  SplashViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "SplashViewController.h"
#import "UIView+Extras.h"

@implementation SplashViewController
@synthesize buttonview;
@synthesize imageview;

- (void)viewDidLoad
{
    [self.view setExclusiveTouch:YES];
    [self.view setUserInteractionEnabled:NO];
    buttonview.backgroundColor = [UIColor clearColor];
    imageview.backgroundColor = [UIColor clearColor];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

- (void)viewDidUnload {
    [self setImageview:nil];
    [self setButtonview:nil];
    [super viewDidUnload];
}

@end
