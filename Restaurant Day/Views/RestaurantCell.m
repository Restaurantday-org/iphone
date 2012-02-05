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
#import "AppDelegate.h"

@implementation RestaurantCell

@synthesize nameLabel;
@synthesize descriptionLabel;
@synthesize timeLabel;
@synthesize addressLabel;
@synthesize distanceLabel;
@synthesize timeIndicator;
@synthesize currentTimePointer;
@synthesize currentTimeDash;
@synthesize favoriteIndicator;

@synthesize restaurantTypesView;

- (void)setRestaurant:(Restaurant *)restaurant
{
    nameLabel.text = restaurant.name;
    descriptionLabel.text = restaurant.shortDesc;
    timeLabel.text = restaurant.openingHoursText;
    addressLabel.text = restaurant.address;
    distanceLabel.text = restaurant.distanceText;
    
    int addressWidth = [restaurant.address sizeWithFont:addressLabel.font].width;
    if (addressWidth > 160) { addressWidth = 160; }
    addressLabel.width = addressWidth;
    
    [restaurantTypesView removeFromSuperview];
    self.restaurantTypesView = [[UIView alloc] init];
    restaurantTypesView.frame = CGRectMake(addressLabel.x+addressLabel.width+12, addressLabel.y+4, restaurant.type.count*13, 12);
    [self addSubview:restaurantTypesView];

    for (int i = 0; i < restaurant.type.count; i++) {
        if (restaurantTypesView.x + i*13 >= distanceLabel.x) {
            break;
        }
        NSString *type = [restaurant.type objectAtIndex:i];
        UIImage *typeIcon = [UIImage imageNamed:[NSString stringWithFormat:@"icon-%@", type]];
        UIImageView *typeIconView = [[UIImageView alloc] initWithImage:typeIcon];
        typeIconView.frame = CGRectMake(i*13, 0, 12, 12);
        typeIconView.alpha = 0.9;
        [restaurantTypesView addSubview:typeIconView];
    }
    
    timeIndicator.x = [self.class xForTimestamp:restaurant.openingSeconds];
    timeIndicator.width = [self.class xForTimestamp:restaurant.closingSeconds]-timeIndicator.x;
    
    NSInteger currentSeconds = (NSInteger) [NSDate timeIntervalSinceReferenceDate] % (24*60*60) + (2*60*60);
    currentTimePointer.x = [self.class xForTimestamp:currentSeconds];
    currentTimeDash.x = currentTimePointer.x;
    
    BOOL todayIsRestaurantDay = [AppDelegate todayIsRestaurantDay];
    
    if (restaurant.isOpen || !todayIsRestaurantDay) {
        
        timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        timeIndicator.alpha = 1;
        currentTimePointer.backgroundColor = [UIColor whiteColor];

    } else if (restaurant.isAlreadyClosed) {
        
        timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient-gray.png"]];
        timeIndicator.alpha = 0.5;
        currentTimePointer.backgroundColor = [UIColor darkGrayColor];
        
    } else {
        
        timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        timeIndicator.alpha = 0.5;
        currentTimePointer.backgroundColor = [UIColor darkGrayColor];
    }
    
    currentTimePointer.hidden = !todayIsRestaurantDay;
    currentTimeDash.hidden = !todayIsRestaurantDay;
    
    // NSLog(@"is restaurant day: %d", [AppDelegate todayIsRestaurantDay]);
    favoriteIndicator.hidden = !restaurant.favorite;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
    }
    
    UIColor *labelColor = (selected) ? [UIColor whiteColor] : [UIColor darkTextColor];
    UIColor *shadowColor = (selected) ? [UIColor darkTextColor] : [UIColor whiteColor];
    nameLabel.textColor = labelColor;
    descriptionLabel.textColor = labelColor;
    timeLabel.textColor = labelColor;
    addressLabel.textColor = labelColor;
    distanceLabel.textColor = labelColor;
    timeLabel.shadowColor = shadowColor;
    addressLabel.shadowColor = shadowColor;
    
    // NSLog(@"start: %d end: %d", timeIndicator.x, timeIndicator.x+timeIndicator.width);
    
    if (animated) {
        [UIView commitAnimations];
    }
}

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"RestaurantCell";
    RestaurantCell *cell = (RestaurantCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RestaurantCell" owner:nil options:nil] objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.currentTimeDash.backgroundColor = /*[UIColor colorWithPatternImage:[UIImage imageNamed:@"dash-pattern"]];*/ [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
        gradient.frame = cell.frame;
        UIColor *lightColor = [UIColor clearColor];
        UIColor *darkColor = [UIColor colorWithWhite:0 alpha:0.14];
        gradient.colors = [NSArray arrayWithObjects:(id)[lightColor CGColor], (id)[darkColor CGColor], nil];
        [cell.backgroundView.layer insertSublayer:gradient atIndex:0];
    }
    
    return cell;
}

+ (NSInteger)xForTimestamp:(NSInteger)seconds
{
    int x = (seconds - 3*60*60.0)/(24*60*60.0) * 320;  // why subtract 3 hours? to set the scale as 03:00 -> (next day's) 03:00
    if (x < 0) {
        // NSLog(@"ai saatana: %d", seconds);
    }
    return x;
}

@end
