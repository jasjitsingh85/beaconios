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
#import "UIButton+HSNavButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FriendsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *approvedUsers;
@property (strong, nonatomic) NSArray *notApprovedUsers;
@property (strong, nonatomic) NSDictionary *allContacts;
@property (strong, nonatomic) UIView *noFriendsView;
@property (strong, nonatomic) UIButton *linkFacebookButton;
@property (strong, nonatomic) UIButton *syncContactsButton;

@end

@implementation FriendsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    
    self.noFriendsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.view.height * 2)];
    self.noFriendsView.backgroundColor = [UIColor whiteColor];
    [self.noFriendsView.layer setZPosition:1000];
    self.noFriendsView.hidden = NO;
    [self.tableView addSubview:self.noFriendsView];
    
    UIImageView *headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friends"]];
    headerIcon.centerX = self.tableView.width/2;
    headerIcon.y = 75;
    [self.noFriendsView addSubview:headerIcon];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, self.view.width - 60, 20)];
    label.font = [ThemeManager boldFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.y = 100;
    label.text = @"FIND FRIENDS ON HOTSPOT";
    [self.noFriendsView addSubview:label];
    
    UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(30, 115, self.view.width - 60, 60)];
    body.textAlignment = NSTextAlignmentCenter;
    body.font = [ThemeManager lightFontOfSize:12];
    body.numberOfLines = 0;
    body.text = @"Link facebook and sync contacts to find your friends on Hotspot. You’ll be able to invite them to join you when you check in.";
    [self.noFriendsView addSubview:body];
    
    self.linkFacebookButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.linkFacebookButton.size = CGSizeMake(self.view.width - 50, 35);
    self.linkFacebookButton.y = 200;
    self.linkFacebookButton.width = self.view.width - 60;
    self.linkFacebookButton.height = 35;
    self.linkFacebookButton.centerX = self.view.width/2.0;
    self.linkFacebookButton.layer.cornerRadius = 3;
    self.linkFacebookButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.linkFacebookButton.layer.borderWidth = 1;
    self.linkFacebookButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.linkFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.linkFacebookButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.linkFacebookButton.titleLabel.font = [ThemeManager mediumFontOfSize:11];
    
    self.syncContactsButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.syncContactsButton.backgroundColor=[[ThemeManager sharedTheme] lightBlueColor];
    self.syncContactsButton.layer.cornerRadius = 3;
    self.syncContactsButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.syncContactsButton.layer.borderWidth = 1;
    [self.syncContactsButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.syncContactsButton.frame=CGRectMake(0, 260, self.view.width - 60, 35);
    self.syncContactsButton.titleLabel.font = [ThemeManager mediumFontOfSize:11];
    self.syncContactsButton.centerX = self.view.width/2;
    
    [self.linkFacebookButton
     addTarget:self
     action:@selector(facebookButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.syncContactsButton
     addTarget:self
     action:@selector(contactButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.noFriendsView addSubview:self.linkFacebookButton];
    [self.noFriendsView addSubview:self.syncContactsButton];
    
    [self updateNoFriendsView];
    self.allContacts = [ContactManager sharedManager].contactDictionary;
    [self refreshFriends];

}

-(void)updateNoFriendsView
{
    if (self.approvedUsers.count == 0 && self.notApprovedUsers.count == 0 ) {
        self.noFriendsView.hidden = NO;
    } else {
        self.noFriendsView.hidden = YES;
    }
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self changeFacebookButtonToCompletedState];
    } else {
        [self changeFacebookButtonToIncompletedState];
    }
    
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
        [self changeContactButtonToActiveState];
    }
    else if (contactAuthStatus == kABAuthorizationStatusDenied) {
        [self changeContactButtonToInactiveState];
    }
    else if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
        [self changeContactButtonToSelectedState];
    }

}

