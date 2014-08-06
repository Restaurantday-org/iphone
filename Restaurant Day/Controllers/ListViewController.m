//
//  ListViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "ListViewController.h"
#import "Restaurant.h"
#import "RestaurantViewController.h"
#import "AppDelegate.h"

#define kOrderChoiceIndexName         0
#define kOrderChoiceIndexDistance     1
#define kOrderChoiceIndexOpeningHours 2

@interface ListViewController () {
    NSInteger maxCountOfClosestRestaurants;
    NSInteger keyboardHeight;
    BOOL searching;
}

- (void)showOnlyOpenButtonPressed;
- (void)toggleShowOnlyOpenFilter;
- (void)filterRestaurants;
- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant;

@property (nonatomic) NSArray *restaurants;

@end

@implementation ListViewController

- (void)reloadData
{
    maxCountOfClosestRestaurants = 50;
    
    if (self.displaysOnlyFavorites) {
        self.restaurants = [self.dataSource favoriteRestaurants];
    } else {
        NSMutableArray *restaurants = [NSMutableArray array];
        NSArray *allRestaurantsSortedByDistance = [[self.dataSource allRestaurants] sortedArrayUsingFunction:compareRestaurantsByDistance context:NULL];
        for (Restaurant *restaurant in allRestaurantsSortedByDistance) {
            if (restaurants.count < maxCountOfClosestRestaurants) {
                [restaurants addObject:restaurant];
            } else {
                break;
            }
        }
        self.restaurants = restaurants;
    }
    
    [self filterRestaurants];
}

- (void)filterRestaurants
{
    NSInteger previousVisibleCount = visibleRestaurants.count;
    
    visibleRestaurants = [[NSMutableArray alloc] init];
    if (!self.displaysOnlyFavorites) {
        for (Restaurant *restaurant in self.restaurants) {
            if ([self shouldShowRestaurant:restaurant]) {
                [visibleRestaurants addObject:restaurant];
            }
        }
    } else {
        [visibleRestaurants addObjectsFromArray:self.restaurants];
        // NSLog(@"visibleRestaurants: %@", visibleRestaurants);
    }
    
    if (self.orderChooser.selectedSegmentIndex == kOrderChoiceIndexName) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByName context:NULL];
    } else if (self.orderChooser.selectedSegmentIndex == kOrderChoiceIndexDistance) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByDistance context:NULL];
    } else if (self.orderChooser.selectedSegmentIndex == kOrderChoiceIndexOpeningHours) {
        [visibleRestaurants sortUsingFunction:compareRestaurantsByOpeningTime context:NULL];
    }
    
    if (previousVisibleCount != visibleRestaurants.count) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
        
    NSInteger contentHeight = 88 * visibleRestaurants.count;
    NSInteger availableHeight = (self.tableView.height - self.listHeader.height + self.listHeader.searchBar.y);
    if (searching &&
            contentHeight > 0 &&
            contentHeight < availableHeight) {
        
        self.tableView.tableFooterView = [[UIView alloc] init];
        self.tableView.tableFooterView.height = availableHeight - contentHeight;
        
    } else if (self.restaurants.count == maxCountOfClosestRestaurants && !self.displaysOnlyFavorites) {
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = NSLocalizedString(@"List.NoMoreResults", @"");
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont boldSystemFontOfSize:13];
        label.backgroundColor = [UIColor clearColor];
        CGSize labelSize = [label sizeThatFits:CGSizeMake(self.tableView.width - 40, 100)];
        label.frame = CGRectMake((self.tableView.width - labelSize.width) / 2, 20, labelSize.width, labelSize.height);
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, labelSize.height + 40)];
        [footer addSubview:label];
        self.tableView.tableFooterView = footer;
        
    } else {
        
        self.tableView.tableFooterView = nil;
    }
}

