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

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Settings"];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Privacy";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Terms";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Feedback";
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
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
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self logoutSelected];
        }
    }
}

- (void)termsSelected
{
    NSURL *termsURL = [NSURL URLWithString:kTermsURL];
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"Terms" andURL:termsURL];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)privacySelected
{
    NSURL *privacyURL = [NSURL URLWithString:kPrivacyURL];
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"Privacy" andURL:privacyURL];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)feedbackSelected
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.completionBlock = ^(MFMailComposeViewController *mailComposeViewController, MFMailComposeResult result, NSError *error) {
        [mailComposeViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [mailViewController setSubject:@"Feedback"];
    [mailViewController setToRecipients:@[kFeedbackEmailAddress]];
    [[AppDelegate sharedAppDelegate].window.rootViewController presentViewController:mailViewController animated:YES completion:nil];
}

- (void)logoutSelected
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logoutOfServer];
}

@end
