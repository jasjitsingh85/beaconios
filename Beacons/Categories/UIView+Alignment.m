//
//  UIView+Alignment.m
//  QuadStreaker
//
//  Created by Jeff Ames on 9/18/13.
//  Copyright (c) 2013 Quadstreaker, Inc. All rights reserved.
//

#import "UIView+Alignment.h"

@implementation UIView (Alignment)

- (void)centerInSuperView
{
    if (!self.superview) {
        return;
    }
    CGPoint center;
    center.x = 0.5*self.superview.frame.size.width;
    center.y = 0.5*self.superview.frame.size.height;
    self.center = center;
}

- (void)centerHorizontallyInSuperView
{
    if (!self.superview) {
        return;
    }
    CGPoint center = self.center;
    center.x = 0.5*self.superview.frame.size.width;
    self.center = center;
}

- (void)centerVerticallyInSuperView
{
    if (!self.superview) {
        return;
    }
    CGPoint center = self.center;
    center.y = 0.5*self.superview.frame.size.height;
    self.center = center;
}

@end
