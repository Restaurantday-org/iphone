//
//  Definitions.h
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import "Extras.h"

#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// URLs

#define kURLForRestaurantsWithCenterAndDistanceKm @"http://api.restaurantday.org/mobileapi/restaurants?lat=%f&lon=%f&maxDistanceKm=%ld"
#define kURLForRestaurantsByIdListWithCoordinates @"http://api.restaurantday.org/mobileapi/restaurants/%@?lat=%f&lon=%f"
#define kURLForRestaurantById                     @"http://api.restaurantday.org/mobileapi/restaurant/%@"
#define kURLForInfo                               @"http://api.restaurantday.org/mobileapi/info"

// User Defaults Keys

#define kHasLaunchedBefore @"hasLaunchedBefore"

/// Whatever expression is wrapped within this macro, is never evaluated at
/// runtime (but still checked at compile time). Useful for avoiding "unused"
/// argument warnings.
#define RD_UNUSED(...) ((void)sizeof((__VA_ARGS__),0))

/// Suppress logging for App Store builds
#if !defined(DEBUG)
#define NSLog(...) RD_UNUSED(__VA_ARGS__)
#endif