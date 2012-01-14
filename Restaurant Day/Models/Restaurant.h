//
//  Restaurant.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Restaurant : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, unsafe_unretained) CLLocationCoordinate2D coordinates;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *openingTime;
@property (nonatomic, strong) NSDate *closingTime;

@end
