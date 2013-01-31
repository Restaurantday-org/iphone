//
//  RestaurantListHeader.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSliderPopover.h"

@interface RestaurantListHeader : UIView

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *homeImage;
@property (weak, nonatomic) IBOutlet UIButton *indoorButton;
@property (weak, nonatomic) IBOutlet UILabel *indoorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indoorImage;
@property (weak, nonatomic) IBOutlet UIButton *outdoorButton;
@property (weak, nonatomic) IBOutlet UILabel *outdoorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *outdoorImage;
@property (weak, nonatomic) IBOutlet UIButton *restaurantButton;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UIButton *cafeButton;
@property (weak, nonatomic) IBOutlet UILabel *cafeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cafeImage;
@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (weak, nonatomic) IBOutlet UILabel *barLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barImage;

@property (weak, nonatomic) IBOutlet UIView *showOnlyOpenView;
@property (weak, nonatomic) IBOutlet UIButton *showOnlyOpenButton;
@property (weak, nonatomic) IBOutlet UILabel *showOnlyOpenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *showOnlyOpenCheckbox;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet NYSliderPopover *distanceSlider;

+ (RestaurantListHeader *)newInstance;

@end