-(void)refreshFriends
{
    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    [[APIClient sharedClient] getManageFriends:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *approvedUsers = [[NSMutableArray alloc] init];
        NSMutableArray *notApprovedUsers = [[NSMutableArray alloc] init];
        NSArray *approvedUserData = responseObject[@"friends"];
        NSArray *notApprovedUserData = responseObject[@"removed_friends"];
        for (NSDictionary *userData in approvedUserData) {
            User *user = [[User alloc] initWithUserDictionary:userData];
            if (user) {
                [approvedUsers addObject:user];
            }
        }
        
        for (NSDictionary *userData in notApprovedUserData) {
            User *user = [[User alloc] initWithUserDictionary:userData];
            if (user) {
                [notApprovedUsers addObject:user];
            }
        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        self.approvedUsers = [approvedUsers sortedArrayUsingDescriptors:@[sort]];
        self.notApprovedUsers = [notApprovedUsers sortedArrayUsingDescriptors:@[sort]];
        [self.tableView reloadData];
        [self updateNoFriendsView];
        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    }];
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
    User *user;
    if (indexPath.section == 1) {
        user = self.approvedUsers[indexPath.row];
    } else {
        user = self.notApprovedUsers[indexPath.row];
    }
    
    NSString *userFullName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    NSString *CellIdentifier = [NSString stringWithFormat:@"%ld-%ld-%@", (long)indexPath.section, (long)indexPath.row, userFullName];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, self.view.width/2, 20)];
        userLabel.font = [ThemeManager lightFontOfSize:12];
        [cell.contentView addSubview:userLabel];
        
        if (indexPath.section == 1) {
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:user.username];
            Contact *contact = self.allContacts[normalizedPhoneNumber];
            NSRange range;
            if (contact) {
                userLabel.text = contact.fullName;
                if (contact.firstName) {
                    range = [userLabel.text rangeOfString:[NSString stringWithFormat:@"%@", contact.firstName]];
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:userLabel.text];
                    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
                    userLabel.attributedText = attributedText;
                }
            } else {
                userLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                range = [userLabel.text rangeOfString:user.firstName];
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:userLabel.text];
                [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
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
            removeButton.tag = indexPath.row;
            [removeButton addTarget:self action:@selector(removeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:removeButton];

        } else if (indexPath.section == 2) {
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:user.username];
            Contact *contact = self.allContacts[normalizedPhoneNumber];
            NSRange range;
            if (contact) {
                userLabel.text = contact.fullName;
                if (contact.firstName) {
                    range = [userLabel.text rangeOfString:[NSString stringWithFormat:@"%@", contact.firstName]];
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:userLabel.text];
                    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
                    userLabel.attributedText = attributedText;
                }
            } else {
                userLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                range = [userLabel.text rangeOfString:user.firstName];
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:userLabel.text];
                [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
                userLabel.attributedText = attributedText;
            }
            
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addButton.size = CGSizeMake(65, 25);
            addButton.x = cell.size.width - 90;
            addButton.y = 7.5;
            addButton.layer.cornerRadius = 4;
            addButton.backgroundColor = [UIColor whiteColor];
            addButton.layer.borderColor = [UIColor blackColor].CGColor;
            addButton.layer.borderWidth = 1;
            [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [addButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
            addButton.titleLabel.font = [ThemeManager regularFontOfSize:11];
            [addButton setTitle:@"Add" forState:UIControlStateNormal];
            addButton.tag = indexPath.row;
            [addButton addTarget:self action:@selector(addButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:addButton];
        }
        
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, self.view.width - 60, 20)];
    if (section == 0) {
        UIImageView *headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friends"]];
        headerIcon.centerX = self.tableView.width/2;
        headerIcon.y = 15;
        [view addSubview:headerIcon];
        
        label.font = [ThemeManager boldFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.y = 40;
        label.text = @"FRIENDS ON HOTSPOT";
        
        UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(30, 55, self.view.width - 60, 60)];
        body.textAlignment = NSTextAlignmentCenter;
        body.font = [ThemeManager lightFontOfSize:12];
        body.numberOfLines = 0;
        body.text = @"Add or remove your friends on Hotspot. If you remove a friend, they won't see you check-in. Friend removals are kept completely private.";
        [view addSubview:body];
        
    } else if (section == 1) {
        label.text = @"FRIENDS";
        label.font = [ThemeManager boldFontOfSize:12];
        label.textColor = [[ThemeManager sharedTheme] redColor];
    } else if (section == 2)  {
        label.font = [ThemeManager boldFontOfSize:12];
        label.text = @"OTHER CONTACTS";
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

-(void)removeButtonTouched:(UIButton *)sender
{
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    User *user = self.approvedUsers[sender.tag];
    [[APIClient sharedClient] toggleFriendBlocking:user.userID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self refreshFriends];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self refreshFriends];
    }];
}

