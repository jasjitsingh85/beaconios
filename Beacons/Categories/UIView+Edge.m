//
//  UIView+Edge.m
//  ZipDigs
//
//  Created by Jeffrey Ames on 3/10/14.
//  Copyright (c) 2014 ZipDigs. All rights reserved.
//

#import "UIView+Edge.h"

@interface EdgeView : UIView

@property (assign, nonatomic) UIRectEdge edge;

@end

@implementation UIView (Edge)

- (void)addEdge:(UIRectEdge)edge width:(CGFloat)width color:(UIColor *)color
{
    [self removeEdge:edge];
    UIRectEdge left = edge & UIRectEdgeLeft;
    UIRectEdge right = edge & UIRectEdgeRight;
    UIRectEdge top = edge & UIRectEdgeTop;
    UIRectEdge bottom = edge & UIRectEdgeBottom;
    if (left) {
        [self addLeftEdge:width color:color];
    }
    if (right) {
        [self addRightEdge:width color:color];
    }
    if (top) {
        [self addTopEdge:width color:color];
    }
    if (bottom) {
        [self addBottomEdge:width color:color];
    }
}

- (void)addLeftEdge:(CGFloat)width color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(width, self.bounds.size.height);
    resizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)addRightEdge:(CGFloat)width color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(width, self.bounds.size.height);
    frame.origin.x = self.bounds.size.width - frame.size.width;
    resizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)addTopEdge:(CGFloat)width color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.bounds.size.width, width);
    resizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)addBottomEdge:(CGFloat)width color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.bounds.size.width, width);
    frame.origin.y = self.bounds.size.height - frame.size.height;
    resizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)removeEdge:(UIRectEdge)edge
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[EdgeView class]]) {
            EdgeView *edgeView = (EdgeView *)view;
            if (edgeView.edge & edge) {
                [view removeFromSuperview];
            }
        }
    }
}

- (void)removeAllEdges
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[EdgeView class]]) {
                [view removeFromSuperview];
        }
    }
}

@end

@implementation EdgeView


@end


