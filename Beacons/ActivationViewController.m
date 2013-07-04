//
//  ActivationViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ActivationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <BSKeyboardControls/BSKeyboardControls.h>
#import "APIClient.h"
#import "AppDelegate.h"
#import "Theme.h"
#import "AnalyticsManager.h"

@interface ActivationViewController () <UITextFieldDelegate, BSKeyboardControlsDelegate>

@property (strong, nonatomic) IBOutlet UITextField *activationCodeTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UIView *labelBackgroundView;
@property (assign, nonatomic) CGRect originalLabelFrame;
@end

@implementation ActivationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    [ThemeManager customizeViewAndSubviews:self.view];
    self.codeLabel.adjustsFontSizeToFitWidth = YES;
    self.codeLabel.font = [ThemeManager boldFontOfSize:15];
    
    self.labelBackgroundView.layer.cornerRadius = 4;
    self.labelBackgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.labelBackgroundView.layer.borderWidth = 1;
    NSArray *textFields = @[self.activationCodeTextField];
    for (UITextField *textField in textFields) {
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        textField.textColor = [[ThemeManager sharedTheme] cyanColor];
    }
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    self.keyboardControls.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedManager] viewPage:AnalyticsLocationRegistration];
}


- (IBAction)submitButtonTouched:(id)sender
{
    [self sendActivation];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
	return YES;
    
}


#pragma mark - BSKeyboardControlsDelegate
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}

#pragma mark - Networking
- (void)sendActivation
{
    NSDictionary *parameters = @{@"activation_code": self.activationCodeTextField.text};
    [[APIClient sharedClient] postPath:@"activate/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
         [appDelegate didActivateAccount];
    }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.originalLabelFrame = self.labelBackgroundView.frame;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.labelBackgroundView.frame;
        frame.origin.y = MIN(frame.origin.y, self.view.frame.size.height - 259 - frame.size.height);
        self.labelBackgroundView.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.labelBackgroundView.frame = self.originalLabelFrame;
    }];
}


@end
