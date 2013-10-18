//
//  JAInsetLabel.m
//  Beacons
//
//  Created by Jeff Ames on 10/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "JAInsetLabel.h"

@implementation JAInsetLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.edgeInsets);
    [super drawTextInRect:insetRect];
}


@end
