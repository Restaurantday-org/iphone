//
//  RestaurantCell.m
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantCell.h"

#import "Restaurant.h"
#import "UIView+Extras.h"
#import <QuartzCore/QuartzCore.h>

@implementation RestaurantCell

@synthesize nameLabel;
@synthesize descriptionLabel;
@synthesize timeLabel;
@synthesize addressLabel;
@synthesize distanceLabel;
@synthesize timeIndicator;
@synthesize currentTimeIndicator;

- (void)setRestaurant:(Restaurant *)restaurant
{
    nameLabel.text = restaurant.name;
    descriptionLabel.text = restaurant.description;
    timeLabel.text = restaurant.openingHoursText;
    addressLabel.text = restaurant.address;
    distanceLabel.text = restaurant.distanceText;
    
    int addressWidth = [restaurant.address sizeWithFont:addressLabel.font].width;
    if (addressWidth > 160) { addressWidth = 160; }
    addressLabel.width = addressWidth;
    
    distanceLabel.x = addressLabel.x + addressLabel.width + 10;
    
    timeIndicator.x = [self.class xForTimestamp:restaurant.openingSeconds];
    timeIndicator.width = [self.class xForTimestamp:restaurant.closingSeconds]-timeIndicator.x;
    
    NSInteger currentSeconds = (NSInteger) [NSDate timeIntervalSinceReferenceDate] % (24*60*60);
    currentTimeIndicator.x = [self.class xForTimestamp:currentSeconds];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        
        CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
        gradient.frame = cell.frame;
        CGColorRef lightColor = [UIColor clearColor].CGColor;
        CGColorRef darkColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.14].CGColor;
        gradient.colors = [NSArray arrayWithObjects:(__bridge id)lightColor, (__bridge id)darkColor, nil];
        [cell.layer insertSublayer:gradient atIndex:0];
    }
    
    return cell;
}

+ (NSInteger)xForTimestamp:(NSInteger)seconds
{
    return seconds/(24*60*60.0) * 320;
}

@end
