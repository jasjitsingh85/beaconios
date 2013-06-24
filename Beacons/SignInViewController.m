//
//  SignInViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SignInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <BSKeyboardControls/BSKeyboardControls.h>
#import "Theme.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "User.h"

typedef enum {
    SignInTableViewRowPhone=0,
    SignInTableViewRowPassword,
} SignInTableViewRow;

@interface SignInViewController () <BSKeyboardControlsDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *phoneTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation SignInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:244/255.0];
    
    self.phoneTextField = [UITextField new];
    self.passwordTextField = [UITextField new];
    NSArray *textFields = @[self.phoneTextField, self.passwordTextField];
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
    self.tableView.allowsSelection = NO;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"Sign In";
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
    if (indexPath.row == SignInTableViewRowPhone) {
        label.text = @"Phone #";
        textField = self.phoneTextField;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if (indexPath.row == SignInTableViewRowPassword) {
        textField = self.passwordTextField;
        textField.secureTextEntry = YES;
        label.text = @"Password";
    }
    [cell.contentView addSubview:textField];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)signInButtonTouched:(id)sender
{
    NSDictionary *parameters = @{@"password" : self.passwordTextField.text,
                                 @"phone_number" : self.phoneTextField.text};
    [[APIClient sharedClient] postPath:@"login/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   //if the user already has a valid authorization token then the server retuns an empty response
                                   if (operation.response.statusCode != kHTTPStatusCodeNoContent) {
                                       AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                                       [appDelegate loggedIntoServerWithResponse:responseObject];
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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

@end
