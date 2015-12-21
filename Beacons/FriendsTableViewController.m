//
//  SettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "AppDelegate.h"
#import "Theme.h"
#import "APIClient.h"
#import "LoadingIndictor.h"
#import "ContactManager.h"
#import "User.h"
#import "Utilities.h"
#import "Contact.h"

@interface FriendsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *approvedUsers;
@property (strong, nonatomic) NSArray *notApprovedUsers;
@property (strong, nonatomic) NSDictionary *allContacts;

@end

@implementation FriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.tableView.allowsSelection = NO;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    [self updateFriendList];
    [self.tableView reloadData];

}

-(void)updateFriendList
{
    self.allContacts = [ContactManager sharedManager].contactDictionary;
    self.approvedUsers = [ContactManager sharedManager].approvedUsers;
    self.notApprovedUsers = [ContactManager sharedManager].notApprovedUsers;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.notApprovedUsers.count > 0) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.approvedUsers.count;
    } else if (section == 2) {
        return self.notApprovedUsers.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, self.view.width/2, 20)];
        userLabel.font = [ThemeManager lightFontOfSize:13];
        [cell.contentView addSubview:userLabel];
        
        if (indexPath.section == 1) {
            User *user = self.approvedUsers[indexPath.row];
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:user.username];
            Contact *contact = self.allContacts[normalizedPhoneNumber];
            NSRange range;
            if (contact) {
                userLabel.text = contact.fullName;
                if (contact.lastName) {
                    range = [userLabel.text rangeOfString:[NSString stringWithFormat:@" %@", contact.lastName]];
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:userLabel.text];
                    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:13] range:range];
                    userLabel.attributedText = attributedText;
                }
            } else {
                userLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                range = [userLabel.text rangeOfString:user.lastName];
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:userLabel.text];
                [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:13] range:range];
                userLabel.attributedText = attributedText;
            }
            
            UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            removeButton.size = CGSizeMake(65, 25);
            removeButton.x = cell.size.width - 90;
            removeButton.y = 7.5;
            removeButton.layer.cornerRadius = 4;
            removeButton.backgroundColor = [UIColor whiteColor];
            removeButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
            removeButton.layer.borderWidth = 1;
            [removeButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
            [removeButton setTitleColor:[[[ThemeManager sharedTheme] redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
            removeButton.titleLabel.font = [ThemeManager regularFontOfSize:11];
            [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
            [cell.contentView addSubview:removeButton];

        } else if (indexPath.section == 2) {
            User *user = self.notApprovedUsers[indexPath.row];
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:user.username];
            Contact *contact = self.allContacts[normalizedPhoneNumber];
            if (contact) {
                userLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
            } else {
                userLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            }
            
            UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            removeButton.size = CGSizeMake(65, 25);
            removeButton.x = cell.size.width - 90;
            removeButton.y = 7.5;
            removeButton.layer.cornerRadius = 4;
            removeButton.backgroundColor = [UIColor whiteColor];
            removeButton.layer.borderColor = [UIColor blackColor].CGColor;
            removeButton.layer.borderWidth = 1;
            [removeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [removeButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
            removeButton.titleLabel.font = [ThemeManager regularFontOfSize:11];
            [removeButton setTitle:@"Add" forState:UIControlStateNormal];
            [cell.contentView addSubview:removeButton];
        }
        
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.size.width, 25)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, tableView.size.width, 20)];
    label.font = [ThemeManager boldFontOfSize:13];
    if (section == 1) {
        label.text = @"FRIENDS ON HOTSPOT";
        label.textColor = [[ThemeManager sharedTheme] redColor];
    } else if (section == 2)  {
        label.text = @"REMOVED";
        label.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    } else {
        
    }
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 125;
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


@end
