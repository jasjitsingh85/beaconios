//
//  SettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "PromoViewController.h"
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>
#import "AppDelegate.h"
#import "Theme.h"
#import "UIButton+HSNavButton.h"
#import "WebViewController.h"
#import "NavigationBarTitleLabel.h"
#import "SecretSettingsViewController.h"
#import "User.h"
#import "GroupsViewController.h"
#import "FormView.h"
#import "APIClient.h"
#import "LoadingIndictor.h"

@interface PromoViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *promoTextField;
@property (strong, nonatomic) UILabel *promoMessage;

@end

@implementation PromoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Promotions"];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    
    UIButton *applyButton = [UIButton navButtonWithTitle:@"APPLY"];
    [applyButton addTarget:self action:@selector(applyPromoCode:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:applyButton];
    
    self.promoMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, self.view.width - 50, 50)];
    self.promoMessage.numberOfLines = 0;
    self.promoMessage.centerX = self.view.width/2;
    self.promoMessage.textAlignment = NSTextAlignmentCenter;
    self.promoMessage.font = [ThemeManager lightFontOfSize:14];
    [self.view addSubview:self.promoMessage];
    
//    UIButton *secretButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGRect buttonFrame;
//    buttonFrame.size = CGSizeMake(self.view.frame.size.width, 50);
//    buttonFrame.origin = CGPointMake(0, self.view.frame.size.height - buttonFrame.size.height - 64);
//    secretButton.frame = buttonFrame;
//    secretButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    [secretButton setTitle:@"Made with \U0000E022 in Santa Fe" forState:UIControlStateNormal];
//    secretButton.titleLabel.font = [ThemeManager lightFontOfSize:14];
//    [secretButton addTarget:self action:@selector(secretButtonTouched:) forControlEvents:UIControlEventTouchDownRepeat];
//    [secretButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [self.view addSubview:secretButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (!section) {
//        return 1;
//    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
//            NSArray *activationFormTitles = @[@"PROMO CODE:"];
//            NSArray *activationFormPlaceholders = @[@" "];
//            FormView *promoFormView = [[FormView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36) formTitles:activationFormTitles formPlaceholders:activationFormPlaceholders];
//            promoFormView.delegate = self;
//            promoFormView.backgroundColor = [UIColor whiteColor];
//            promoFormView.layer.cornerRadius = 4;
//            //    self.activationFormView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//            //    self.activationFormView.layer.borderWidth = 1
////            [promoFormView centerHorizontallyInSuperView];
//            promoFormView.alpha = 0;
//            UITextField *promoTextField = [promoFormView textFieldAtIndex:0];
//            promoTextField.keyboardType = UIKeyboardTypeNumberPad;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *promoCode = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 130, 40)];
    promoCode.text = @"PROMO CODE:";
    promoCode.font = [ThemeManager boldFontOfSize:16];
    
    // This allocates the textfield and sets its frame
    self.promoTextField = [[UITextField  alloc] initWithFrame:
                              CGRectMake(20, 0, self.view.width, 40)];
    
    // This sets the border style of the text field
//    textField.borderStyle = UITextBorderStyleRoundedRect;
    self.promoTextField.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [self.promoTextField setFont:[ThemeManager lightFontOfSize:16]];
    
    //Placeholder text is displayed when no text is typed
    self.promoTextField.placeholder = @" ";
    
    //Prefix label is set as left view and the text starts after that
    self.promoTextField.leftView = promoCode;
    
    //It set when the left prefixLabel to be displayed
    self.promoTextField.leftViewMode = UITextFieldViewModeAlways;
    
    // sets the delegate to the current class
    self.promoTextField.delegate = self;
    
    [self.promoTextField setReturnKeyType:UIReturnKeyDone];
    
    [cell.contentView addSubview:self.promoTextField];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.promoTextField resignFirstResponder];
    return YES;
}

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    if (indexPath.section == 0) {
////        [self groupsSelected];
////    }
//        if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            [self privacySelected];
//        }
//        else if (indexPath.row == 1) {
//            [self termsSelected];
//        }
//        else if (indexPath.row == 2) {
//            [self feedbackSelected];
//        }
//        else if (indexPath.row == 3) {
//            [self logoutSelected];
//        }
//    }
//}

//- (void)groupsSelected
//{
//    GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
//    [self.navigationController pushViewController:groupsViewController animated:YES];
//}
//
//- (void)termsSelected
//{
//    NSURL *termsURL = [NSURL URLWithString:kTermsURL];
//    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"Terms" andURL:termsURL];
//    [self.navigationController pushViewController:webViewController animated:YES];
//}
//
//- (void)privacySelected
//{
//    NSURL *privacyURL = [NSURL URLWithString:kPrivacyURL];
//    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"Privacy" andURL:privacyURL];
//    [self.navigationController pushViewController:webViewController animated:YES];
//}
//
//- (void)feedbackSelected
//{
//    if (![MFMailComposeViewController canSendMail]) {
//        NSString *message = [NSString stringWithFormat:@"This device is not configured to send email. Please send feedback to %@", kFeedbackEmailAddress];
//        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        return;
//    }
//    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
//    mailViewController.bk_completionBlock = ^(MFMailComposeViewController *mailComposeViewController, MFMailComposeResult result, NSError *error) {
//        [mailComposeViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    };
//    [mailViewController setSubject:@"Feedback"];
//    [mailViewController setToRecipients:@[kFeedbackEmailAddress]];
//    [[AppDelegate sharedAppDelegate].window.rootViewController presentViewController:mailViewController animated:YES completion:nil];
//}
//
//- (void)logoutSelected
//{
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    [appDelegate logoutOfServer];
//}
//
//- (void)secretButtonTouched:(id)sender
//{
//    NSArray *permissions = @[@"6176337532", @"5413359388"];
//    if ([permissions containsObject:[User loggedInUser].normalizedPhoneNumber]) {
//        [self.navigationController pushViewController:[[SecretSettingsViewController alloc] init] animated:YES];
//    }
//}

- (void) applyPromoCode:(id)sender
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] addPromoCode:self.promoTextField.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *message = responseObject[@"message"];
        self.promoMessage.text = message;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

@end
