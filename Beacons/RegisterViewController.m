//
//  RegisterViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "RegisterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>
#import "UIView+Alignment.h"
#import "FormView.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "AnalyticsManager.h"
#import "Utilities.h"
#import "LoadingIndictor.h"
#import "Theme.h"

typedef enum {
    ViewModeRegister=0,
    ViewModeSignIn,
    ViewModeActivation,
} ViewMode;

@interface RegisterViewController () <FormViewDelegate>

@property (strong, nonatomic) FormView *registerFormView;
@property (strong, nonatomic) FormView *signInFormView;
@property (strong, nonatomic) FormView *activationFormView;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *helpButton;
@property (assign, nonatomic) ViewMode viewMode;
@property (assign, nonatomic) BOOL makingNetworkRequest;
@property (strong, nonatomic) UIImageView *hotbotImageView;
@property (strong, nonatomic) UILabel *hotbotCommentLabel;
@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNav"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 30;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"waveBackground"]];
    NSArray *registerFormTitles = @[@"full name", @"email", @"phone"];
    self.registerFormView = [[FormView alloc] initWithFrame:CGRectMake(81, 105, 220, 30*registerFormTitles.count) formTitles:registerFormTitles];
    self.registerFormView.delegate = self;
    self.registerFormView.backgroundColor = [UIColor whiteColor];
    self.registerFormView.layer.cornerRadius = 4;
    self.registerFormView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.registerFormView.layer.borderWidth = 1;
    [self.view addSubview:self.registerFormView];
    UITextField *registerEmailTextField = [self.registerFormView textFieldAtIndex:1];
    registerEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    registerEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    UITextField *registerPhoneTextField = [self.registerFormView textFieldAtIndex:2];
    registerPhoneTextField.keyboardType = UIKeyboardTypePhonePad;
    
    
    NSArray *signInFormTitles = @[@"phone"];
    self.signInFormView = [[FormView alloc] initWithFrame:CGRectMake(81, 159, 220, 30*signInFormTitles.count) formTitles:signInFormTitles];
    self.signInFormView.delegate = self;
    self.signInFormView.backgroundColor = [UIColor whiteColor];
    self.signInFormView.layer.cornerRadius = 4;
    self.signInFormView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.signInFormView.layer.borderWidth = 1;
    [self.view addSubview:self.signInFormView];
    self.signInFormView.alpha = 0;
    UITextField *signInPhoneTextField = [self.signInFormView textFieldAtIndex:0];
    signInPhoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    NSArray *activationFormTitles = @[@"code"];
    self.activationFormView = [[FormView alloc] initWithFrame:CGRectMake(81, 159, 65, 36*activationFormTitles.count) formTitles:activationFormTitles];
    self.activationFormView.delegate = self;
    self.activationFormView.backgroundColor = [UIColor whiteColor];
    self.activationFormView.layer.cornerRadius = 4;
    self.activationFormView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.activationFormView.layer.borderWidth = 1;
    [self.view addSubview:self.activationFormView];
    [self.activationFormView centerHorizontallyInSuperView];
    self.activationFormView.alpha = 0;
    UITextField *activationTextField = [self.activationFormView textFieldAtIndex:0];
    activationTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"Register" forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor colorWithRed:162/255.0 green:211/255.0 blue:156/255.0 alpha:1.0];
    UIColor *confirmButtonColor = [UIColor colorWithRed:108/255.0 green:124/255.0 blue:146/255.0 alpha:1.0];
    [self.confirmButton setTitleColor:[confirmButtonColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.confirmButton setTitleColor:confirmButtonColor forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 4;
    CGRect confirmButtonFrame;
    confirmButtonFrame.size  = CGSizeMake(243, 35);
    confirmButtonFrame.origin.x = 0.5*(self.view.frame.size.width - confirmButtonFrame.size.width);
    confirmButtonFrame.origin.y = 265;
    self.confirmButton.frame = confirmButtonFrame;
    [self.view addSubview:self.confirmButton];
    [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.loginButton setTitle:@"I have an account" forState:UIControlStateNormal];
    UIColor *loginButtonColor = [UIColor whiteColor];
    [self.loginButton setTitleColor:[loginButtonColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:loginButtonColor forState:UIControlStateNormal];
    CGRect loginButtonFrame;
    loginButtonFrame.size = self.confirmButton.frame.size;
    loginButtonFrame.origin.x = 0.5*(self.view.frame.size.width - loginButtonFrame.size.width);
    loginButtonFrame.origin.y = CGRectGetMaxY(self.confirmButton.frame);
    self.loginButton.frame = loginButtonFrame;
    [self.view addSubview:self.loginButton];
    [self.loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.helpButton setImage:[UIImage imageNamed:@"helpButton"] forState:UIControlStateNormal];
    [self.helpButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.helpButton.backgroundColor = [UIColor clearColor];
    CGRect helpButtonFrame;
    helpButtonFrame.size = CGSizeMake(30, 30);
    helpButtonFrame.origin.x = self.view.frame.size.width - helpButtonFrame.size.width;
    helpButtonFrame.origin.y = 0;
    self.helpButton.frame = helpButtonFrame;
    [self.helpButton addTarget:self action:@selector(helpButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.helpButton];
    
    self.hotbotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotbotSmile"]];
    CGRect hotbotFrame = self.hotbotImageView.frame;
    hotbotFrame.origin = CGPointMake(-33, 58);
    self.hotbotImageView.frame = hotbotFrame;
    [self.view addSubview:self.hotbotImageView];
    
    self.hotbotCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 80, 220, 15)];
    self.hotbotCommentLabel.textColor = [UIColor colorWithRed:234/255.0 green:118/255.0 blue:90/255.0 alpha:1.0];
    [self.view addSubview:self.hotbotCommentLabel];
    
    self.viewMode = -1;
    [self enterRegisterMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AnalyticsManager sharedManager] registrationBegan];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    if (self.viewMode == ViewModeRegister && [self registerInputsAreValid]) {
        [self registerAccount];
        [self enterActivationMode];
    }
    else if (self.viewMode == ViewModeSignIn) {
        [self signInAccount];
    }
    else if (self.viewMode == ViewModeActivation) {
        [self activateAccount];
    }
}

- (void)helpButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:nil];
    [actionSheet addButtonWithTitle:@"Having Trouble?" handler:^{
        [self presentFeedbackForm];
    }];
    [actionSheet setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentFeedbackForm
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.completionBlock = ^(MFMailComposeViewController *mailComposeViewController, MFMailComposeResult result, NSError *error) {
        [mailComposeViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [mailViewController setSubject:@"I'm Having Trouble Registering or Logging In"];
    [mailViewController setToRecipients:@[kFeedbackEmailAddress]];
    [mailViewController setMessageBody:@"These are my problems:\n" isHTML:NO];
    [self presentViewController:mailViewController animated:YES completion:nil];
}

- (void)presentModalWithContentViewController:(UIViewController *)viewController
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(modalDoneButtonTouched:)];
    viewController.navigationItem.leftBarButtonItem = cancelButtonItem;;
    [nav.navigationBar setBackgroundImage:    [[ThemeManager sharedTheme] navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)modalDoneButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enterSignInMode
{
    if (self.viewMode == ViewModeSignIn) {
        return;
    }
    
    UITextField *textField = [self.signInFormView textFieldAtIndex:0];
    [textField becomeFirstResponder];
    
    self.viewMode = ViewModeSignIn;
    [self.confirmButton setTitle:@"Sign In" forState:UIControlStateNormal];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Not a user? Register here!" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.loginButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    NSRange range = [attributedTitle.string rangeOfString:@"Register here!"];
    [attributedTitle addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:108/255.0 green:124/255.0 blue:146/255.0 alpha:1.0]} range:range];
    self.signInFormView.alpha = 1;
    self.signInFormView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(self.signInFormView.frame) - 20, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.signInFormView.transform = CGAffineTransformIdentity;
        self.registerFormView.alpha = 0;
        self.activationFormView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"Hey, again. What's your number?" attributes:@{NSFontAttributeName : [ThemeManager regularFontOfSize:13]}];
    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:13] range:[attributedText.string rangeOfString:@"Hey, again."]];
    self.hotbotCommentLabel.attributedText = attributedText;
    self.hotbotCommentLabel.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
        self.hotbotCommentLabel.alpha = 1;
    } completion:nil];
}

