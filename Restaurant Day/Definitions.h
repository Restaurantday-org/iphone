//
//  Definitions.h
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// URLs

#define kURLForRestaurantsWithCenterAndDistanceKm @"http://api.restaurantday.org/mobileapi/restaurants?lat=%f&lon=%f&maxDistanceKm=%ld"
#define kURLForRestaurantsByIdListWithCoordinates @"http://api.restaurantday.org/mobileapi/restaurants/%@?lat=%f&lon=%f"
#define kURLForRestaurantById                     @"http://api.restaurantday.org/mobileapi/restaurant/%@"
#define kURLForInfo                               @"http://api.restaurantday.org/mobileapi/info"

// User Defaults Keys

#define kHasLaunchedBefore @"hasLaunchedBefore"