- (BOOL)shouldShowRestaurant:(Restaurant *)restaurant
{
    if (searching) {
        NSString *search = self.listHeader.searchBar.text;
        if (search.length > 0 &&
            ([restaurant.name rangeOfString:search options:NSCaseInsensitiveSearch].location == NSNotFound) &&
            ([restaurant.shortDesc rangeOfString:search options:NSCaseInsensitiveSearch].location == NSNotFound) &&
            ([restaurant.fullAddress rangeOfString:search options:NSCaseInsensitiveSearch].location == NSNotFound)) {
            return NO;
        }
    }
    
    if (self.displaysOnlyFavorites) {
        return restaurant.favorite;
    }
    
    if (displaysOnlyCurrentlyOpen && (!searching || kIsiPad)) {
        // since the checkbox is not visible on iPhone when searching, we ignore it
        if (!restaurant.isOpen) {
            return NO;
        }
    }
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    keyboardHeight = 216;
    
    self.screenName = (self.displaysOnlyFavorites) ? @"Favorites" : @"List";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.height - 20) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    NSArray *orderChoices = [NSArray arrayWithObjects:NSLocalizedString(@"List.Order.ByName", @""), NSLocalizedString(@"List.Order.ByDistance", @""), NSLocalizedString(@"List.Order.ByOpeningHours", @""), nil];
    self.orderChooser = [[UISegmentedControl alloc] initWithItems:orderChoices];
    self.orderChooser.tintColor = [UIColor grayColor];
    [self.orderChooser addTarget:self action:@selector(orderChoiceChanged:) forControlEvents:UIControlEventValueChanged];
            
    if (self.displaysOnlyFavorites) {
        self.orderChooser.selectedSegmentIndex = kOrderChoiceIndexOpeningHours;
    } else {
        self.orderChooser.selectedSegmentIndex = kOrderChoiceIndexDistance;
    }
    
    UIView *header;
    if (!self.displaysOnlyFavorites) {
        
        RestaurantListHeader *listHeader = [RestaurantListHeader newInstance];
        
        [listHeader.showOnlyOpenButton addTarget:self action:@selector(showOnlyOpenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        listHeader.showOnlyOpenLabel.text = NSLocalizedString(@"Filters.ShowOnlyOpen", nil);
                
        listHeader.searchBar.delegate = self;
        listHeader.searchBar.alpha = (kIsiPad) ? 1 : 0.7;
        
        listHeader.searchBar.tintColor = [UIColor whiteColor];
        listHeader.searchBar.barTintColor = listHeader.backgroundColor;
                
        [listHeader.searchButton addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
        
        [listHeader.cancelSearchButton addTarget:self action:@selector(hideSearch) forControlEvents:UIControlEventTouchUpInside];
        
        self.listHeader = listHeader;
        header = listHeader;
        
    } else {
        
        self.listHeader = nil;
        header = [[UIView alloc] init];
        header.backgroundColor = [UIColor colorWithWhite:33/255.0 alpha:1];
        header.frame = CGRectMake(0, 0, self.view.width, 44);
    }
    
    self.orderChooser.frame = CGRectMake(10, header.height - 37, header.width - 20, 30);
    self.orderChooser.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.orderChooser.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [header addSubview:self.orderChooser];
        
    self.tableView.tableHeaderView = header;
    
    self.navigationItem.titleView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL todayIsRestaurantDay = [AppDelegate todayIsRestaurantDay];
    self.listHeader.showOnlyOpenCheckbox.alpha = (todayIsRestaurantDay) ? 1 : 0.3;
    self.listHeader.showOnlyOpenLabel.alpha = (todayIsRestaurantDay) ? 1 : 0.3;
    
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)showSearch
{
    searching = YES;
    
    [self.listHeader.searchBar becomeFirstResponder];
    
    self.listHeader.searchBar.placeholder = NSLocalizedString(@"Search.Placeholder", @"");
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listHeader.searchBar.alpha = 1;
        self.listHeader.searchButton.alpha = 0;
        self.listHeader.searchBar.x = (kIsiPad) ? (self.view.bounds.size.width - self.listHeader.searchBar.width - 6) : 0;
        self.listHeader.searchButton.x = self.listHeader.searchBar.x;
        self.listHeader.showOnlyOpenView.alpha = 0;
        self.listHeader.cancelSearchButton.alpha = 1;
    }];
    
    self.listHeader.searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.listHeader.searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self filterRestaurants];
}

