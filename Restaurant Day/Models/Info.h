//
//  Info.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Info : NSObject

@property (nonatomic, strong) NSDate *nextDate;
@property (nonatomic, strong) NSArray *bulletins;

+ (Info *)infoFromJson:(NSString *)json;

@end
