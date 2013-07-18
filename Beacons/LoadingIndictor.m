//
//  LoadingIndictor.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LoadingIndictor.h"

@implementation LoadingIndictor

+ (MBProgressHUD *)showLoadingIndicatorInView:(UIView *)view animated:(BOOL)animated
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:animated];
    hud.labelText = @"Loading...";
    return hud;
}

+ (void)hideLoadingIndicatorForView:(UIView *)view animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:animated];
    });
}

@end
