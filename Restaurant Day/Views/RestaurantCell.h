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

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *timeIndicator;
@property (weak, nonatomic) IBOutlet UIView *currentTimePointer;
@property (weak, nonatomic) IBOutlet UIView *currentTimeDash;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *clockIconView;
@property (weak, nonatomic) IBOutlet UIImageView *placeIconView;
@property (weak, nonatomic) CAGradientLayer *gradientLayer;

@property (strong) UIView *restaurantTypesView;

@property (strong) Restaurant *restaurant;

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView;

+ (NSInteger)xForTimestamp:(NSInteger)seconds withCellWidth:(CGFloat)width;

@end
