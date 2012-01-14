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
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"RestaurantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    Restaurant *restaurant = [restaurants objectAtIndex:indexPath.row];
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = restaurant.address;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    RestaurantViewController *companyViewController = [[RestaurantViewController alloc] init];
    companyViewController.restaurant = [restaurants objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:companyViewController animated:YES];
}

@end
