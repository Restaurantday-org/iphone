//
//  Extras.h
//  Restaurant Day
//
//  Created by Janne Käki on 1/20/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IS_IOS_7_OR_LATER (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))

NSArray *rd_map(NSArray *array, id (^function)(id object, NSInteger index));
NSArray *rd_filter(NSArray *array, BOOL (^function)(id object));

@interface NSObject (Extras)

+ (instancetype)cast:(id)object;

@end

@interface NSDate (Extras)

+ (NSDate *)dateFromTimestampString:(NSString *)string;

@end

@interface NSDateFormatter (Extras)

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format;

@end

@interface NSDictionary (Extras)

- (NSArray *)arrayForKey:(id)key;
- (NSDictionary *)dictionaryForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (double)doubleForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (NSDate *)dateForKey:(id)key;

@end

@interface UIView (Extras)

@property (assign) NSInteger x;
@property (assign) NSInteger y;
@property (assign) NSInteger width;
@property (assign) NSInteger height;

@end