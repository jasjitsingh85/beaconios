//
//  LoadingIndictor.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoadingIndictor : NSObject

+ (void)showLoadingIndicatorInView:(UIView *)view animated:(BOOL)animated;

+ (void)hideLoadingIndicatorForView:(UIView *)view animated:(BOOL)animated;

@end
