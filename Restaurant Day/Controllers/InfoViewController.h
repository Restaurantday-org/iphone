//
//  RestaurantDayViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface InfoViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *textBackgroundBox;
@property (nonatomic, weak) IBOutlet UILabel *newsDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *newsContentLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *splashImageView;
@property (nonatomic, weak) IBOutlet UIButton *feedbackButton;

@property (assign) BOOL modalPresentation;

- (IBAction)presentFeedbackComposer;

@end
