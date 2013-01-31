//
//  ListViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantListHeader.h"
#import "RestaurantsDataSource.h"
#import <MapKit/MKUserLocation.h>
#import "GAI.h"

@interface ListViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    BOOL displaysOnlyCurrentlyOpen;

    NSMutableArray *visibleRestaurants;
    NSMutableArray *upperActiveFilters;
    NSMutableArray *lowerActiveFilters;
        
    CLLocation *location;
}

- (void)reloadData;

@property (assign) BOOL displaysOnlyFavorites;

@property (strong) UITableView *tableView;
@property (strong) RestaurantListHeader *listHeader;
@property (strong) UISegmentedControl *orderChooser;

@property (weak, nonatomic) id<RestaurantsDataSource> dataSource;

- (IBAction)showSearch;
- (IBAction)hideSearch;

@end
