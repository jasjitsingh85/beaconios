//
//  FindFriendsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FindFriendsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Contact.h"
#import "Theme.h"
#import "APIClient.h"
#import "User.h"
#import "Utilities.h"
#import "ContactManager.h"

typedef enum {
    FindFriendSectionUsers=0,
    FindFriendSectionContacts,
} FindFriendSection;

@interface FindFriendsViewController ()

@property (strong, nonatomic) NSArray *nonuserList;
@property (strong, nonatomic) NSArray *userList;
@property (strong, nonatomic) NSMutableDictionary *contactDictionary;
@property (strong, nonatomic) NSMutableDictionary *selectedContacts;

@end

@implementation FindFriendsViewController

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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    
    self.nonuserList = @[];
    self.userList = @[];
    self.selectedContacts = [NSMutableDictionary new];
    self.contactDictionary = [NSMutableDictionary new];
    [[ContactManager sharedManager] fetchContacts:^(NSArray *contacts) {
        self.contactDictionary = [NSMutableDictionary new];
        for (Contact *contact in contacts) {
            [self.contactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
        }
        [self reloadData];
        [self requestFriendsOnBeacons];
        [self requestUserFollowers];
        [self requestNonUserFollowers];
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Add Followers";
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
}

- (void)reloadData
{
    NSArray *allContacts = self.contactDictionary.allValues;
    //separate users and nonusers
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"isUser = %d",YES];
    self.userList = [allContacts filteredArrayUsingPredicate:userPredicate];
    NSPredicate *nonuserPredicate = [NSPredicate predicateWithFormat:@"isUser = %d", NO];
    self.nonuserList = [allContacts filteredArrayUsingPredicate:nonuserPredicate];
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.userList = [self.userList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.nonuserList = [self.nonuserList sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

- (NSArray *)contactsWhoAreNotUsers
{
    NSMutableArray *userNumbers = [NSMutableArray new];
    for (User *user in self.userList) {
        [userNumbers addObject:user.normalizedPhoneNumber];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (normalizedPhoneNumber in %@)", userNumbers];
    NSArray *contactsNotUsers = [self.nonuserList filteredArrayUsingPredicate:predicate];
    return contactsNotUsers;
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == FindFriendSectionUsers) {
        title = @"Users";
    }
    else if (section == FindFriendSectionContacts) {
        title = @"Contacts";
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == FindFriendSectionUsers) {
        numRows = self.userList.count;
    }
    else if (section == FindFriendSectionContacts) {
        numRows = self.nonuserList.count;
    }
    return numRows;
}

#define TAG_NAME_LABEL 1
#define TAG_CHECK_IMAGE 2
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(160, 15);
        frame.origin.x = 58;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        nameLabel.frame = frame;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [ThemeManager boldFontOfSize:14];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.tag = TAG_NAME_LABEL;
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *addFriendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriendNormal"]];
        frame = addFriendImageView.frame;
        frame.origin.x = 8;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        addFriendImageView.frame = frame;
        addFriendImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        addFriendImageView.tag = TAG_CHECK_IMAGE;
        [cell.contentView addSubview:addFriendImageView];
    }
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:TAG_NAME_LABEL];
    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
    NSString *normalizedPhoneNumber;
    Contact *contact;
    if (indexPath.section == FindFriendSectionUsers) {
        contact = self.userList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        contact = self.nonuserList[indexPath.row];
    }
    nameLabel.text = contact.fullName;
    normalizedPhoneNumber = contact.normalizedPhoneNumber;
    BOOL contactSelected = [self.selectedContacts.allKeys containsObject:normalizedPhoneNumber];
    addFriendImageView.image = contactSelected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact;
    if (indexPath.section == FindFriendSectionUsers) {
        contact = self.userList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        contact = self.nonuserList[indexPath.row];
    }
    
    BOOL currentlySelected = [self.selectedContacts.allKeys containsObject:contact.normalizedPhoneNumber];
    if (currentlySelected) {
        [self.selectedContacts removeObjectForKey:contact.normalizedPhoneNumber];
    }
    else {
        [self.selectedContacts setObject:contact forKey:contact.normalizedPhoneNumber];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - buttons
- (void)doneButtonTouched:(id)sender
{
    [self sendFollowersToServer];
    if ([self.delegate respondsToSelector:@selector(findFriendViewController:didPickContacts:)]) {
        [self.delegate findFriendViewController:self didPickContacts:self.selectedContacts.allValues];
    }
}

#pragma mark - Networking
- (void)requestFriendsOnBeacons
{
//    [self showLoadingIndicator];
    NSMutableArray *phoneNumbers = [NSMutableArray new];
    for (Contact *contact in self.nonuserList) {
        [phoneNumbers addObject:contact.phoneNumber];
    }
    NSDictionary *parameters = @{@"phone_number" : phoneNumbers};
    [[APIClient sharedClient] postPath:@"friends/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   [self hideLoadingIndicator];
                                   for (NSDictionary *userData in responseObject) {
                                       NSString *phoneNumber = userData[@"phone_number"];
                                       NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                       Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                       contact.isUser = YES;
                                   }
                                   [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [self hideLoadingIndicator];
                               }];
}

- (void)requestUserFollowers
{
//    [self showLoadingIndicator];
    NSDictionary *parameters = @{@"type" : @"users"};
    [[APIClient sharedClient] getPath:@"friends/broadcast/" parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self hideLoadingIndicator];
                                  for (NSDictionary *userData in responseObject) {
                                      NSString *phoneNumber = userData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          [self.selectedContacts setObject:contact forKey:normalizedPhoneNumber];
                                      }
                                  }
                                  [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self hideLoadingIndicator];
        
    }];
}

- (void)requestNonUserFollowers
{
//    [self showLoadingIndicator];
    NSDictionary *parameters = @{@"type" : @"contacts"};
    [[APIClient sharedClient] getPath:@"friends/broadcast/" parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self hideLoadingIndicator];
                                  for (NSDictionary *contactData in responseObject) {
                                      NSString *phoneNumber = contactData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          [self.selectedContacts setObject:contact forKey:normalizedPhoneNumber];
                                      }
                                  }
                                  [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self hideLoadingIndicator];
        
    }];
}

- (void)sendFollowersToServer
{
    if (!self.selectedContacts.count) {
        return;
    }
    NSMutableArray *nonUserFollows = [NSMutableArray new];
    for (Contact *contact in self.selectedContacts.allValues) {
        NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
        [nonUserFollows addObject:contactString];
    }
    NSDictionary *parameters = @{@"contact" : nonUserFollows};
    [[APIClient sharedClient] postPath:@"friends/broadcast/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   
                               }];
}

#pragma mark - Loading Indicator
- (void)showLoadingIndicator
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
}

- (void)hideLoadingIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

@end
