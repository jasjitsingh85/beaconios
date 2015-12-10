//
//  RegistrationFlowViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 1/27/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "IntroViewController.h"
#import "UIImageView+AnimationCompletion.h"
#import "Theme.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface IntroViewController ()



@end

@implementation IntroViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNav"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 25;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    self.facebookRegisterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect registerButtonFrame = CGRectZero;
    registerButtonFrame.size = CGSizeMake(self.view.width, 45);
    registerButtonFrame.origin.x = 0.5*(self.view.frame.size.width - registerButtonFrame.size.width);
    registerButtonFrame.origin.y = self.view.frame.size.height - registerButtonFrame.size.height;
    self.facebookRegisterButton.frame = registerButtonFrame;
    self.facebookRegisterButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.facebookRegisterButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    //self.registerButton.layer.cornerRadius = 4;
    [self.facebookRegisterButton addTarget:self action:@selector(transitionToRegisterWithFacebookView) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookRegisterButton setTitle:@"Facebook!" forState:UIControlStateNormal];
    [self.facebookRegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.facebookRegisterButton.titleLabel.font = [ThemeManager boldFontOfSize:16];
    [self.view addSubview:self.facebookRegisterButton];
}

-(void)transitionToRegisterView
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate startRegistration];
}

-(void)loginButtonClicked
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate startLogin];
}

-(void)transitionToRegisterWithFacebookView
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Facebook registration failed. Please try again or register with an email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             if ([FBSDKAccessToken currentAccessToken]) {
                 NSString *token = [[FBSDKAccessToken currentAccessToken] tokenString];
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id,name,email" forKey:@"fields"];
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      if (!error) {
                          AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                          NSDictionary *parameters = @{@"name" : result[@"name"],
                                                       @"email" : result[@"email"],
                                                       @"facebook_id" : result[@"id"],
                                                       @"facebook_token" : token};
                          [appDelegate startRegistrationWithFacebook:parameters];
                      } else {
                          [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Facebook registration failed. Please try again or register with an email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                      }
                  }];
             } else {
                 [self transitionToRegisterView];
             }
         }
     }];
}

- (void)animateRegisterButton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.facebookRegisterButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.facebookRegisterButton.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                onceToken = 0;
            }];
        }];
    });
}


@end
