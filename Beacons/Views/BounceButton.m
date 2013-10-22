//
//  BounceButton.m
//  Beacons
//
//  Created by Jeff Ames on 10/21/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BounceButton.h"

@implementation BounceButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(bounce) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)bounce
{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end
