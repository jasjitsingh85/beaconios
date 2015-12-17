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

    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoBlackBig"]];
    logoImageView.width = 115;
    logoImageView.height = 40;
    logoImageView.centerX = self.view.width/2;
    logoImageView.y = 40;
    [self.view addSubview:logoImageView];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotIconBig"]];
    iconImageView.height = 180;
    iconImageView.width = 180;
    iconImageView.centerX = self.view.width/2 - 5;
    iconImageView.y = 80;
    [self.view addSubview:iconImageView];
    
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, self.view.width - 100, 60)];
    subtitle.centerX = self.view.width/2;
    subtitle.text = @"Hotspot connects you to places and people you care about";
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.numberOfLines = 0;
    subtitle.textColor = [UIColor unnormalizedColorWithRed:70 green:70 blue:70 alpha:255];
    subtitle.font = [ThemeManager regularFontOfSize:14];
    [self.view addSubview:subtitle];
    
    UILabel *extraSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 275, self.view.width - 110, 60)];
    extraSubtitle.centerX = self.view.width/2;
    extraSubtitle.text = @"\xe2\x80\x94 in real life";
    extraSubtitle.textAlignment = NSTextAlignmentCenter;
    extraSubtitle.numberOfLines = 0;
    extraSubtitle.textColor = [UIColor unnormalizedColorWithRed:70 green:70 blue:70 alpha:255];
    extraSubtitle.font = [ThemeManager boldFontOfSize:14];
    [self.view addSubview:extraSubtitle];
    
    self.facebookRegisterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.facebookRegisterButton.frame = CGRectMake(0, 340, self.view.width - 75, 35);
    self.facebookRegisterButton.centerX = self.view.width/2;
    self.facebookRegisterButton.backgroundColor = [UIColor unnormalizedColorWithRed:46 green:83 blue:147 alpha:255];
    self.facebookRegisterButton.layer.cornerRadius = 4;
    [self.facebookRegisterButton addTarget:self action:@selector(transitionToRegisterWithFacebookView) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookRegisterButton setTitle:@"          Register with Facebook" forState:UIControlStateNormal];
    [self.facebookRegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookRegisterButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.facebookRegisterButton.titleLabel.font = [ThemeManager mediumFontOfSize:13];
    [self.view addSubview:self.facebookRegisterButton];
    
    UIImageView *facebookIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebookIconWhite"]];
    facebookIcon.width = 20;
    facebookIcon.height = 20;
    facebookIcon.y = 348;
    facebookIcon.x = 77;
    [self.view addSubview:facebookIcon];
    
    self.basicRegisterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.basicRegisterButton.frame = CGRectMake(0, 390, self.view.width - 75, 35);
    self.basicRegisterButton.centerX = self.view.width/2;
    self.basicRegisterButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.basicRegisterButton.backgroundColor = [UIColor unnormalizedColorWithRed:204 green:204 blue:204 alpha:255];
    self.basicRegisterButton.layer.cornerRadius = 4;
    [self.basicRegisterButton addTarget:self action:@selector(transitionToRegisterView) forControlEvents:UIControlEventTouchUpInside];
    [self.basicRegisterButton setTitle:@"           Register with your Email" forState:UIControlStateNormal];
    [self.basicRegisterButton setTitleColor:[UIColor unnormalizedColorWithRed:84 green:84 blue:84 alpha:255] forState:UIControlStateNormal];
    [self.basicRegisterButton setTitleColor:[[UIColor unnormalizedColorWithRed:84 green:84 blue:84 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.basicRegisterButton.titleLabel.font = [ThemeManager mediumFontOfSize:13];
    [self.view addSubview:self.basicRegisterButton];
    
    UIImageView *emailIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emailIcon"]];
    emailIcon.width = 19;
    emailIcon.height = 19;
    emailIcon.y = 398;
    emailIcon.x = 78;
    [self.view addSubview:emailIcon];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 440, self.view.width - 50, 0.5)];
    //    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:204 green:204 blue:204 alpha:255];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:129 green:129 blue:129 alpha:255];
    [self.view addSubview:topBorder];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(0, 440, self.view.width, 35);
    self.loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.loginButton.backgroundColor = [UIColor clearColor];
    [self.loginButton addTarget:self action:@selector(transitionToLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Already have an account? Log in" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor unnormalizedColorWithRed:99 green:99 blue:99 alpha:255] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [ThemeManager lightFontOfSize:14];
    [self.view addSubview:self.loginButton];
    
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:self.loginButton.titleLabel.text];
    NSRange attrStringRange = [self.loginButton.titleLabel.text rangeOfString:@"Log in"];
    [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager mediumFontOfSize:14] range:attrStringRange];
    self.loginButton.titleLabel.attributedText = attrMessage;
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
