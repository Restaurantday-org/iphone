//
//  RestaurantDayViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantsDataSource.h"

#import "GAI.h"

@interface InfoViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *splashImageView;
@property (nonatomic, weak) IBOutlet UIButton *feedbackButton;

@property (nonatomic, weak) id<RestaurantsDataSource> dataSource;

@property (assign) BOOL modalPresentation;

- (void)refreshInfo;

- (IBAction)presentFeedbackComposer;

@end
