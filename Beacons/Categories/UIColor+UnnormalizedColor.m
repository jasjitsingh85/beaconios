//
//  UIColor+UnnormalizedColor.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "UIColor+UnnormalizedColor.h"

@implementation UIColor (UnnormalizedColor)

+ (UIColor *)unnormalizedColorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

@end
