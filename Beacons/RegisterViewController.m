//
//  RegisterViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "RegisterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Alignment.h"
#import "FormView.h"

typedef enum {
    ViewModeRegister=0,
    ViewModeSignIn,
    ViewModeActivation,
} ViewMode;

@interface RegisterViewController ()

@property (strong, nonatomic) FormView *registerFormView;
@property (strong, nonatomic) FormView *signInFormView;
@property (strong, nonatomic) FormView *activationFormView;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *backButton;
@property (assign, nonatomic) ViewMode viewMode;
@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    self.view.userInteractionEnabled = YES;
    self.viewMode = ViewModeRegister;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"orangeBackground"]];
    NSArray *registerFormTitles = @[@"name", @"email", @"phone"];
    self.registerFormView = [[FormView alloc] initWithFrame:CGRectMake(0, 105, 250, 36*registerFormTitles.count) formTitles:registerFormTitles];
    self.registerFormView.backgroundColor = [UIColor whiteColor];
    self.registerFormView.layer.cornerRadius = 4;
    [self.view addSubview:self.registerFormView];
    [self.registerFormView centerHorizontallyInSuperView];
    UITextField *registerPhoneTextField = [self.registerFormView textFieldAtIndex:2];
    registerPhoneTextField.keyboardType = UIKeyboardTypePhonePad;
    
    
    NSArray *signInFormTitles = @[@"phone"];
    self.signInFormView = [[FormView alloc] initWithFrame:CGRectMake(0, 105, 250, 36*signInFormTitles.count) formTitles:signInFormTitles];
    self.signInFormView.backgroundColor = [UIColor whiteColor];
    self.signInFormView.layer.cornerRadius = 4;
    [self.view addSubview:self.signInFormView];
    [self.signInFormView centerHorizontallyInSuperView];
    self.signInFormView.alpha = 0;
    UITextField *signInPhoneTextField = [self.signInFormView textFieldAtIndex:0];
    signInPhoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    NSArray *activationFormTitles = @[@"activation code"];
    self.activationFormView = [[FormView alloc] initWithFrame:CGRectMake(0, 105, 250, 36*activationFormTitles.count) formTitles:activationFormTitles];
    self.activationFormView.backgroundColor = [UIColor whiteColor];
    self.activationFormView.layer.cornerRadius = 4;
    [self.view addSubview:self.activationFormView];
    [self.activationFormView centerHorizontallyInSuperView];
    self.activationFormView.alpha = 0;
    UITextField *activationTextField = [self.activationFormView textFieldAtIndex:0];
    activationTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"Register" forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor colorWithRed:162/255.0 green:211/255.0 blue:156/255.0 alpha:1.0];
    [self.confirmButton setTitleColor:[UIColor colorWithRed:108/255.0 green:124/255.0 blue:146/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 4;
    CGRect confirmButtonFrame;
    confirmButtonFrame.size  = CGSizeMake(200, 35);
    confirmButtonFrame.origin.x = 0.5*(self.view.frame.size.width - confirmButtonFrame.size.width);
    confirmButtonFrame.origin.y = 250;
    self.confirmButton.frame = confirmButtonFrame;
    [self.view addSubview:self.confirmButton];
    [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:@"I have an account" forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1];
    self.loginButton.layer.cornerRadius = 4;
    CGRect loginButtonFrame;
    loginButtonFrame.size = CGSizeMake(200, 35);
    loginButtonFrame.origin.x = 0.5*(self.view.frame.size.width - loginButtonFrame.size.width);
    loginButtonFrame.origin.y = 300;
    self.loginButton.frame = loginButtonFrame;
    [self.view addSubview:self.loginButton];
    [self.loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backgroundTapped:(id)sender
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [self.activationFormView endEditing];
    [self.registerFormView endEditing];
    [self.signInFormView endEditing];
}

- (void)loginButtonTouched:(id)sender
{
    [self dismissKeyboard];
    if (self.viewMode == ViewModeActivation) {
        [self enterRegisterMode];
    }
    else if (self.viewMode == ViewModeRegister) {
        [self enterSignInMode];
    }
    else if (self.viewMode == ViewModeSignIn) {
        [self enterRegisterMode];
    }
}

- (void)confirmButtonTouched:(id)sender
{
    [self dismissKeyboard];
    if (self.viewMode == ViewModeSignIn || self.viewMode == ViewModeRegister) {
        [self enterActivationMode];
    }
}

- (void)enterSignInMode
{
    if (self.viewMode == ViewModeSignIn) {
        return;
    }
    self.viewMode = ViewModeSignIn;
    [self.confirmButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Back" forState:UIControlStateNormal];
    self.signInFormView.alpha = 1;
    self.signInFormView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(self.signInFormView.frame) - 20, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.signInFormView.transform = CGAffineTransformIdentity;
        self.registerFormView.alpha = 0;
        self.activationFormView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)enterRegisterMode
{
    if (self.viewMode == ViewModeRegister) {
        return;
    }
    self.viewMode = ViewModeRegister;
    [self.confirmButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"I have an account" forState:UIControlStateNormal];
    self.registerFormView.alpha = 1;
    self.registerFormView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width - CGRectGetMinX(self.registerFormView.frame), 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.registerFormView.transform = CGAffineTransformIdentity;
        self.signInFormView.alpha = 0;
        self.activationFormView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)enterActivationMode
{
    if (self.viewMode == ViewModeActivation) {
        return;
    }
    self.viewMode = ViewModeActivation;
    [self.confirmButton setTitle:@"Activate" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Back" forState:UIControlStateNormal];
    self.activationFormView.alpha = 1;
    self.activationFormView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(self.activationFormView.frame) - 20, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.activationFormView.transform = CGAffineTransformIdentity;
        self.registerFormView.alpha = 0;
        self.signInFormView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

@end
