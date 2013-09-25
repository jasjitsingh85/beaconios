//
//  InsetTextField.m
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "InsetTextField.h"

@implementation InsetTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.horizontalInset = 0;
        self.verticalInset = 0;
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.horizontalInset, self.verticalInset);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.horizontalInset, self.verticalInset);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.horizontalInset, self.verticalInset);
}

@end
