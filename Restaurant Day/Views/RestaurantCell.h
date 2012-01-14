//
//  RestaurantCell.h
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Restaurant;

@interface RestaurantCell : UITableViewCell

@property (strong) IBOutlet UILabel *nameLabel;
@property (strong) IBOutlet UILabel *descriptionLabel;
@property (strong) IBOutlet UILabel *timeLabel;
@property (strong) IBOutlet UILabel *addressLabel;
@property (strong) IBOutlet UILabel *distanceLabel;
@property (strong) IBOutlet UIView *timeIndicator;
@property (strong) IBOutlet UIView *currentTimeIndicator;

- (void)setRestaurant:(Restaurant *)restaurant;

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView;

+ (NSInteger)xForTimestamp:(NSInteger)seconds;

@end
