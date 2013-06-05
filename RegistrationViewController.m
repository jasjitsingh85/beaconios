//
//  RegistrationViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "RegistrationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <BSKeyboardControls/BSKeyboardControls.h>
#import "Theme.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "Utilities.h"

typedef enum {
    RegistrationTableViewRowFirstName=0,
    RegistrationTableViewRowLastName,
    RegistrationTableViewRowEmail,
    RegistrationTableViewRowPhone,
    RegistrationTableViewRowPassword,
} RegistrationTableViewRows;

@interface RegistrationViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BSKeyboardControlsDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) UITextField *firstNameTextField;
@property (strong, nonatomic) UITextField *lastNameTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *phoneTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end

@implementation RegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:244/255.0];
    
    self.firstNameTextField = [UITextField new];
    self.lastNameTextField = [UITextField new];
    self.emailTextField = [UITextField new];
    self.phoneTextField = [UITextField new];
    self.passwordTextField = [UITextField new];
    NSArray *textFields = @[self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.phoneTextField, self.passwordTextField];
    for (UITextField *textField in textFields) {
        textField.frame = CGRectMake(100, 0, self.tableView.frame.size.width - 100, self.tableView.rowHeight);
        textField.font = [ThemeManager boldFontOfSize:16.0];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.adjustsFontSizeToFitWidth = YES;
        textField.minimumFontSize = 4;
        textField.textColor = [UIColor colorWithRed:83/255.0 green:192/255.0 blue:197/255.0 alpha:1.0];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        textField.placeholder = @"";
        textField.text = @"";
    }
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    self.keyboardControls.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.layer.cornerRadius = 2;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.layer.borderWidth = 1;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

typedef enum {
    CellTagFieldLabel=1,
    CellTagTextField,
} CellTag;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *fieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, self.tableView.rowHeight)];
        fieldLabel.backgroundColor = [UIColor clearColor];
        fieldLabel.font = [ThemeManager regularFontOfSize:16.0];
        fieldLabel.tag = CellTagFieldLabel;
        [cell.contentView addSubview:fieldLabel];
        
        
    }
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:CellTagFieldLabel];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:CellTagTextField];
    if (textField) {
        [textField removeFromSuperview];
    }
    if (indexPath.row == RegistrationTableViewRowFirstName) {
        label.text = @"First Name";
        textField = self.firstNameTextField;
    }
    if (indexPath.row == RegistrationTableViewRowLastName) {
        label.text = @"Last Name";
        textField = self.lastNameTextField;
    }
    else if (indexPath.row == RegistrationTableViewRowEmail) {
        label.text = @"Email";
        textField = self.emailTextField;
    }
    else if (indexPath.row == RegistrationTableViewRowPhone) {
        label.text = @"Phone #";
        textField = self.phoneTextField;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if (indexPath.row == RegistrationTableViewRowPassword) {
        textField = self.passwordTextField;
        label.text = @"Password";
    }
    [cell.contentView addSubview:textField];
    return cell;
}

#pragma mark - UITableViewDelegate

- (IBAction)submitButtonTouched:(id)sender
{
    //validate inputs
    if (![self inputsAreValid]) {
        return;
    }
    //send to server
    [self registerAccount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:CellTagTextField];
    textField.enabled = YES;
    [textField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
    CGPoint point = [self.tableView convertPoint:textField.frame.origin fromView:textField];
    CGFloat yOffset = MAX(0,point.y - 60);
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
	return YES;

}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}

- (BOOL)inputsAreValid
{
    BOOL inputsAreValid = YES;
    NSString *alertMessage = @"";
    
    //name is valid
    BOOL nameIsValid = self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length > 0;
    if (!nameIsValid) {
        alertMessage = @"please enter a valid name";
    }
    
    //validate password
    BOOL passwordIsValid = [Utilities passwordIsValid:self.passwordTextField.text];
    if (!passwordIsValid) {
        alertMessage = @"please enter a valid password 6 or more characters";
    }
    
    //validate phone number
    BOOL phoneValid = [Utilities americanPhoneNumberIsValid:self.phoneTextField.text];
    if (!phoneValid) {
        alertMessage = @"please enter a valid phone number";
    }
    
    inputsAreValid = phoneValid && passwordIsValid && nameIsValid; //&& others valid
    if (!inputsAreValid) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oopsy" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    return inputsAreValid;
}

#pragma mark - Networking
- (void)registerAccount
{
    NSDictionary *parameters = @{@"first_name" : self.firstNameTextField.text,
                                 @"last_name" : self.lastNameTextField.text,
                                 @"password" : self.passwordTextField.text,
                                 @"email" : self.emailTextField.text,
                                 @"phone_number" : self.phoneTextField.text};
    [[APIClient sharedClient] postPath:@"user/me/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   //if the user already has a valid authorization token then the server retuns an empty response
                                   if (operation.response.statusCode != kHTTPStatusCodeNoContent) {
                                       NSString *authorizationToken = responseObject[@"token"];
                                       [[APIClient sharedClient] setAuthorizationHeaderWithToken:authorizationToken];
                                       AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                                       [appDelegate loggedInToServer];
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSString *message = @"Something went wrong";
                                   if (operation.response.statusCode == kHTTPStatusCodeBadRequest) {
                                       message = error.userInfo[@"NSLocalizedRecoverySuggestion"];
                                   }
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alertView show];
                                       
                               }];
}

@end
