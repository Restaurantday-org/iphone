//
//  RestaurantCluster.m
//  RestaurantDay
//
//  Created by Janne Käki on 15/08/14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "RestaurantCluster.h"

#import "Restaurant.h"

@interface RestaurantCluster ()

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSArray *restaurants;

@end

@implementation RestaurantCluster

+ (instancetype)clusterWithRestaurants:(NSArray *)restaurants
{
    RestaurantCluster *cluster = [RestaurantCluster new];
    
    cluster.restaurants = restaurants;
    
    double latitudeSum = 0;
    double longitudeSum = 0;
    for (Restaurant *restaurant in restaurants) {
        latitudeSum += restaurant.coordinate.latitude;
        longitudeSum += restaurant.coordinate.longitude;
    }
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitudeSum / restaurants.count;
    coordinate.longitude = longitudeSum / restaurants.count;
    cluster.coordinate = coordinate;
    
    return cluster;
}

- (NSString *)title
{
    return nil;
}

@end