- (void)enterRegisterMode
{
    if (self.viewMode == ViewModeRegister) {
        return;
    }
    self.viewMode = ViewModeRegister;
    [self.confirmButton setTitle:@"Register" forState:UIControlStateNormal];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Already registed? Login here!" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    NSRange range = [attributedTitle.string rangeOfString:@"Login here!"];
    [attributedTitle addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:108/255.0 green:124/255.0 blue:146/255.0 alpha:1.0]} range:range];
    [self.loginButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    self.registerFormView.alpha = 1;
    self.registerFormView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width - CGRectGetMinX(self.registerFormView.frame), 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.registerFormView.transform = CGAffineTransformIdentity;
        self.signInFormView.alpha = 0;
        self.activationFormView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"Welcome! Looks like you're new." attributes:@{NSFontAttributeName : [ThemeManager regularFontOfSize:13]}];
    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:13] range:[attributedText.string rangeOfString:@"Welcome!"]];
    self.hotbotCommentLabel.attributedText = attributedText;
    self.hotbotCommentLabel.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
        self.hotbotCommentLabel.alpha = 1;
    } completion:nil];
}

- (void)enterActivationMode
{
    if (self.viewMode == ViewModeActivation) {
        return;
    }
    self.viewMode = ViewModeActivation;
    UITextField *textField = [self.activationFormView textFieldAtIndex:0];
    [textField becomeFirstResponder];
    
    [self.confirmButton setTitle:@"Activate" forState:UIControlStateNormal];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Back" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.loginButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    self.activationFormView.alpha = 1;
    self.activationFormView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(self.activationFormView.frame) - 20, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.activationFormView.transform = CGAffineTransformIdentity;
        self.registerFormView.alpha = 0;
        self.signInFormView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"Let's get started! Enter your code." attributes:@{NSFontAttributeName : [ThemeManager regularFontOfSize:13]}];
    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:13] range:[attributedText.string rangeOfString:@"Let's get started!"]];
    self.hotbotCommentLabel.attributedText = attributedText;
    self.hotbotCommentLabel.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
        self.hotbotCommentLabel.alpha = 1;
    } completion:nil];
}

