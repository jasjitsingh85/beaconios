//
//  RegistrationFlowViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 2/4/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "RegistrationFlowViewController.h"
//#import "IntroWalkthroughViewController.h"
#import "RegisterViewController.h"

@interface RegistrationFlowViewController ()

@end

@implementation RegistrationFlowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.walkthroughViewController = [[IntroWalkthroughViewController alloc] init];
//    [self addChildViewController:self.walkthroughViewController];
//    [self.view addSubview:self.walkthroughViewController.view];
    
    self.registerViewController = [[RegisterViewController alloc] init];
    [self addChildViewController:self.registerViewController];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
//    [self.walkthroughViewController.registerButton addTarget:self action:@selector(transitionToRegisterView) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)registerButtonTouched
{
    
}

- (void)signInButtonTouched
{
    
}

//- (void)transitionToRegisterView
//{
////    self.registerViewController.view.alpha = 0;
//    self.registerViewController.view.transform = CGAffineTransformMakeTranslation(self.registerViewController.view.frame.size.width, 0);
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    //[self transitionFromViewController:self.walkthroughViewController toViewController:self.registerViewController duration:0.25 options:0 animations:^{
//        self.registerViewController.view.transform = CGAffineTransformIdentity;
//        self.walkthroughViewController.view.transform = CGAffineTransformMakeTranslation(-self.walkthroughViewController.view.frame.size.width, 0);
//    } completion:^(BOOL finished) {
//        self.walkthroughViewController.view.transform = CGAffineTransformIdentity;
//    }];
//}

//- (void)finishedWalkthrough:(IntroWalkthroughViewController *)introWalkthroughViewController
//{
//    [self transitionToRegisterView];
//}

@end
