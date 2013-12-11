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
    button.frame = CGRectMake(0, 0, 50, 30);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 4;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    button.titleLabel.font = [ThemeManager regularFontOfSize:12];
    return button;
}

@end
