//
//  Restaurant_DayTests.m
//  Restaurant DayTests
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Restaurant_DayTests.h"
#import "RestaurantParser.h"
#import "Restaurant.h"

@implementation Restaurant_DayTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testRestaurantParser
{
    RestaurantParser *parser = [[RestaurantParser alloc] init];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"restaurants" ofType:@"json"];
    NSString *json = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *restaurants = [parser createArrayFromRestaurantJson:json];
    
    STAssertTrue(restaurants.count == 3, @"Wrong restaurant count, was: %d, should have been 3", restaurants.count);
    
    Restaurant *restaurant = [restaurants objectAtIndex:2];
    STAssertTrue([restaurant.name isEqualToString:@"Matti's Rasta-Pasta"], @"Restaurant name was: %@, should have been: Matti's Rasta-Pasta", restaurant.name);
    STAssertTrue([restaurant.address isEqualToString:@"Itälahdenkatu 14"], @"Restaurant address was: %@, should have been: Itälahdenkatu 14", restaurant.address);
    STAssertEquals(restaurant.restaurantId, 1450, @"Wrong restaurant id");
    STAssertEqualsWithAccuracy(restaurant.coordinates.latitude, 60.15193, 0.00001, @"Wrong restaurant latitude");
    STAssertEqualsWithAccuracy(restaurant.coordinates.longitude, 24.881111, 0.00001, @"Wrong restaurant longitude");
    STAssertTrue([restaurant.venue isEqualToString:@"home"], @"Restaurant venue was: %@, should have been: home", restaurant.venue);
    STAssertTrue([restaurant.type isEqualToString:@"restaurant"], @"Restaurant type was: %@, should have been: restaurant", restaurant.type);
    STAssertEquals(restaurant.openingSeconds, 50400, @"Wrong opening seconds");
    STAssertEquals(restaurant.closingSeconds, 72000, @"Wrong closing seconds");
}

@end
