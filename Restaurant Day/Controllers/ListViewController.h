//
//  ListViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKUserLocation.h>

#import "RestaurantsDataSource.h"

@class RestaurantListHeader;

@interface ListViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    BOOL displaysOnlyCurrentlyOpen;

    NSMutableArray *visibleRestaurants;
    
    CLLocation *location;
}

- (void)reloadData;

@property (assign) BOOL displaysOnlyFavorites;

@property (strong) UITableView *tableView;
@property (strong) RestaurantListHeader *listHeader;
@property (strong) UISegmentedControl *orderChooser;

@property (nonatomic, weak) id<RestaurantsDataSource> dataSource;

- (IBAction)showSearch;
- (IBAction)hideSearch;

@end

@interface RestaurantListHeader : UIView

@property (nonatomic, weak) IBOutlet UIView *showOnlyOpenView;
@property (nonatomic, weak) IBOutlet UIButton *showOnlyOpenButton;
@property (nonatomic, weak) IBOutlet UILabel *showOnlyOpenLabel;
@property (nonatomic, weak) IBOutlet UIImageView *showOnlyOpenCheckbox;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelSearchButton;

+ (RestaurantListHeader *)newInstance;

@end

@interface RestaurantCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIView *timeIndicator;
@property (nonatomic, weak) IBOutlet UIView *currentTimePointer;
@property (nonatomic, weak) IBOutlet UIView *currentTimeDash;
@property (nonatomic, weak) IBOutlet UIImageView *favoriteIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *clockIconView;
@property (nonatomic, weak) IBOutlet UIImageView *placeIconView;
@property (nonatomic, weak) CAGradientLayer *gradientLayer;

@property (nonatomic) UIView *restaurantTypesView;

@property (nonatomic, weak) Restaurant *restaurant;

+ (RestaurantCell *)restaurantCellWithTableView:(UITableView *)tableView;

+ (NSInteger)xForTimestamp:(NSInteger)seconds withCellWidth:(CGFloat)width;

@end
