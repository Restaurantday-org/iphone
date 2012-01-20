//
//  NSDictionary+Parsing.m
//  Restaurant Day
//
//  Created by Janne Käki on 1/20/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "NSDictionary+Parsing.h"

@implementation NSDictionary (Parsing)

- (id)objectOrNilForKey:(id)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

@end
