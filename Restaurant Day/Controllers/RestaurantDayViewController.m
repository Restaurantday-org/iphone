//
//  RestaurantDayViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Bulletin.h"
#import "UIView+Extras.h"

@implementation RestaurantDayViewController
@synthesize dateLabel;
@synthesize textBackgroundBox;
@synthesize newsDateLabel;
@synthesize newsContentLabel;
@synthesize activityIndicator;

- (id)init {
    self = [super init];
    if (self) {
        dataProvider = [[InfoDataProvider alloc] init];
        dataProvider.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    dateLabel.text = @"";
    newsDateLabel.text = @"";
    newsContentLabel.text = @"";
    textBackgroundBox.hidden = YES;
    dateLabel.width = 0;
    
    [dataProvider startLoadingInfo];
    self.navigationController.navigationBarHidden = YES;
    dateLabel.layer.cornerRadius = 4.0f;
    textBackgroundBox.layer.cornerRadius = 4.0f;
}

- (void)viewDidUnload {
    [self setDateLabel:nil];
    [self setTextBackgroundBox:nil];
    [self setNewsDateLabel:nil];
    [self setNewsContentLabel:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)gotInfo:(Info *)info
{
    [activityIndicator stopAnimating];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d.M.YYYY"];
    dateLabel.text = [formatter stringFromDate:info.nextDate];
    CGSize dateSize = [dateLabel.text sizeWithFont:dateLabel.font];
    dateLabel.width = ceil(dateSize.width + 20.0f);
    if (dateLabel.width % 2 == 1) dateLabel.width += 1;
    dateLabel.x = 160 - dateLabel.width/2;
    
    if (info.bulletins.count > 0) {
        Bulletin *bulletin = [info.bulletins objectAtIndex:0];
        newsDateLabel.text = [formatter stringFromDate:bulletin.date];
        newsContentLabel.text = bulletin.text;
        
        CGSize neededSize = [bulletin.text sizeWithFont:newsContentLabel.font constrainedToSize:CGSizeMake(newsContentLabel.width, 80.0f) lineBreakMode:UILineBreakModeWordWrap];
        textBackgroundBox.height = neededSize.height + 40.0f;
        newsContentLabel.height = neededSize.height;
        
        textBackgroundBox.hidden = NO;
    }
}

- (void)failedToGetInfo
{
    [activityIndicator stopAnimating];
    NSLog(@"Failed to get info :(");
}

@end