- (IBAction)hideSearch
{
    searching = NO;
    
    self.listHeader.searchBar.text = nil;
    
    [self.listHeader.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listHeader.cancelSearchButton.alpha = 0;
    }];
    
    if (!kIsiPad) {
        [UIView animateWithDuration:0.3 animations:^{
            self.listHeader.searchBar.alpha = 0.7;
            self.listHeader.searchButton.alpha = 1;
            self.listHeader.searchBar.x = (kIsiPad) ? (self.view.bounds.size.width - 60) : self.view.width - 42;
            self.listHeader.searchButton.x = self.listHeader.searchBar.x;
            self.listHeader.showOnlyOpenView.alpha = 1;
        } completion:^(BOOL finished) {
            self.listHeader.searchBar.placeholder = nil;
        }];
        
        self.listHeader.searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.listHeader.searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    
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
        noResultsCell.textLabel.textAlignment = NSTextAlignmentCenter;
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
    return (self.displaysOnlyFavorites && visibleRestaurants.count == 0) ? 120 : 0;
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
    
    for (NSInteger hour = 4; hour <= 26; hour += 1) {
        
        NSInteger hourX = [RestaurantCell xForTimestamp:(hour * 60 * 60) withCellWidth:tableView.width];
        
        if (hour % 3 == 0) {
            UILabel *hourLabel = [[UILabel alloc] init];
            hourLabel.frame = CGRectMake(0, 0, 30, 18);
            hourLabel.font = [UIFont boldSystemFontOfSize:11];
            hourLabel.text = [NSString stringWithFormat:@"%ld", (long) hour];
            hourLabel.textAlignment = NSTextAlignmentCenter;
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
    if (self.displaysOnlyFavorites && visibleRestaurants.count == 0) {
        
        UIView *footer = [[UIView alloc] init];
        footer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
        
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.frame = CGRectMake(15, 20, footer.width - 30, 20);
        footerLabel.font = [UIFont boldSystemFontOfSize:14];
        footerLabel.textColor = [UIColor lightGrayColor];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        footerLabel.numberOfLines = 0;
        footerLabel.text = NSLocalizedString(@"Favorites.NoFavorites.Title", @"");
        [footer addSubview:footerLabel];
        
        UILabel *footerSubLabel = [[UILabel alloc] init];
        footerSubLabel.frame = CGRectMake(15, 40, footer.width - 30, 70);
        footerSubLabel.font = [UIFont systemFontOfSize:14];
        footerSubLabel.textColor = [UIColor lightGrayColor];
        footerSubLabel.backgroundColor = [UIColor clearColor];
        footerSubLabel.textAlignment = NSTextAlignmentCenter;
        footerSubLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
        
        UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:restaurantViewController];
        navigator.modalPresentationStyle = UIModalPresentationFormSheet;
        navigator.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController.tabBarController presentViewController:navigator animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
}

- (void)toggleShowOnlyOpenFilter
{
    if (![AppDelegate todayIsRestaurantDay]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Filter.ShowOnlyOpen.NotToday", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Buttons.OK", @"") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    displaysOnlyCurrentlyOpen = !displaysOnlyCurrentlyOpen;
    
    if (displaysOnlyCurrentlyOpen) {
        self.listHeader.showOnlyOpenCheckbox.image = [UIImage imageNamed:@"checkbox-checked"];
    } else {
        self.listHeader.showOnlyOpenCheckbox.image = [UIImage imageNamed:@"checkbox-unchecked"];
    }
    
    [self filterRestaurants];
}

- (void)showOnlyOpenButtonPressed
{
    [self toggleShowOnlyOpenFilter];
}

- (IBAction)orderChoiceChanged:(UISegmentedControl *)sender
{
    NSString *order = @[@"name", @"distance", @"opening hours"][sender.selectedSegmentIndex];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"List"
                                                          action:@"Change order"
                                                           label:order
                                                           value:nil] build]];
    
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
    if (kIsiPad) {
        searching = (searchText.length > 0);
    }
    
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

@implementation RestaurantListHeader

+ (RestaurantListHeader *)newInstance
{
    NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"NewRestaurantListHeader_iPhone" : @"NewRestaurantListHeader_iPad";
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    return nibs.firstObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIButton *cancelSearchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelSearchButton.frame = CGRectMake(255, 0, 60, 44);
    [cancelSearchButton setTitle:NSLocalizedString(@"Buttons.Cancel", nil) forState:UIControlStateNormal];
    cancelSearchButton.titleLabel.font = [UIFont systemFontOfSize:14];
    cancelSearchButton.tintColor = [UIColor lightGrayColor];
    [self.searchBar addSubview:cancelSearchButton];
    self.cancelSearchButton = cancelSearchButton;
}

@end

@implementation RestaurantCell

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

