//
//  Extras.m
//  Restaurant Day
//
//  Created by Janne Käki on 1/20/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "Extras.h"

NSArray *rd_map(NSArray *array, id (^function)(id object, NSInteger index))
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:array.count];
    for (NSInteger i = 0; i < array.count; i++) {
        id object = array[i];
        id result = function(object, i);
        if (result) {
            [results addObject:result];
        }
    }
    return results;
}

NSArray *rd_filter(NSArray *array, BOOL (^function)(id object))
{
    NSMutableArray *results = [NSMutableArray array];
    for (id object in array) {
        if (function(object)) {
            [results addObject:object];
        }
    }
    return results;
}

@implementation NSObject (Extras)

+ (instancetype)cast:(id)object
{
    return [object isKindOfClass:self] ? object : nil;
}

@end

@implementation NSDate (Extras)

+ (NSDate *)dateFromTimestampString:(NSString *)string
{
    return [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"] dateFromString:string];
}

@end

@implementation NSDateFormatter (Extras)

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format
{
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = threadDict[format];
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = format;
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        threadDict[format] = formatter;
    }
    return formatter;
}

@end

@implementation NSDictionary (Extras)

- (NSArray *)arrayForKey:(id)key
{
    return [NSArray cast:self[key]];
}

- (NSDictionary *)dictionaryForKey:(id)key
{
    return [NSDictionary cast:self[key]];
}

- (NSString *)stringForKey:(id)key
{
    NSString *string = [NSString cast:self[key]];
    return (string.length) ? string : nil;
}

- (NSInteger)integerForKey:(id)key
{
    return ([self[key] respondsToSelector:@selector(integerValue)]) ? [self[key] integerValue] : 0;
}

- (double)doubleForKey:(id)key
{
    return ([self[key] respondsToSelector:@selector(doubleValue)]) ? [self[key] doubleValue] : 0;
}

- (BOOL)boolForKey:(id)key
{
    return ([self[key] respondsToSelector:@selector(boolValue)]) ? [self[key] boolValue] : NO;
}

- (NSDate *)dateForKey:(id)key
{
    NSString *dateString = [self stringForKey:key];
    return [NSDate dateFromTimestampString:dateString];
}

@end

@implementation UIView (Extras)

@dynamic x, y, width, height;

- (NSInteger)x
{
    return self.frame.origin.x;
}

- (void)setX:(NSInteger)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (NSInteger)y
{
    return self.frame.origin.y;
}

- (void)setY:(NSInteger)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (NSInteger)width
{
    return self.frame.size.width;
}

- (void)setWidth:(NSInteger)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (NSInteger)height
{
    return self.frame.size.height;
}

- (void)setHeight:(NSInteger)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end
