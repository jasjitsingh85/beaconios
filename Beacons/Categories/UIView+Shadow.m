//
//  UIView+Shadow.m
//  Beacons
//
//  Created by Jeff Ames on 10/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "UIView+Shadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shadow)


- (void)setShadowWithColor:(UIColor *)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset shouldDrawPath:(BOOL)shouldDrawPath
{
    UIBezierPath *path = shouldDrawPath ? [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius] : nil;
    [self setShadowWithColor:color opacity:opacity radius:radius offset:offset path:path];
    
}

- (void)setShadowWithColor:(UIColor *)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset path:(UIBezierPath *)path
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
    if (path) {
        self.layer.shadowPath = path.CGPath;
    }
    else {
        self.layer.shadowPath = nil;
    }
}

@end
