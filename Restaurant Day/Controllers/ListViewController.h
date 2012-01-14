//
//  ListViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantListHeader.h"

@interface ListViewController : UITableViewController <UITableViewDelegate> {
    
    NSMutableArray *restaurants;
    BOOL displaysOnlyFavorites;

    NSMutableArray *visibleRestaurants;
    RestaurantListHeader *listHeader;
    NSMutableArray *activeFilters;
}

- (id)initWithStyle:(UITableViewStyle)style displayOnlyFavorites:(BOOL)onlyFavorites;

@property (strong) NSArray *restaurants;
@property (readonly) BOOL displaysOnlyFavorites;

@end
