//
//  UIView+BounceAnimation.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "UIView+BounceAnimation.h"

@implementation UIView (BounceAnimation)

- (void)bounceWithDuration:(NSTimeInterval)duration scale:(CGFloat)scale
{
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end
