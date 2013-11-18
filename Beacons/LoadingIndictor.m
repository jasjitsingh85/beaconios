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

+ (MRProgressOverlayView *)showLoadingIndicatorInView:(UIView *)view animated:(BOOL)animated
{
    MRProgressOverlayView *progressOverlay = [MRProgressOverlayView showOverlayAddedTo:view animated:animated];
    progressOverlay.tintColor = [[ThemeManager sharedTheme] darkBlueColor];
    progressOverlay.titleLabelText = @"Loading...";
    return progressOverlay;
}

+ (void)hideLoadingIndicatorForView:(UIView *)view animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MRProgressOverlayView dismissOverlayForView:view animated:animated];
    });
}

@end
