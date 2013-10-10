//
//  UIView+Shadow.h
//  Beacons
//
//  Created by Jeff Ames on 10/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shadow)

- (void)setShadowWithColor:(UIColor *)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset shouldDrawPath:(BOOL)shouldDrawPath;
- (void)setShadowWithColor:(UIColor *)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset path:(UIBezierPath *)path;

@end
