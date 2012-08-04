//
//  Definitions.h
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

// URLs

#define kURLForRestaurantsWithCenterAndDistance   @"http://api.restaurantday.org/mobileapi/restaurants?lat=%f&lon=%f&maxDistanceKm=%d"
#define kURLForRestaurantsByIdListWithCoordinates @"http://api.restaurantday.org/mobileapi/restaurants/%@?lat=%f&lon=%f"
#define kURLForRestaurantById                     @"http://api.restaurantday.org/mobileapi/restaurant/%@"
#define kURLForInfo                               @"http://api.restaurantday.org/mobileapi/info"

// Notification Keys

#define kFavoriteAdded   @"favoriteAdded"
#define kFavoriteRemoved @"favoriteRemoved"
#define kLocationUpdated @"locationUpdated"

// User Defaults Keys

#define kHasLaunchedBefore @"hasLaunchedBefore"