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

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNav"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 25;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    self.facebookRegisterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.facebookRegisterButton.frame = CGRectMake(0, 300, self.view.width - 75, 35);
    self.facebookRegisterButton.centerX = self.view.width/2;
    self.facebookRegisterButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.facebookRegisterButton.backgroundColor = [UIColor unnormalizedColorWithRed:46 green:83 blue:147 alpha:255];
    self.facebookRegisterButton.layer.cornerRadius = 4;
    [self.facebookRegisterButton addTarget:self action:@selector(transitionToRegisterWithFacebookView) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookRegisterButton setTitle:@"Register with Facebook" forState:UIControlStateNormal];
    [self.facebookRegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.facebookRegisterButton.titleLabel.font = [ThemeManager mediumFontOfSize:14];
    [self.view addSubview:self.facebookRegisterButton];
    
    self.basicRegisterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.basicRegisterButton.frame = CGRectMake(0, 400, self.view.width - 75, 35);
    self.basicRegisterButton.centerX = self.view.width/2;
    self.basicRegisterButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.basicRegisterButton.backgroundColor = [UIColor unnormalizedColorWithRed:204 green:204 blue:204 alpha:255];
    self.basicRegisterButton.layer.cornerRadius = 4;
    [self.basicRegisterButton addTarget:self action:@selector(transitionToRegisterView) forControlEvents:UIControlEventTouchUpInside];
    [self.basicRegisterButton setTitle:@"Register with Email" forState:UIControlStateNormal];
    [self.basicRegisterButton setTitleColor:[UIColor unnormalizedColorWithRed:84 green:84 blue:84 alpha:255] forState:UIControlStateNormal];
    self.basicRegisterButton.titleLabel.font = [ThemeManager mediumFontOfSize:14];
    [self.view addSubview:self.basicRegisterButton];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(0, 500, self.view.width, 35);
    self.loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.loginButton.backgroundColor = [UIColor clearColor];
    [self.loginButton addTarget:self action:@selector(transitionToLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Already have an account? Log in" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor unnormalizedColorWithRed:99 green:99 blue:99 alpha:255] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [ThemeManager lightFontOfSize:14];
    [self.view addSubview:self.loginButton];
}

-(void)transitionToRegisterView
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate startRegistration];
}

-(void)transitionToLoginView
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
