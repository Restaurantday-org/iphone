//
//  ListViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantListHeader.h"
#import "RestaurantDataProvider.h"
#import <MapKit/MKUserLocation.h>
#import "GAI.h"

@interface ListViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, RestaurantDataProviderDelegate> {
    
    NSMutableArray *restaurants;
    BOOL displaysOnlyCurrentlyOpen;

    NSMutableArray *visibleRestaurants;
    NSMutableArray *upperActiveFilters;
    NSMutableArray *lowerActiveFilters;
    
    RestaurantDataProvider *dataProvider;
    
    CLLocation *location;
    
    BOOL wasRestaurantDayWhenHeaderWasLoaded;
}

- (void)addRestaurants:(NSArray *)newRestaurants;
- (void)clearRestaurants;

@property (assign) BOOL displaysOnlyFavorites;

@property (strong) UITableView *tableView;
@property (strong) RestaurantListHeader *listHeader;
@property (strong) UISegmentedControl *orderChooser;

@end
