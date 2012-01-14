//
//  RestaurantCell.m
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantCell.h"

#import "Restaurant.h"

@implementation RestaurantCell

@synthesize nameLabel;
@synthesize descriptionLabel;
@synthesize locationLabel;
@synthesize timeIndicator;
@synthesize currentTimeIndicator;

- (void)setRestaurant:(Restaurant *)restaurant
{
    nameLabel.text = restaurant.name;
    descriptionLabel.text = restaurant.description;
    if (restaurant.distanceText != nil) {
        locationLabel.text = [NSString stringWithFormat:@"%@  ·  %@", restaurant.address, restaurant.distanceText];
    } else {
        locationLabel.text = restaurant.address;
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"RestaurantCell";
    RestaurantCell *cell = (RestaurantCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RestaurantCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    return cell;
}

@end
