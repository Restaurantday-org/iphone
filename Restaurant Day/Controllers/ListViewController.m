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

@interface ListViewController (hidden)
- (void)homeButtonPressed;
- (void)indoorButtonPressed;
- (void)outdoorButtonPressed;
- (void)restaurantButtonPressed;
- (void)cafeButtonPressed;
- (void)barButtonPressed;
- (void)filterRestaurants;
- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant;
@end

@implementation ListViewController

@dynamic restaurants;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (NSArray *)restaurants
{
    return restaurants;
}

- (void)setRestaurants:(NSArray *)newRestaurants
{
    restaurants = newRestaurants;
    [self filterRestaurants];
    [self.tableView reloadData];
    NSLog(@"newRestaurants: %@, restaurants: %@, visibleRestaurants: %@", newRestaurants, restaurants, visibleRestaurants);
}

- (void)filterRestaurants
{
    visibleRestaurants = [[NSMutableArray alloc] init];
    
    for (Restaurant *restaurant in restaurants) {
        if ([self shouldShowRestaurant:restaurant]) {
            [visibleRestaurants addObject:restaurant];
        }
    }
    NSLog(@"visible: %@", visibleRestaurants);
}

- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant
{
    for (NSString *type in restaurant.type) {
        for (NSString *comparisonType in activeFilters) {
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
    
    activeFilters = [[NSMutableArray alloc] initWithObjects:@"home", @"indoor", @"outdoor", @"restaurant", @"cafe", @"bar", nil];
    
    self.tableView.separatorColor = [UIColor clearColor];
    RestaurantListHeader *header = [[RestaurantListHeader alloc] init];
    self.tableView.tableHeaderView = header;
    listHeader = header;
    [header.homeButton addTarget:self action:@selector(homeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [header.indoorButton addTarget:self action:@selector(indoorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [header.outdoorButton addTarget:self action:@selector(outdoorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [header.restaurantButton addTarget:self action:@selector(restaurantButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [header.cafeButton addTarget:self action:@selector(cafeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [header.barButton addTarget:self action:@selector(barButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = [[UIView alloc] init];
    
    [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RestaurantViewController *companyViewController = [[RestaurantViewController alloc] init];
    companyViewController.restaurant = [restaurants objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:companyViewController animated:YES];
}

#pragma mark - Filter button actions

- (BOOL)checkIfFilterIsOn:(NSString *)filter
{
    for (NSString *restaurant in activeFilters) {
        if ([restaurant isEqualToString:filter]) {
            return NO;
        }
    }
    return YES;
}

- (void)removeFilter:(NSString *)filter
{
    NSString *removeObject;
    for (NSString *activeFilter in activeFilters) {
        if ([activeFilter isEqualToString:filter]) {
            removeObject = activeFilter;
            break;
        }
    }
    if (removeObject != nil) [activeFilters removeObject:removeObject];
}

- (void)toggleFilter:(NSString *)filter
{
    UIButton *button;
    UILabel *label;
    if ([filter isEqualToString:@"home"]) {
        button = listHeader.homeButton;
        label = listHeader.homeLabel;
    } else if ([filter isEqualToString:@"indoor"]) {
        button = listHeader.indoorButton;
        label = listHeader.indoorLabel;
    } else if ([filter isEqualToString:@"outdoor"]) {
        button = listHeader.outdoorButton;
        label = listHeader.outdoorLabel;
    } else if ([filter isEqualToString:@"restaurant"]) {
        button = listHeader.restaurantButton;
        label = listHeader.restaurantLabel;
    } else if ([filter isEqualToString:@"cafe"]) {
        button = listHeader.cafeButton;
        label = listHeader.cafeLabel;
    } else if ([filter isEqualToString:@"bar"]) {
        button = listHeader.barButton;
        label = listHeader.barLabel;
    }
    
    if (![self checkIfFilterIsOn:filter]) {
        button.backgroundColor = [UIColor lightGrayColor];
        label.alpha = 0.5f;
        [self removeFilter:filter];
    } else {
        button.backgroundColor = [UIColor darkGrayColor];
        label.alpha = 1.0f;
        [activeFilters addObject:filter];
    }
    
    NSLog(@"filters: %@", activeFilters);
    
    [self filterRestaurants];
    [self.tableView reloadData];
}

- (void)homeButtonPressed
{
    [self toggleFilter:@"home"];
}

- (void)indoorButtonPressed
{
    [self toggleFilter:@"indoor"];
}

- (void)outdoorButtonPressed
{
    [self toggleFilter:@"outdoor"];
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

@end
