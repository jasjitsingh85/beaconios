//
//  RegisterViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ViewModeFacebookRegister,
    ViewModeRegister,
    ViewModeSignIn,
    ViewModeActivation,
} ViewMode;

@interface RegisterViewController : UIViewController

- (void)enterRegisterMode;
- (void)enterSignInMode;

@property (strong, nonatomic) NSDictionary *facebookParams;
@property (assign, nonatomic) BOOL isRegister;
@property (assign, nonatomic) ViewMode viewMode;

@end