- (BOOL)registerInputsAreValid
{
    BOOL inputsAreValid = YES;
    NSString *alertMessage = @"";
    
    //name is valid
    NSString *nameText = [self.registerFormView textFieldAtIndex:0].text;
    BOOL nameIsValid = nameText.length;
    if (!nameIsValid) {
        alertMessage = @"Please enter a valid name";
    }
    
    
    //validate phone number
    NSString *phoneText = [self.registerFormView textFieldAtIndex:2].text;
    NSLog(@"phone %@", phoneText);
    BOOL phoneValid = [Utilities americanPhoneNumberIsValid:phoneText];
    if (!phoneValid) {
        alertMessage = @"Please enter a valid phone number";
    }
    
    inputsAreValid = phoneValid && nameIsValid; //&& others valid
    if (!inputsAreValid) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Couldn't Register Account" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    return inputsAreValid;
}

#pragma mark - Networking
- (void)registerAccount
{
    if (self.makingNetworkRequest) {
        return;
    }
    self.makingNetworkRequest = YES;
    
    NSString *nameText = [self.registerFormView textFieldAtIndex:0].text;
    NSArray *nameComponents = [nameText componentsSeparatedByString:@" "];
    NSString *firstName = [nameComponents firstObject];
    NSString *lastName = @"";
    if (nameComponents.count > 1) {
        lastName = [nameComponents lastObject];
    }
    NSString *emailText = [self.registerFormView textFieldAtIndex:1].text;
    NSString *phoneText = [Utilities normalizePhoneNumber:[self.registerFormView textFieldAtIndex:2].text];
    NSDictionary *parameters = @{@"first_name" : firstName,
                                 @"last_name" : lastName,
                                 @"email" : emailText,
                                 @"phone_number" : phoneText};
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] postPath:@"user/me/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
                                   self.makingNetworkRequest = NO;
                                   [[AppDelegate sharedAppDelegate] registeredWithResponse:responseObject];
                                   [[[UIAlertView alloc] initWithTitle:@"Thanks" message:@"Activation code sent via SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   [self enterActivationMode];
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
                                   self.makingNetworkRequest = NO;
                                   NSString *message = @"Something went wrong";
                                   if (operation.response.statusCode == kHTTPStatusCodeBadRequest) {
                                       message = [error serverErrorMessage];
                                   }
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alertView show];
                                   [self enterRegisterMode];
                               }];
}

