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
#import "NYSliderPopover.h"

#define kOrderChoiceIndexName         0
#define kOrderChoiceIndexDistance     1
#define kOrderChoiceIndexOpeningHours 2

@interface ListViewController () {
    NSInteger keyboardHeight;
}

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

@synthesize displaysOnlyFavorites;

@synthesize listHeader;
@synthesize orderChooser;

- (void)reloadData
{
    [self filterRestaurants];
}

- (void)filterRestaurants
{
    // NSLog(@"upper filters: %@, lower filters: %@", upperActiveFilters, lowerActiveFilters);
    visibleRestaurants = [[NSMutableArray alloc] init];
    if (!displaysOnlyFavorites) {
        for (Restaurant *restaurant in [self.dataSource allRestaurants]) {
            if ([self shouldShowRestaurant:restaurant]) {
                [visibleRestaurants addObject:restaurant];
                
            } else {
                // NSLog(@"restaurant: %@, filters: %@", restaurant.name, restaurant.type);
            }
        }
    } else {
        [visibleRestaurants addObjectsFromArray:[self.dataSource favoriteRestaurants]];
        // NSLog(@"visibleRestaurants: %@", visibleRestaurants);
    }
    
    if (orderChooser.selectedSegmentIndex == kOrderChoiceIndexName) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByName context:NULL];
    } else if (orderChooser.selectedSegmentIndex == kOrderChoiceIndexDistance) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByDistance context:NULL];
    } else if (orderChooser.selectedSegmentIndex == kOrderChoiceIndexOpeningHours) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByOpeningTime context:NULL];
    }
    
    [self.tableView reloadData];
    
    int contentHeight = 88 * visibleRestaurants.count;
    int availableHeight = (self.tableView.height - self.listHeader.height + self.listHeader.searchBar.y);
    if (searching &&
            contentHeight > 0 &&
            contentHeight < availableHeight) {
        UIView *footer = [[UIView alloc] init];
        footer.height = availableHeight - contentHeight;
        self.tableView.tableFooterView = footer;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant
{
    if (!displaysOnlyFavorites) {
        if (restaurant.distance > maxDistance) {
            return NO;
        }
    }
    
    if (searching) {
        NSString *search = listHeader.searchBar.text;
        if (search.length > 0 &&
            ([restaurant.name rangeOfString:search options:NSCaseInsensitiveSearch].location == NSNotFound) &&
            ([restaurant.shortDesc rangeOfString:search options:NSCaseInsensitiveSearch].location == NSNotFound) &&
            ([restaurant.fullAddress rangeOfString:search options:NSCaseInsensitiveSearch].location == NSNotFound)) {
            return NO;
        }
    }
    
    if (displaysOnlyFavorites) {
        return restaurant.favorite;
    }
    
    if (displaysOnlyCurrentlyOpen && !searching) {  // since the checkbox is not visible when searching, we ignore it
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
    
    keyboardHeight = 216;
    
    self.trackedViewName = (displaysOnlyFavorites) ? @"Favorites" : @"List";
    
    upperActiveFilters = [[NSMutableArray alloc] initWithObjects:@"home", @"indoors", @"outdoors", nil];
    lowerActiveFilters = [[NSMutableArray alloc] initWithObjects:@"restaurant", @"cafe", @"bar", nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    NSArray *orderChoices = [NSArray arrayWithObjects:NSLocalizedString(@"List.Order.ByName", @""), NSLocalizedString(@"List.Order.ByDistance", @""), NSLocalizedString(@"List.Order.ByOpeningHours", @""), nil];
    self.orderChooser = [[UISegmentedControl alloc] initWithItems:orderChoices];
    orderChooser.segmentedControlStyle = UISegmentedControlStyleBar;
    orderChooser.tintColor = [UIColor grayColor];
    [orderChooser addTarget:self action:@selector(orderChoiceChanged:) forControlEvents:UIControlEventValueChanged];
            
    if (displaysOnlyFavorites) {
        orderChooser.selectedSegmentIndex = kOrderChoiceIndexOpeningHours;
    } else {
        orderChooser.selectedSegmentIndex = kOrderChoiceIndexDistance;
    }
    
    UIView *header;
    if (!displaysOnlyFavorites) {
        
        self.listHeader = [RestaurantListHeader newInstance];
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
        listHeader.showOnlyOpenButton.enabled = todayIsRestaurantDay;
        listHeader.showOnlyOpenCheckbox.alpha = (todayIsRestaurantDay) ? 1 : 0.3;
        listHeader.showOnlyOpenLabel.alpha = (todayIsRestaurantDay) ? 1 : 0.3;
        
        listHeader.searchBar.delegate = self;
        listHeader.searchBar.alpha = 0.4;
        [listHeader.searchBar.subviews[0] removeFromSuperview];
        
        [listHeader.searchButton addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
        [listHeader.distanceSlider addTarget:self action:@selector(maxDistanceChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self maxDistanceChanged:listHeader.distanceSlider];
        
    } else {
        
        self.listHeader = nil;
        header = [[UIView alloc] init];
        header.backgroundColor = [UIColor colorWithWhite:33/255.0 alpha:1];
        header.frame = CGRectMake(0, 0, self.view.width, 44);
    }
    
    orderChooser.frame = CGRectMake(10, header.height - 37, header.width - 20, 30);
    orderChooser.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [header addSubview:orderChooser];
        
    self.tableView.tableHeaderView = header;
    
    self.navigationItem.titleView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    [self filterRestaurants];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    self.listHeader = nil;
    self.orderChooser = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (IBAction)showSearch
{
    searching = YES;
    
    [listHeader.searchBar becomeFirstResponder];
        
    [UIView animateWithDuration:0.3 animations:^{
        listHeader.searchBar.alpha = 1;
        listHeader.searchButton.alpha = 0;
        listHeader.searchBar.x = (kIsiPad) ? (self.view.bounds.size.width - listHeader.searchBar.width - 6) : 0;
        listHeader.searchButton.x = listHeader.searchBar.x;
        listHeader.showOnlyOpenView.alpha = 0;
    }];
    
    listHeader.searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    listHeader.searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self filterRestaurants];
}

- (IBAction)hideSearch
{
    searching = NO;
    
    [listHeader.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        listHeader.searchBar.alpha = 0.4;
        listHeader.searchButton.alpha = 1;
        listHeader.searchBar.x = (kIsiPad) ? (self.view.bounds.size.width - 60) : self.view.width - 42;
        listHeader.searchButton.x = listHeader.searchBar.x;
        listHeader.showOnlyOpenView.alpha = 1;
    }];
    
    listHeader.searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    listHeader.searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self filterRestaurants];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching && visibleRestaurants.count == 0) {
        return 1;
    }
    
    return visibleRestaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searching && visibleRestaurants.count == 0) {
        UITableViewCell *noResultsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        noResultsCell.textLabel.textAlignment = UITextAlignmentCenter;
        noResultsCell.textLabel.text = NSLocalizedString(@"Search.NoMatches", @"");
        noResultsCell.textLabel.textColor = [UIColor lightGrayColor];
        noResultsCell.textLabel.font = [UIFont boldSystemFontOfSize:13];
        noResultsCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return noResultsCell;
    }
    
    RestaurantCell *cell = [RestaurantCell restaurantCellWithTableView:tableView];
        
    Restaurant *restaurant = [visibleRestaurants objectAtIndex:indexPath.row];
    [cell setRestaurant:restaurant];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searching && visibleRestaurants.count == 0) {
        return self.tableView.height - (self.listHeader.height - self.listHeader.searchBar.y) - 10;
    }
    
    return 88;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (displaysOnlyFavorites && visibleRestaurants.count == 0) ? 120 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    header.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 19, self.view.bounds.size.width, 1);
    line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [header addSubview:line];
    
    for (int hour = 4; hour <= 26; hour += 1) {
        
        int hourX = [RestaurantCell xForTimestamp:(hour * 60 * 60) withCellWidth:tableView.width];
        
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (displaysOnlyFavorites && visibleRestaurants.count == 0) {
        
        UIView *footer = [[UIView alloc] init];
        footer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
        
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.frame = CGRectMake(15, 20, footer.width - 30, 20);
        footerLabel.font = [UIFont boldSystemFontOfSize:14];
        footerLabel.textColor = [UIColor lightGrayColor];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.textAlignment = UITextAlignmentCenter;
        footerLabel.lineBreakMode = UILineBreakModeWordWrap;
        footerLabel.numberOfLines = 0;
        footerLabel.text = NSLocalizedString(@"Favorites.NoFavorites.Title", @"");
        [footer addSubview:footerLabel];
        
        UILabel *footerSubLabel = [[UILabel alloc] init];
        footerSubLabel.frame = CGRectMake(15, 40, footer.width - 30, 70);
        footerSubLabel.font = [UIFont systemFontOfSize:14];
        footerSubLabel.textColor = [UIColor lightGrayColor];
        footerSubLabel.backgroundColor = [UIColor clearColor];
        footerSubLabel.textAlignment = UITextAlignmentCenter;
        footerSubLabel.lineBreakMode = UILineBreakModeWordWrap;
        footerSubLabel.numberOfLines = 0;
        footerSubLabel.text = NSLocalizedString(@"Favorites.NoFavorites.Subtitle", @"");
        [footer addSubview:footerSubLabel];
        
        return footer;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (visibleRestaurants.count == 0) {
        return;
    }
    
    RestaurantViewController *restaurantViewController = [[RestaurantViewController alloc] init];
    restaurantViewController.restaurant = [visibleRestaurants objectAtIndex:indexPath.row];
    restaurantViewController.dataSource = self.dataSource;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self.navigationController pushViewController:restaurantViewController animated:YES];
        
    } else {
        
        UINavigationController *navigator = [AppDelegate navigationControllerWithRootViewController:restaurantViewController];
        navigator.modalPresentationStyle = UIModalPresentationFormSheet;
        navigator.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController.tabBarController presentViewController:navigator animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
}

