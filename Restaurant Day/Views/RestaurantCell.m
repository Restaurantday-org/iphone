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
#import "AppDelegate.h"

@interface RestaurantCell () {
    Restaurant *restaurant;
}

@end

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
@synthesize clockIconView;
@synthesize placeIconView;

@synthesize restaurantTypesView;

@dynamic restaurant;

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"RestaurantCell";
    RestaurantCell *cell = (RestaurantCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"RestaurantCell_iPhone" : @"RestaurantCell_iPad";
        cell = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:0];
        cell.accessoryType = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        
        // cell.currentTimeDash.backgroundColor = /*[UIColor colorWithPatternImage:[UIImage imageNamed:@"dash-pattern"]];*/ [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
        UIColor *lightColor = [UIColor clearColor];
        UIColor *darkColor = [UIColor colorWithWhite:0 alpha:0.14];
        gradient.colors = [NSArray arrayWithObjects:(id)[lightColor CGColor], (id)[darkColor CGColor], nil];
        [cell.backgroundView.layer insertSublayer:gradient atIndex:0];
        cell.gradientLayer = gradient;
    }
    
    cell.width = tableView.width;
    
    return cell;
}

- (Restaurant *)restaurant
{
    return restaurant;
}

- (void)setRestaurant:(Restaurant *)newRestaurant
{
    restaurant = newRestaurant;
    
    nameLabel.text = restaurant.name;
    descriptionLabel.text = restaurant.shortDesc;
    timeLabel.text = restaurant.openingHoursText;
    addressLabel.text = restaurant.address;
    distanceLabel.text = restaurant.distanceText;
    
    NSInteger addressWidth = [restaurant.address sizeWithFont:addressLabel.font].width;
    if (addressWidth > 160) { addressWidth = 160; }
    addressLabel.width = addressWidth;
    
    [restaurantTypesView removeFromSuperview];
    self.restaurantTypesView = [[UIView alloc] init];
    
    NSInteger typeViewSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        typeViewSize = 12;
        restaurantTypesView.frame = CGRectMake(addressLabel.x + addressLabel.width + 12,
                                               addressLabel.y + 4,
                                               restaurant.type.count * (typeViewSize + 1),
                                               typeViewSize);
    } else {
        typeViewSize = 30;
        NSInteger totalWidth = restaurant.type.count * (typeViewSize + 1);
        restaurantTypesView.frame = CGRectMake(self.width - totalWidth - 76,
                                               (self.height - typeViewSize) / 2,
                                               totalWidth,
                                               typeViewSize);
        restaurantTypesView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    [self addSubview:restaurantTypesView];

    for (NSInteger i = 0; i < restaurant.type.count; i++) {
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
            (restaurantTypesView.x + i * (typeViewSize + 1) >= distanceLabel.x)) {
            break;
        }
        NSString *type = [restaurant.type objectAtIndex:i];
        UIImage *typeIcon = [UIImage imageNamed:[NSString stringWithFormat:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"icon-%@" : @"bigicon-%@", type]];
        UIImageView *typeIconView = [[UIImageView alloc] initWithImage:typeIcon];
        typeIconView.frame = CGRectMake(i * (typeViewSize + 1), 0, typeViewSize, typeViewSize);
        typeIconView.alpha = 0.9;
        [restaurantTypesView addSubview:typeIconView];
    }
    
    timeIndicator.x = [self.class xForTimestamp:restaurant.openingSeconds withCellWidth:self.width];
    timeIndicator.width = [self.class xForTimestamp:restaurant.closingSeconds withCellWidth:self.width] - timeIndicator.x;
    
    // NSInteger currentSeconds = (NSInteger) [NSDate timeIntervalSinceReferenceDate] % (24*60*60) + (2*60*60);
    
    NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
    [secondFormatter setDateFormat:@"A"];
    NSInteger currentSeconds = [[secondFormatter stringFromDate:[NSDate date]] intValue] / 1000;
    currentTimePointer.x = [self.class xForTimestamp:currentSeconds withCellWidth:self.width];
    currentTimeDash.x = currentTimePointer.x;
    
    BOOL todayIsRestaurantDay = [AppDelegate todayIsRestaurantDay];
    BOOL restaurantIsAlreadyClosed = restaurant.isAlreadyClosed;
    
    if (restaurant.isOpen) {
        
        timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        timeIndicator.alpha = 1;

    } else if (restaurantIsAlreadyClosed) {
        
        timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient-gray.png"]];
        timeIndicator.alpha = 0.5;
        
    } else {
        
        timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        timeIndicator.alpha = 0.5;
    }
    
    currentTimePointer.hidden = !(restaurant.isOpen);
    
    clockIconView.alpha = (restaurantIsAlreadyClosed) ? 0.4 : 1;
    placeIconView.alpha = (restaurantIsAlreadyClosed) ? 0.4 : 1;
    restaurantTypesView.alpha = (restaurantIsAlreadyClosed) ? 0.4 : 1;
    
    currentTimePointer.hidden = !todayIsRestaurantDay;
    currentTimeDash.hidden = !todayIsRestaurantDay;
    
    // NSLog(@"is restaurant day: %d", [AppDelegate todayIsRestaurantDay]);
    favoriteIndicator.hidden = !restaurant.favorite;
    
    self.gradientLayer.frame = self.bounds;
    
    [self setSelected:NO animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
    }
    
    UIColor *labelColor;
    if (restaurant.isAlreadyClosed) {
        labelColor = (selected) ? [UIColor whiteColor] : [UIColor lightGrayColor];
    } else {
        labelColor = (selected) ? [UIColor whiteColor] : [UIColor darkTextColor];
    }
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

+ (NSInteger)xForTimestamp:(NSInteger)seconds withCellWidth:(CGFloat)width
{
    NSInteger x = (seconds - 3 * 60 * 60.0) / (24 * 60 * 60.0) * width;  // why subtract 3 hours? to set the scale as 03:00 -> (next day's) 03:00
    return x;
}

@end
