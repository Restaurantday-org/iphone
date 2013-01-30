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

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *dateLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *textBackgroundBox;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *newsDateLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *newsContentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *splashImageView;

@property (assign) BOOL modalPresentation;

@end
