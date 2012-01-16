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
#import "UIView+Extras.h"

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
@end

@implementation ListViewController

@dynamic restaurants;
@dynamic displaysOnlyFavorites;

- (id)initWithStyle:(UITableViewStyle)style displayOnlyFavorites:(BOOL)onlyFavorites
{
    if ((self = [super initWithStyle:style])) {
        displaysOnlyFavorites = onlyFavorites;
        if (displaysOnlyFavorites) {
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:kFavoriteAdded object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteRemoved:) name:kFavoriteRemoved object:nil];
            dataProvider = [[RestaurantDataProvider alloc] init];
            dataProvider.delegate = self;
        } else {
            displaysOnlyCurrentlyOpen = NO;
        }
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
    [restaurants sortUsingFunction:compareRestaurantsByDistance context:NULL];
    [self filterRestaurants];
    NSLog(@"newRestaurants: %@, restaurants: %@, visibleRestaurants: %@", newRestaurants, restaurants, visibleRestaurants);
}

- (void)filterRestaurants
{
    visibleRestaurants = [[NSMutableArray alloc] init];
    if (!displaysOnlyFavorites) {
        for (Restaurant *restaurant in restaurants) {
            if ([self shouldShowRestaurant:restaurant]) {
                [visibleRestaurants addObject:restaurant];
            }
        }
    } else {
        [visibleRestaurants addObjectsFromArray:restaurants];
        NSLog(@"visibleRestaurants: %@", visibleRestaurants);
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
    
    BOOL hasFound = NO;
    for (NSString *type in restaurant.type) {
        for (NSString *comparisonType in upperActiveFilters) {
            if ([type isEqualToString:comparisonType]) {
                hasFound = YES;
            }
        }
    }
    if (!hasFound) return NO;
    
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
    
    upperActiveFilters = [[NSMutableArray alloc] initWithObjects:@"home", @"public", @"outdoors", nil];
    lowerActiveFilters = [[NSMutableArray alloc] initWithObjects:@"restaurant", @"cafe", @"bar", nil];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    if (!displaysOnlyFavorites) {
        RestaurantListHeader *header = [[RestaurantListHeader alloc] init];
        self.tableView.tableHeaderView = header;
        listHeader = header;
        [header.homeButton addTarget:self action:@selector(homeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [header.indoorButton addTarget:self action:@selector(indoorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [header.outdoorButton addTarget:self action:@selector(outdoorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [header.restaurantButton addTarget:self action:@selector(restaurantButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [header.cafeButton addTarget:self action:@selector(cafeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [header.barButton addTarget:self action:@selector(barButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [header.showOnlyOpenButton addTarget:self action:@selector(showOnlyOpenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        header.homeLabel.text = NSLocalizedString(@"Filters.Venue.AtHome", nil);
        header.indoorLabel.text = NSLocalizedString(@"Filters.Venue.Indoors", nil);
        header.outdoorLabel.text = NSLocalizedString(@"Filters.Venue.Outdoors", nil);
        header.restaurantLabel.text = NSLocalizedString(@"Filters.Type.Restaurant", nil);
        header.cafeLabel.text = NSLocalizedString(@"Filters.Type.Cafe", nil);
        header.barLabel.text = NSLocalizedString(@"Filters.Type.Bar", nil);
        header.showOnlyOpenLabel.text = NSLocalizedString(@"Filters.ShowOnlyOpen", nil);
    }
    
    [dataProvider startLoadingFavoriteRestaurants];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (displaysOnlyFavorites) {
        [dataProvider startLoadingFavoriteRestaurants];
    }
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.navigationItem.titleView = [[UIView alloc] init];
    
    if (displaysOnlyFavorites) {
        [restaurants sortUsingFunction:compareRestaurantsByOpeningTime context:NULL];
    } else {
        [restaurants sortUsingFunction:compareRestaurantsByDistance context:NULL];
    }
    
    [self.tableView reloadData];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)displaysOnlyFavorites
{
    return displaysOnlyFavorites;
}

- (void)favoriteAdded:(NSNotification *)notification
{
    if (restaurants == nil) {
        restaurants = [NSMutableArray array];
    }
    [restaurants addObject:notification.object];
    [self filterRestaurants];
}

- (void)favoriteRemoved:(NSNotification *)notification
{
    [restaurants removeObject:notification.object];    
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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    UILabel *label;
    NSMutableArray *filterList;
    if ([filter isEqualToString:@"home"]) {
        button = listHeader.homeButton;
        label = listHeader.homeLabel;
        filterList = upperActiveFilters;
    } else if ([filter isEqualToString:@"public"]) {
        button = listHeader.indoorButton;
        label = listHeader.indoorLabel;
        filterList = upperActiveFilters;
    } else if ([filter isEqualToString:@"outdoors"]) {
        button = listHeader.outdoorButton;
        label = listHeader.outdoorLabel;
        filterList = upperActiveFilters;
    } else if ([filter isEqualToString:@"restaurant"]) {
        button = listHeader.restaurantButton;
        label = listHeader.restaurantLabel;
        filterList = lowerActiveFilters;
    } else if ([filter isEqualToString:@"cafe"]) {
        button = listHeader.cafeButton;
        label = listHeader.cafeLabel;
        filterList = lowerActiveFilters;
    } else if ([filter isEqualToString:@"bar"]) {
        button = listHeader.barButton;
        label = listHeader.barLabel;
        filterList = lowerActiveFilters;
    }
    
    if (![self checkIfFilterIsOn:filter]) {
        button.backgroundColor = [UIColor lightGrayColor];
        label.alpha = 0.5f;
        [self removeFilter:filter];
    } else {
        button.backgroundColor = [UIColor darkGrayColor];
        label.alpha = 1.0f;
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
    [self toggleFilter:@"public"];
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

@end