- (void)signInAccount
{
    if (self.makingNetworkRequest) {
        return;
    }
    
    self.makingNetworkRequest = YES;
    NSString *phoneText = [Utilities normalizePhoneNumber:[self.signInFormView textFieldAtIndex:0].text];
    NSDictionary *parameters = @{@"phone_number" : phoneText};
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] postPath:@"login/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
                                   self.makingNetworkRequest = NO;
                                   AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                                   [appDelegate loggedIntoServerWithResponse:responseObject];
                                   [[[UIAlertView alloc] initWithTitle:@"Thanks" message:@"Activation code sent via SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   [self enterActivationMode];
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
                                   self.makingNetworkRequest = NO;
                                   NSString *message = @"We couldn't find a user with this number";
                                   if (operation.response.statusCode == kHTTPStatusCodeBadRequest) {
                                       message = [error serverErrorMessage];
                                   }
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alertView show];
                                   
                               }];
}

- (void)activateAccount
{
    if (self.makingNetworkRequest) {
        return;
    }
    self.makingNetworkRequest = YES;
    
    NSString *activationText = [self.activationFormView textFieldAtIndex:0].text;
    NSDictionary *parameters = @{@"activation_code" : activationText};
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] putPath:@"login/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.makingNetworkRequest = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate didActivateAccount];
        [[AnalyticsManager sharedManager] registrationFinished];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.makingNetworkRequest = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem with your activation code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - FormViewDelegate
- (void)formView:(FormView *)formView textFieldDidChange:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"phone"]) {
        NSString *phone = [Utilities normalizePhoneNumber:textField.text];
        if (phone.length < 4) {
            textField.text = phone;
        }
        else if (phone.length < 7) {
            NSString *comp0 = [phone substringWithRange:NSMakeRange(0, 3)];
            NSString *comp1 = [phone substringWithRange:NSMakeRange(3, MIN((phone.length - 3), 3))];
            textField.text = [NSString stringWithFormat:@"(%@) %@", comp0, comp1];
        }
        else {
            NSString *comp0 = [phone substringWithRange:NSMakeRange(0, 3)];
            NSString *comp1 = [phone substringWithRange:NSMakeRange(3, 3)];
            NSString *comp2 = [phone substringWithRange:NSMakeRange(6, phone.length - 6)];
            textField.text = [NSString stringWithFormat:@"(%@) %@ - %@", comp0, comp1, comp2];
        }
        //make sure register and sign in views are synced
        UITextField *registerPhoneField = [self.registerFormView textFieldAtIndex:2];
        if (textField == registerPhoneField) {
            UITextField *signInPhoneField = [self.signInFormView textFieldAtIndex:0];
            signInPhoneField.text = registerPhoneField.text;
        }
    }
    
    if ([textField.placeholder isEqualToString:@"code"]) {
        NSInteger activitionCodeLength = 4;
        if (textField.text.length == activitionCodeLength) {
            [textField resignFirstResponder];
            [self activateAccount];
        }
        else if (textField.text.length > activitionCodeLength) {
            textField.text = nil;
        }
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.view.frame.size.height == 568) {
        return;
    }
    NSDictionary* info = [notification userInfo];
    CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -48);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.view.frame.size.height == 568) {
        return;
    }
    NSDictionary* info = [notification userInfo];
    CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

@end
