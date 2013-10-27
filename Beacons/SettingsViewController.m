//
//  SettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SettingsViewController.h"
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
        return 2;
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
        if (indexPath.row == 1) {
            [self termsSelected];
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
    NSURL *termsURL = [NSURL URLWithString:@"http://mighty-reef-7102.herokuapp.com/terms"];
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"Terms" andURL:termsURL];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)privacySelected
{
    NSURL *privacyURL = [NSURL URLWithString:@"http://mighty-reef-7102.herokuapp.com/privacy"];
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"Privacy" andURL:privacyURL];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)logoutSelected
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logoutOfServer];
}

@end
