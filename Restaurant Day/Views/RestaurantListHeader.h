//
//  RestaurantListHeader.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantListHeader : UIView
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *homeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *homeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *indoorButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *indoorLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *outdoorButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *outdoorLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *restaurantButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cafeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *cafeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *barButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *barLabel;

@end