#pragma mark - Filter button actions

- (BOOL)checkIfFilterIsActive:(NSString *)filter
{
    for (NSString *testFilter in upperActiveFilters) {
        if ([testFilter isEqualToString:filter]) {
            return YES;
        }
    }
    for (NSString *testFilter in lowerActiveFilters) {
        if ([testFilter isEqualToString:filter]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeFilter:(NSString *)filter
{
    NSString *removeObject = nil;
    for (NSString *activeFilter in upperActiveFilters) {
        if ([activeFilter isEqualToString:filter]) {
            removeObject = activeFilter;
            break;
        }
    }
    if (removeObject != nil) {
        [upperActiveFilters removeObject:removeObject];
        return;
    }
    for (NSString *activeFilter in lowerActiveFilters) {
        if ([activeFilter isEqualToString:filter]) {
            removeObject = activeFilter;
            break;
        }
    }
    if (removeObject != nil) {
        [lowerActiveFilters removeObject:removeObject];
    }
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
    
    BOOL setFilterActive = ![self checkIfFilterIsActive:filter];
    if (setFilterActive) {
        button.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1];
        label.alpha = 1;
        image.alpha = 1;
        [filterList addObject:filter];
    } else {
        button.backgroundColor = [UIColor colorWithWhite:0.13 alpha:1];
        label.alpha = 0.3;
        image.alpha = 0.3;
        [self removeFilter:filter];
    }
    
    [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"List"
                                                       withAction:@"Toggle filter"
                                                        withLabel:filter
                                                        withValue:@(setFilterActive)];
    
    // NSLog(@"filters: %@, %@", upperActiveFilters, lowerActiveFilters);
    
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

- (IBAction)orderChoiceChanged:(UISegmentedControl *)sender
{
    NSString *order = @[@"name", @"distance", @"opening hours"][sender.selectedSegmentIndex];
    [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"List"
                                                       withAction:@"Change order"
                                                        withLabel:order
                                                        withValue:nil];
    
    [self filterRestaurants];
}

- (IBAction)maxDistanceChanged:(NYSliderPopover *)sender
{
    CGFloat maxDistanceInKm = pow(10, (sender.value));
    maxDistance = maxDistanceInKm * 1000;
    sender.popover.textLabel.text = [NSString stringWithFormat:(maxDistanceInKm < 10) ? @"< %.1f km" : @"< %.0f km", maxDistanceInKm];
    [self filterRestaurants];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameConverted = [self.navigationController.tabBarController.view convertRect:keyboardFrame fromView:self.view.window];
    keyboardHeight = keyboardFrameConverted.size.height;
    
    self.tableView.height = self.view.height - keyboardHeight + 50;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView setContentOffset:CGPointMake(0, (kIsiPad) ? 0 : self.listHeader.searchBar.y + 1) animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.tableView.height = self.view.height;
    
    for (UIView *view in searchBar.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            ((UIControl *) view).enabled = YES;
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterRestaurants];
    [self.tableView setContentOffset:CGPointMake(0, (kIsiPad) ? 0 : self.listHeader.searchBar.y + 1) animated:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearch];
}

@end