//
//  UIView+Extras.m
//  Restaurant Day
//
//  Created by Janne Käki on 1/14/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "UIView+Extras.h"

@implementation UIView (Extras)

@dynamic x, y, width, height;

- (NSInteger)x
{
    return self.frame.origin.x;
}

- (void)setX:(NSInteger)x
{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (NSInteger)y
{
    return self.frame.origin.y;
}

- (void)setY:(NSInteger)y
{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (NSInteger)width
{
    return self.frame.size.width;
}

- (void)setWidth:(NSInteger)width
{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (NSInteger)height
{
    return self.frame.size.height;
}

- (void)setHeight:(NSInteger)height
{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

@end
