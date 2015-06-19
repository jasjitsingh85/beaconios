//
//  UIButton+HSNavButton.m
//  Beacons
//
//  Created by Jeffrey Ames on 12/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "UIButton+HSNavButton.h"
#import "Theme.h"

@implementation UIButton (HSNavButton)

+ (id)navButtonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] init];
    button.size = CGSizeMake(40, 25);
    //button.backgroundColor = [UIColor clearColor];
    button.layer.cornerRadius = 2;
    button.layer.borderColor = [[UIColor unnormalizedColorWithRed:167 green:167 blue:167 alpha:255] CGColor];
    button.layer.borderWidth = 1.0;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    button.titleLabel.font = [ThemeManager regularFontOfSize:10];
    return button;
}

@end
