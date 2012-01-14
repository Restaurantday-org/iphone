//
//  RestaurantDataProvider.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantDataProvider.h"
#import "Restaurant.h"

@implementation RestaurantDataProvider

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
    }
    return self;
}

- (void)startLoadingRestaurantsBetweenMinLat:(CLLocationDegrees)minLat maxLat:(CLLocationDegrees)maxLat minLon:(CLLocationDegrees)minLon maxLon:(CLLocationDegrees)maxLon
{
    /*ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://golf-174.srv.hosting.fi/mobileapi/restaurants.php"]];
    [queue addOperation:request];
    [queue go];*/
    
    // Dummy data for now
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    Restaurant *firstRestaurant = [[Restaurant alloc] init];
    firstRestaurant.name = @"Eka rafla";
    firstRestaurant.coordinates = CLLocationCoordinate2DMake(60.154343, 24.886887);
    firstRestaurant.description = @"Awesomest ravintola";
    firstRestaurant.address = @"Vattuniemenranta 2";
    firstRestaurant.openingTime = [dateFormatter dateFromString:@"2012-01-14 14:00"];
    firstRestaurant.closingTime = [dateFormatter dateFromString:@"2012-01-14 20:00"];
    [returnArray addObject:firstRestaurant];
    
    Restaurant *secondRestaurant = [[Restaurant alloc] init];
    secondRestaurant.name = @"Toka rafla";
    secondRestaurant.coordinates = CLLocationCoordinate2DMake(60.160856, 24.915276);
    secondRestaurant.description = @"Toiseksi awesomein rafla";
    secondRestaurant.address = @"Kinaporinkatu 1";
    secondRestaurant.openingTime = [dateFormatter dateFromString:@"2012-01-14 16:00"];
    secondRestaurant.closingTime = [dateFormatter dateFromString:@"2012-01-14 22:00"];
    [returnArray addObject:secondRestaurant];
    
    [delegate gotRestaurants:returnArray];
    
}

@end
