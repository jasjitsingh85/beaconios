//
//  ActivationViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ActivationViewController.h"
#import <BSKeyboardControls/BSKeyboardControls.h>
#import "APIClient.h"
#import "AppDelegate.h"

@interface ActivationViewController () <UITextFieldDelegate, BSKeyboardControlsDelegate>

@property (strong, nonatomic) IBOutlet UITextField *activationCodeTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

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
    
    NSArray *textFields = @[self.activationCodeTextField];
    for (UITextField *textField in textFields) {
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
    }
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    self.keyboardControls.delegate = self;
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


@end