- (void)setRestaurant:(Restaurant *)restaurant
{
    _restaurant = restaurant;
    
    self.nameLabel.text = restaurant.name;
    self.descriptionLabel.text = restaurant.shortDesc;
    self.timeLabel.text = restaurant.openingHoursText;
    self.addressLabel.text = restaurant.address;
    self.distanceLabel.text = restaurant.distanceText;
    
    NSInteger addressWidth = [self.addressLabel sizeThatFits:CGSizeMake(320, 320)].width;
    if (addressWidth > 160) { addressWidth = 160; }
    self.addressLabel.width = addressWidth;
    
    [self.restaurantTypesView removeFromSuperview];
    self.restaurantTypesView = [[UIView alloc] init];
    
    NSInteger typeViewSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        typeViewSize = 12;
        self.restaurantTypesView.frame = CGRectMake(self.addressLabel.x + self.addressLabel.width + 12,
                                                    self.addressLabel.y + 4,
                                                    restaurant.type.count * (typeViewSize + 1),
                                                    typeViewSize);
    } else {
        typeViewSize = 30;
        NSInteger totalWidth = restaurant.type.count * (typeViewSize + 1);
        self.restaurantTypesView.frame = CGRectMake(self.width - totalWidth - 76,
                                                    (self.height - typeViewSize) / 2,
                                                    totalWidth,
                                                    typeViewSize);
        self.restaurantTypesView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    [self addSubview:self.restaurantTypesView];
    
    for (NSInteger i = 0; i < restaurant.type.count; i++) {
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
            (self.restaurantTypesView.x + i * (typeViewSize + 1) >= self.distanceLabel.x)) {
            break;
        }
        NSString *type = [restaurant.type objectAtIndex:i];
        UIImage *typeIcon = [UIImage imageNamed:[NSString stringWithFormat:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"icon-%@" : @"bigicon-%@", type]];
        UIImageView *typeIconView = [[UIImageView alloc] initWithImage:typeIcon];
        typeIconView.frame = CGRectMake(i * (typeViewSize + 1), 0, typeViewSize, typeViewSize);
        typeIconView.alpha = 0.9;
        [self.restaurantTypesView addSubview:typeIconView];
    }
    
    self.timeIndicator.x = [self.class xForTimestamp:restaurant.openingSeconds withCellWidth:self.width];
    self.timeIndicator.width = [self.class xForTimestamp:restaurant.closingSeconds withCellWidth:self.width] - self.timeIndicator.x;
    
    // NSInteger currentSeconds = (NSInteger) [NSDate timeIntervalSinceReferenceDate] % (24*60*60) + (2*60*60);
    
    NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
    [secondFormatter setDateFormat:@"A"];
    NSInteger currentSeconds = [[secondFormatter stringFromDate:[NSDate date]] intValue] / 1000;
    self.currentTimePointer.x = [self.class xForTimestamp:currentSeconds withCellWidth:self.width];
    self.currentTimeDash.x = self.currentTimePointer.x;
    
    BOOL todayIsRestaurantDay = [AppDelegate todayIsRestaurantDay];
    BOOL restaurantIsAlreadyClosed = restaurant.isAlreadyClosed;
    
    if (restaurant.isOpen) {
        
        self.timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        self.timeIndicator.alpha = 1;
        
    } else if (restaurantIsAlreadyClosed) {
        
        self.timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient-gray.png"]];
        self.timeIndicator.alpha = 0.5;
        
    } else {
        
        self.timeIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time-gradient.png"]];
        self.timeIndicator.alpha = 0.5;
    }
    
    self.currentTimePointer.hidden = !(restaurant.isOpen);
    
    self.clockIconView.alpha = (restaurantIsAlreadyClosed) ? 0.4 : 1;
    self.placeIconView.alpha = (restaurantIsAlreadyClosed) ? 0.4 : 1;
    self.restaurantTypesView.alpha = (restaurantIsAlreadyClosed) ? 0.4 : 1;
    
    self.currentTimePointer.hidden = !todayIsRestaurantDay;
    self.currentTimeDash.hidden = !todayIsRestaurantDay;
    
    // NSLog(@"is restaurant day: %d", [AppDelegate todayIsRestaurantDay]);
    self.favoriteIndicator.hidden = !restaurant.favorite;
    
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
    if (self.restaurant.isAlreadyClosed) {
        labelColor = (selected) ? [UIColor whiteColor] : [UIColor lightGrayColor];
    } else {
        labelColor = (selected) ? [UIColor whiteColor] : [UIColor darkTextColor];
    }
    UIColor *shadowColor = (selected) ? [UIColor darkTextColor] : [UIColor whiteColor];
    self.nameLabel.textColor = labelColor;
    self.descriptionLabel.textColor = labelColor;
    self.timeLabel.textColor = labelColor;
    self.addressLabel.textColor = labelColor;
    self.distanceLabel.textColor = labelColor;
    self.timeLabel.shadowColor = shadowColor;
    self.addressLabel.shadowColor = shadowColor;
    
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