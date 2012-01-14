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

- (int)x
{
    return self.frame.origin.x;
}

- (void)setX:(int)x
{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (int)y
{
    return self.frame.origin.y;
}

- (void)setY:(int)y
{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (int)width
{
    return self.frame.size.width;
}

- (void)setWidth:(int)width
{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (int)height
{
    return self.frame.size.height;
}

- (void)setHeight:(int)height
{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

@end
