//
//  LoadingIndictor.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LoadingIndictor.h"
#import "Theme.h"

@implementation LoadingIndictor

+ (MBProgressHUD *)showLoadingIndicatorInView:(UIView *)view animated:(BOOL)animated
{
    MBProgressHUD *progressOverlay = [MBProgressHUD showHUDAddedTo:view animated:animated];
    progressOverlay.tintColor = [[ThemeManager sharedTheme] darkBlueColor];
    return progressOverlay;
}

+ (void)hideLoadingIndicatorForView:(UIView *)view animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:animated];
    });
}

@end
