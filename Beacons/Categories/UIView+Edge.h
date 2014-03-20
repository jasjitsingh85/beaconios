//
//  UIView+Edge.h
//  ZipDigs
//
//  Created by Jeffrey Ames on 3/10/14.
//  Copyright (c) 2014 ZipDigs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Edge)

- (void)addEdge:(UIRectEdge)edge width:(CGFloat)width color:(UIColor *)color;
- (void)removeEdge:(UIRectEdge)edge;
- (void)removeAllEdges;

@end