-(void)addButtonTouched:(UIButton *)sender
{
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    User *user = self.notApprovedUsers[sender.tag];
    [[APIClient sharedClient] toggleFriendBlocking:user.userID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self refreshFriends];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self refreshFriends];
    }];
}

-(void) changeFacebookButtonToCompletedState
{
    [self.linkFacebookButton setTitle: @"  FACEBOOK LINKED" forState: UIControlStateNormal];
    [self.linkFacebookButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.linkFacebookButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.linkFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) changeFacebookButtonToIncompletedState
{
    [self.linkFacebookButton setTitle: @"LINK FACEBOOK" forState: UIControlStateNormal];
    [self.linkFacebookButton setImage:nil forState:UIControlStateNormal];
    self.linkFacebookButton.backgroundColor = [UIColor clearColor];
    [self.linkFacebookButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
}

-(void) changeContactButtonToActiveState
{
    [self.syncContactsButton setTitle:@"SYNC CONTACTS" forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [UIColor clearColor];
    [self.syncContactsButton setImage:nil forState:UIControlStateNormal];
    [self.syncContactsButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    
}

-(void) changeContactButtonToSelectedState
{
    [self.syncContactsButton setTitle:@"  CONTACTS SYNCED" forState:UIControlStateNormal];
    [self.syncContactsButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.syncContactsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) changeContactButtonToInactiveState
{
    [self.syncContactsButton setTitle:@"SYNC CONTACTS" forState:UIControlStateNormal];
    [self.syncContactsButton setImage:nil forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [UIColor grayColor];
    self.syncContactsButton.layer.borderColor = [UIColor grayColor].CGColor;
}

-(void)facebookButtonTouched
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[UIAlertView alloc] initWithTitle:@"Facebook Linked" message:@"You've already linked your facebook account to Hotspot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
         fromViewController:nil
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//             [self show];
             if (error) {
                 [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error linking Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 NSLog(@"error: %@", error);
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 [[APIClient sharedClient] postFacebookToken:result.token.tokenString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"access token: %@", result.token.tokenString);
                     [self changeFacebookButtonToCompletedState];
                     [self refreshFriends];
//                     [self checkPermissionsAndDismissModal];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [self changeFacebookButtonToIncompletedState];
                     NSLog(@"Facebook token failure");
                 }];
             }
         }];
    }
}


-(void) contactButtonTouched
{
    
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        [LoadingIndictor showLoadingIndicatorInView:self.noFriendsView animated:YES];
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"Granted Contact Permissions");
                [self changeContactButtonToSelectedState];
                [self refreshFriends];
//                [self checkPermissionsAndDismissModal];
            } else {
                [self changeContactButtonToInactiveState];
//                [self checkPermissionsAndDismissModal];
            }
        });
        [LoadingIndictor hideLoadingIndicatorForView:self.noFriendsView animated:YES];
    }
    else if (contactAuthStatus == kABAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"Syncing Contact Permission" message:@"To sync contacts, go to Settings > Hotspot and turn on contact permissions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
        [[[UIAlertView alloc] initWithTitle:@"Contact Synced" message:@"You've already synced your contacts with Hotspot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
