//
//  RestaurantCell.h
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class Restaurant;

@interface RestaurantCell : UITableViewCell

@property (unsafe_unretained) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained) IBOutlet UILabel *descriptionLabel;
@property (unsafe_unretained) IBOutlet UILabel *timeLabel;
@property (unsafe_unretained) IBOutlet UILabel *addressLabel;
@property (unsafe_unretained) IBOutlet UILabel *distanceLabel;
@property (unsafe_unretained) IBOutlet UIView *timeIndicator;
@property (unsafe_unretained) IBOutlet UIView *currentTimePointer;
@property (unsafe_unretained) IBOutlet UIView *currentTimeDash;
@property (unsafe_unretained) IBOutlet UIImageView *favoriteIndicator;
@property (unsafe_unretained) IBOutlet UIImageView *clockIconView;
@property (unsafe_unretained) IBOutlet UIImageView *placeIconView;
@property (unsafe_unretained) CAGradientLayer *gradientLayer;

@property (strong) UIView *restaurantTypesView;

@property (strong) Restaurant *restaurant;

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView;

+ (NSInteger)xForTimestamp:(NSInteger)seconds withCellWidth:(CGFloat)width;

@end
