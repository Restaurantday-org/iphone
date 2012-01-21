//
//  ListViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "ListViewController.h"
#import "Restaurant.h"
#import "RestaurantCell.h"
#import "RestaurantViewController.h"
#import "AppDelegate.h"
#import "UIView+Extras.h"

#define kOrderChoiceIndexName         0
#define kOrderChoiceIndexDistance     1
#define kOrderChoiceIndexOpeningHours 2

@interface ListViewController (hidden)
- (void)homeButtonPressed;
- (void)indoorButtonPressed;
- (void)outdoorButtonPressed;
- (void)restaurantButtonPressed;
- (void)cafeButtonPressed;
- (void)barButtonPressed;
- (void)showOnlyOpenButtonPressed;
- (void)toggleFilter:(NSString *)filter;
- (void)toggleShowOnlyOpenFilter;
- (void)filterRestaurants;
- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant;
- (void)locationUpdated:(NSNotification *)notification;
@end

@implementation ListViewController

@dynamic restaurants;
@dynamic displaysOnlyFavorites;

@synthesize orderChooser;

- (id)initWithStyle:(UITableViewStyle)style displayOnlyFavorites:(BOOL)onlyFavorites
{
    if ((self = [super initWithStyle:style])) {
        displaysOnlyFavorites = onlyFavorites;
        dataProvider = [[RestaurantDataProvider alloc] init];
        dataProvider.delegate = self;
        if (displaysOnlyFavorites) {
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:kFavoriteAdded object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteRemoved:) name:kFavoriteRemoved object:nil];
            
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:kFavoriteAdded object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteRemoved:) name:kFavoriteRemoved object:nil];
            displaysOnlyCurrentlyOpen = NO;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kLocationUpdated object:nil];

    }
    return self;
}

- (NSArray *)restaurants
{
    return restaurants;
}

- (void)setRestaurants:(NSArray *)newRestaurants
{
    restaurants = [newRestaurants mutableCopy];
    [self filterRestaurants];
    NSLog(@"newRestaurants: %@, restaurants: %@, visibleRestaurants: %@", newRestaurants, restaurants, visibleRestaurants);
}

- (void)filterRestaurants
{
    NSLog(@"upper filters: %@, lower filters: %@", upperActiveFilters, lowerActiveFilters);
    visibleRestaurants = [[NSMutableArray alloc] init];
    if (!displaysOnlyFavorites) {
        for (Restaurant *restaurant in restaurants) {
            if ([self shouldShowRestaurant:restaurant]) {
                [visibleRestaurants addObject:restaurant];
                
            } else {
                NSLog(@"restaurant: %@, filters: %@", restaurant.name, restaurant.type);
            }
        }
    } else {
        [visibleRestaurants addObjectsFromArray:restaurants];
        NSLog(@"visibleRestaurants: %@", visibleRestaurants);
    }
    
    if (orderChooser.selectedSegmentIndex == kOrderChoiceIndexName) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByName context:NULL];
    } else if (orderChooser.selectedSegmentIndex == kOrderChoiceIndexDistance) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByDistance context:NULL];
    } else if (orderChooser.selectedSegmentIndex == kOrderChoiceIndexOpeningHours) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByOpeningTime context:NULL];
    }
    
    
    
    [self.tableView reloadData];
}

- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant
{
    if (displaysOnlyFavorites) {
        return restaurant.favorite;
    }
    
    if (displaysOnlyCurrentlyOpen) {
        if (!restaurant.isOpen) {
            return NO;
        }
    }
    
    if (upperActiveFilters.count == 0 && lowerActiveFilters.count == 0) return NO;
    
    BOOL hasFound = NO;
    if (upperActiveFilters.count == 0 || upperActiveFilters.count == 3) {
        hasFound = YES;
    } else {
        for (NSString *type in restaurant.type) {
            for (NSString *comparisonType in upperActiveFilters) {
                if ([type isEqualToString:comparisonType]) {
                    hasFound = YES;
                }
            }
        }
    }
    
    if (!hasFound && upperActiveFilters.count > 0) return NO;
    
    if (lowerActiveFilters.count == 0 || lowerActiveFilters.count == 3) return hasFound;
    
    for (NSString *type in restaurant.type) {
        for (NSString *comparisonType in lowerActiveFilters) {
            if ([type isEqualToString:comparisonType]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    upperActiveFilters = [[NSMutableArray alloc] initWithObjects:@"home", @"indoors", @"outdoors", nil];
    lowerActiveFilters = [[NSMutableArray alloc] initWithObjects:@"restaurant", @"cafe", @"bar", nil];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    NSArray *orderChoices = [NSArray arrayWithObjects:NSLocalizedString(@"List.Order.ByName", @""), NSLocalizedString(@"List.Order.ByDistance", @""), NSLocalizedString(@"List.Order.ByOpeningHours", @""), nil];
    self.orderChooser = [[UISegmentedControl alloc] initWithItems:orderChoices];
    orderChooser.segmentedControlStyle = UISegmentedControlStyleBar;
    orderChooser.tintColor = [UIColor grayColor];
    [orderChooser addTarget:self action:@selector(orderChoiceChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *header;
    if (!displaysOnlyFavorites) {
        
        listHeader = [[RestaurantListHeader alloc] init];
        header = listHeader;
        
        [listHeader.homeButton addTarget:self action:@selector(homeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.indoorButton addTarget:self action:@selector(indoorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.outdoorButton addTarget:self action:@selector(outdoorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.restaurantButton addTarget:self action:@selector(restaurantButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.cafeButton addTarget:self action:@selector(cafeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.barButton addTarget:self action:@selector(barButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.showOnlyOpenButton addTarget:self action:@selector(showOnlyOpenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        listHeader.homeLabel.text = NSLocalizedString(@"Filters.Venue.AtHome", nil);
        listHeader.indoorLabel.text = NSLocalizedString(@"Filters.Venue.Indoors", nil);
        listHeader.outdoorLabel.text = NSLocalizedString(@"Filters.Venue.Outdoors", nil);
        listHeader.restaurantLabel.text = NSLocalizedString(@"Filters.Type.Restaurant", nil);
        listHeader.cafeLabel.text = NSLocalizedString(@"Filters.Type.Cafe", nil);
        listHeader.barLabel.text = NSLocalizedString(@"Filters.Type.Bar", nil);
        listHeader.showOnlyOpenLabel.text = NSLocalizedString(@"Filters.ShowOnlyOpen", nil);
        
        BOOL todayIsRestaurantDay = [AppDelegate todayIsRestaurantDay];
        if (!todayIsRestaurantDay) {
            listHeader.showOnlyOpenButton.hidden = YES;
            listHeader.showOnlyOpenCheckbox.hidden = YES;
            listHeader.showOnlyOpenLabel.hidden = YES;
            listHeader.height -= 36;
        }
        
    } else {
        
        listHeader = nil;
        header = [[UIView alloc] init];
        header.backgroundColor = [UIColor colorWithWhite:33/255.0 alpha:1];
        header.frame = CGRectMake(0, 0, 320, 44);
        
        [dataProvider startLoadingFavoriteRestaurantsWithLocation:location];
    }
        
    [orderChooser removeFromSuperview];    
    orderChooser.frame = CGRectMake(10, header.height-37, 300, 30);
    [header addSubview:orderChooser];
    
    self.tableView.tableHeaderView = header;
        
    if (displaysOnlyFavorites) {
        orderChooser.selectedSegmentIndex = kOrderChoiceIndexOpeningHours;
    } else {
        orderChooser.selectedSegmentIndex = kOrderChoiceIndexDistance;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (displaysOnlyFavorites) {
        [dataProvider startLoadingFavoriteRestaurantsWithLocation:location];
    }
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.navigationItem.titleView = [[UIView alloc] init];
    
    [self filterRestaurants];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)displaysOnlyFavorites
{
    return displaysOnlyFavorites;
}

- (void)favoriteAdded:(NSNotification *)notification
{
    /*if (restaurants == nil) {
        restaurants = [NSMutableArray array];
    }
    [restaurants addObject:notification.object];
    [self filterRestaurants];*/
    
    NSInteger restaurantId = [notification.object intValue];
    
    for (Restaurant *restaurant in restaurants) {
        if (restaurant.restaurantId == restaurantId) {
            restaurant.favorite = YES;
        }
    }
    [self filterRestaurants];
}

- (void)favoriteRemoved:(NSNotification *)notification
{
    /*[restaurants removeObject:notification.object];    
    [self filterRestaurants];*/
    
    NSInteger restaurantId = [notification.object intValue];
    
    for (Restaurant *restaurant in restaurants) {
        if (restaurant.restaurantId == restaurantId) {
            restaurant.favorite = NO;
        }
    }
    [self filterRestaurants];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return visibleRestaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantCell *cell = [RestaurantCell restaurantCellWithTableView:tableView];
        
    Restaurant *restaurant = [visibleRestaurants objectAtIndex:indexPath.row];
    [cell setRestaurant:restaurant];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, 320, 20);
    header.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 19, 320, 1);
    line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [header addSubview:line];
    
    for (int hour = 4; hour <= 26; hour += 1) {
        
        int hourX = [RestaurantCell xForTimestamp:hour*60*60];
        
        if (hour % 3 == 0) {
            UILabel *hourLabel = [[UILabel alloc] init];
            hourLabel.frame = CGRectMake(0, 0, 30, 18);
            hourLabel.font = [UIFont boldSystemFontOfSize:11];
            hourLabel.text = [NSString stringWithFormat:@"%d", hour];
            hourLabel.textAlignment = UITextAlignmentCenter;
            hourLabel.textColor = [UIColor darkGrayColor];
            hourLabel.shadowColor = [UIColor whiteColor];
            hourLabel.shadowOffset = CGSizeMake(0, 1);
            hourLabel.backgroundColor = [UIColor clearColor];
            hourLabel.x = hourX-15;
            [header addSubview:hourLabel];
        }
        
        UIView *hourLine = [[UIView alloc] init];
        hourLine.frame = CGRectMake(hourX, 16, 1, 3);
        hourLine.backgroundColor = (hour % 3 == 0) ? [UIColor grayColor] : [UIColor lightGrayColor];
        [header addSubview:hourLine];
    }
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RestaurantViewController *companyViewController = [[RestaurantViewController alloc] init];
    companyViewController.restaurant = [visibleRestaurants objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:companyViewController animated:YES];
    
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Filter button actions

- (BOOL)checkIfFilterIsOn:(NSString *)filter
{
    for (NSString *testFilter in upperActiveFilters) {
        if ([testFilter isEqualToString:filter]) {
            return NO;
        }
    }
    for (NSString *testFilter in lowerActiveFilters) {
        if ([testFilter isEqualToString:filter]) {
            return NO;
        }
    }
    return YES;
}

- (void)removeFilter:(NSString *)filter
{
    NSString *removeObject;
    for (NSString *activeFilter in upperActiveFilters) {
        if ([activeFilter isEqualToString:filter]) {
            removeObject = activeFilter;
            break;
        }
    }
    for (NSString *activeFilter in lowerActiveFilters) {
        if ([activeFilter isEqualToString:filter]) {
            removeObject = activeFilter;
            break;
        }
    }
    if (removeObject != nil) [upperActiveFilters removeObject:removeObject];
    if (removeObject != nil) [lowerActiveFilters removeObject:removeObject];
}

- (void)toggleFilter:(NSString *)filter
{
    UIButton *button;
    UIImageView *image;
    UILabel *label;
    NSMutableArray *filterList;
    if ([filter isEqualToString:@"home"]) {
        button = listHeader.homeButton;
        label = listHeader.homeLabel;
        image = listHeader.homeImage;
        filterList = upperActiveFilters;
    } else if ([filter isEqualToString:@"indoors"]) {
        button = listHeader.indoorButton;
        label = listHeader.indoorLabel;
        image = listHeader.indoorImage;
        filterList = upperActiveFilters;
    } else if ([filter isEqualToString:@"outdoors"]) {
        button = listHeader.outdoorButton;
        label = listHeader.outdoorLabel;
        image = listHeader.outdoorImage;
        filterList = upperActiveFilters;
    } else if ([filter isEqualToString:@"restaurant"]) {
        button = listHeader.restaurantButton;
        label = listHeader.restaurantLabel;
        image = listHeader.restaurantImage;
        filterList = lowerActiveFilters;
    } else if ([filter isEqualToString:@"cafe"]) {
        button = listHeader.cafeButton;
        label = listHeader.cafeLabel;
        image = listHeader.cafeImage;
        filterList = lowerActiveFilters;
    } else if ([filter isEqualToString:@"bar"]) {
        button = listHeader.barButton;
        label = listHeader.barLabel;
        image = listHeader.barImage;
        filterList = lowerActiveFilters;
    }
    
    if (![self checkIfFilterIsOn:filter]) {
        button.backgroundColor = [UIColor colorWithWhite:0.13f alpha:1.0f];
        label.alpha = 0.3f;
        image.alpha = 0.3f;
        [self removeFilter:filter];
    } else {
        button.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
        label.alpha = 1.0f;
        image.alpha = 1.0f;
        [filterList addObject:filter];
    }
    
    NSLog(@"filters: %@, %@", upperActiveFilters, lowerActiveFilters);
    
    [self filterRestaurants];
}

- (void)toggleShowOnlyOpenFilter
{
    displaysOnlyCurrentlyOpen = !displaysOnlyCurrentlyOpen;
    
    if (displaysOnlyCurrentlyOpen) {
        listHeader.showOnlyOpenCheckbox.image = [UIImage imageNamed:@"checkbox-checked"];
    } else {
        listHeader.showOnlyOpenCheckbox.image = [UIImage imageNamed:@"checkbox-unchecked"];
    }
    
    [self filterRestaurants];
}

- (void)homeButtonPressed
{
    [self toggleFilter:@"home"];
}

- (void)indoorButtonPressed
{
    [self toggleFilter:@"indoors"];
}

- (void)outdoorButtonPressed
{
    [self toggleFilter:@"outdoors"];
}

- (void)restaurantButtonPressed
{
    [self toggleFilter:@"restaurant"];
}

- (void)cafeButtonPressed
{
    [self toggleFilter:@"cafe"];
}

- (void)barButtonPressed
{
    [self toggleFilter:@"bar"];
}

- (void)showOnlyOpenButtonPressed
{
    [self toggleShowOnlyOpenFilter];
}

- (void)gotRestaurants:(NSArray *)theRestaurants
{
    [self setRestaurants:theRestaurants];
    NSLog(@"restaurants: %@, favorite: %d", restaurants, displaysOnlyFavorites);
}

- (void)failedToGetRestaurants
{
    
}

- (void)locationUpdated:(NSNotification *)notification
{
    CLLocation *newLocation = (CLLocation *) notification.object;
    CGFloat distance = [newLocation distanceFromLocation:location];
    NSLog(@"listView distance: %f", distance);
    if (distance > 100 || distance < 0) {
        location = newLocation;
        if (displaysOnlyFavorites) {
            [dataProvider startLoadingFavoriteRestaurantsWithLocation:location];
        } else {
            [dataProvider startLoadingRestaurantsWithCenter:location.coordinate distance:200];
        }
        
    }
}

- (IBAction)orderChoiceChanged:(UISegmentedControl *)sender
{
    [self filterRestaurants];
}

@end
