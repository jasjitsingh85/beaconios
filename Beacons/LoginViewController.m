//
//  LoginViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RegistrationViewController.h"
#import "SignInViewController.h"
#import "Theme.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ThemeManager customizeViewAndSubviews:self.view];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (IBAction)registerButtonTouched:(id)sender {
    [self.navigationController pushViewController:[RegistrationViewController new] animated:YES];
}
- (IBAction)signInButtonTouched:(id)sender {
    [self.navigationController pushViewController:[SignInViewController new] animated:YES];
}


@end
