//
//  RestaurantDayViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoDataProvider.h"
#import "GAI.h"

@interface RestaurantDayViewController : GAITrackedViewController <InfoDataProviderDelegate> {
    InfoDataProvider *dataProvider;
}

@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *textBackgroundBox;
@property (weak, nonatomic) IBOutlet UILabel *newsDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsContentLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

@property (assign) BOOL modalPresentation;

- (IBAction)presentFeedbackComposer;

@end
