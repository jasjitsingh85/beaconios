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

typedef enum {
    RegistrationTableViewRowUserName=0,
    RegistrationTableViewRowName,
    RegistrationTableViewRowEmail,
    RegistrationTableViewRowPhone,
    RegistrationTableViewRowPassword,
} RegistrationTableViewRows;

@interface RegistrationViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BSKeyboardControlsDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *phoneTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end

@implementation RegistrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:244/255.0];
    
    self.usernameTextField = [UITextField new];
    self.nameTextField = [UITextField new];
    self.emailTextField = [UITextField new];
    self.phoneTextField = [UITextField new];
    self.passwordTextField = [UITextField new];
    NSArray *textFields = @[self.usernameTextField, self.nameTextField, self.emailTextField, self.phoneTextField, self.passwordTextField];
    for (UITextField *textField in textFields) {
        textField.frame = CGRectMake(90, 0, self.tableView.frame.size.width - 90, self.tableView.rowHeight);
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
    if (indexPath.row == RegistrationTableViewRowUserName) {
        label.text = @"Username";
        textField = self.usernameTextField;
    }
    if (indexPath.row == RegistrationTableViewRowName) {
        label.text = @"Full Name";
        textField = self.nameTextField;
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
    NSString *fullName = self.nameTextField.text;
    NSArray *nameComponents = [fullName componentsSeparatedByString:@" "];
    if (nameComponents.count < 2) {
        inputsAreValid = NO;
        alertMessage = @"Please enter a first and last name";
    }
    if (!inputsAreValid) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oopsy" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    return inputsAreValid;
}

#pragma mark - Networking
- (void)registerAccount
{
    NSString *fullName = self.nameTextField.text;
    NSArray *nameComponents = [fullName componentsSeparatedByString:@" "];
    NSString *firstName = nameComponents[0];
    NSString *lastName = [nameComponents lastObject];
    NSDictionary *parameters = @{@"username" : self.usernameTextField.text,
                                 @"first_name" : firstName,
                                 @"last_name" : lastName,
                                 @"password" : self.passwordTextField.text,
                                 @"email" : self.emailTextField.text,
                                 @"phone_number" : self.phoneTextField.text};
    [[APIClient sharedClient] postPath:@"user/me/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   //if the user already has a valid authorization token then the server retuns an empty response
                                   if (operation.response.statusCode != kHTTPStatusCodeNoContent) {
                                       id response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                                       NSString *authorizationToken = response[@"token"];
                                       [[APIClient sharedClient] setAuthorizationHeaderWithToken:authorizationToken];
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nice" message:@"Logged In" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView show];
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alertView show];
                               }];
}

@end
