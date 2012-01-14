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
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *indoorButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *outdoorButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *restaurantButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cafeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *barButton;

@end
