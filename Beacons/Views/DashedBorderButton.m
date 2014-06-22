//
//  DashedBorderButton.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DashedBorderButton.h"

@interface DashedBorderButton()

@end

@implementation DashedBorderButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    _border = [CAShapeLayer layer];
    _border.lineWidth = 2;
    _border.strokeColor = [UIColor colorWithWhite:204/255.0 alpha:1.0].CGColor;
    _border.fillColor = nil;
    _border.lineDashPattern = @[@6, @6];
    [self.layer addSublayer:_border];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _border.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    _border.frame = self.bounds;
}


@end
