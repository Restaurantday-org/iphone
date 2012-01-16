//
//  Bulletin.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bulletin : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic, strong) NSDate *date;

@end
