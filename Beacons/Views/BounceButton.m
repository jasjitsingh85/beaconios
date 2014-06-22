//
//  BounceButton.m
//  Beacons
//
//  Created by Jeff Ames on 10/21/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BounceButton.h"
#import "UIView+BounceAnimation.h"

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
    [self bounceWithDuration:0.2 scale:1.2];
}

@end
