//
//  SettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SettingsViewController.h"
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>
#import "AppDelegate.h"
#import "Theme.h"
#import "WebViewController.h"
#import "NavigationBarTitleLabel.h"
#import "SecretSettingsViewController.h"
#import "User.h"
#import "GroupsViewController.h"
#import "FaqViewController.h"
#import "PromoViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Settings"];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    
    UIButton *secretButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame;
    buttonFrame.size = CGSizeMake(self.view.frame.size.width, 50);
    buttonFrame.origin = CGPointMake(0, self.view.frame.size.height - buttonFrame.size.height - 64);
    secretButton.frame = buttonFrame;
    secretButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [secretButton setTitle:@"Made with \U0000E022 in Bangkok" forState:UIControlStateNormal];
    secretButton.titleLabel.font = [ThemeManager lightFontOfSize:14];
    [secretButton addTarget:self action:@selector(secretButtonTouched:) forControlEvents:UIControlEventTouchDownRepeat];
    [secretButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:secretButton];
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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    if (indexPath.section == 0) {
//        cell.textLabel.text = @"Groups";
//    }
//    else
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Privacy";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Terms";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Feedback";
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"FAQ";
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Promo";
        } else if (indexPath.row == 5) {
            cell.textLabel.text = @"Logout";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self privacySelected];
            }
            else if (indexPath.row == 1) {
                [self termsSelected];
            }
            else if (indexPath.row == 2) {
                [self feedbackSelected];
            } else if (indexPath.row == 3) {
                [self faqSelected];
            } else if (indexPath.row == 4) {
                [self promoSelected];
            } else if (indexPath.row == 5) {
                [self logoutSelected];
            }
        }
}

//- (void)groupsSelected
//{
//    GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
//    [self.navigationController pushViewController:groupsViewController animated:YES];
//}

- (void)faqSelected
{
    FaqViewController *faqViewController = [[FaqViewController alloc] init];
    [self.navigationController pushViewController:faqViewController animated:YES];
}

- (void)termsSelected
{
    NSURL *termsURL = [NSURL URLWithString:kTermsURL];
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.title = @"Terms";
    webViewController.websiteUrl = termsURL;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)privacySelected
{
    NSURL *privacyURL = [NSURL URLWithString:kPrivacyURL];
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.title = @"Privacy";
    webViewController.websiteUrl = privacyURL;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)feedbackSelected
{
    if (![MFMailComposeViewController canSendMail]) {
        NSString *message = [NSString stringWithFormat:@"This device is not configured to send email. Please send feedback to %@", kFeedbackEmailAddress];
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.bk_completionBlock = ^(MFMailComposeViewController *mailComposeViewController, MFMailComposeResult result, NSError *error) {
        [mailComposeViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [mailViewController setSubject:@"Feedback"];
    [mailViewController setToRecipients:@[kFeedbackEmailAddress]];
    [[AppDelegate sharedAppDelegate].window.rootViewController presentViewController:mailViewController animated:YES completion:nil];
}

-(void)promoSelected
{
    PromoViewController *promoViewController = [[PromoViewController alloc] init];
    [self.navigationController pushViewController:promoViewController animated:YES];
}

- (void)logoutSelected
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logoutOfServer];
}

- (void)secretButtonTouched:(id)sender
{
    NSArray *permissions = @[@"6176337532", @"5413359388", @"2162695105", @"6094398069", @"2064731300"];
    if ([permissions containsObject:[User loggedInUser].normalizedPhoneNumber]) {
        [self.navigationController pushViewController:[[SecretSettingsViewController alloc] init] animated:YES];
    }
}

@end
