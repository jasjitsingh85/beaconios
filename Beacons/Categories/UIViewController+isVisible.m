//
//  UIViewController+isVisible.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/31/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "UIViewController+isVisible.h"

@implementation UIViewController (isVisible)

- (BOOL)isVisible
{
    return self.isViewLoaded && self.view.window;
}

@end
