//
//  FindFriendsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "Contact.h"
#import "Theme.h"
#import "APIClient.h"
#import "User.h"
#import "Utilities.h"
#import "ContactManager.h"
#import "LoadingIndictor.h"

typedef enum {
    FindFriendSectionSuggested=0,
    FindFriendSectionContacts,
} FindFriendSection;

@interface FindFriendsViewController ()

@property (strong, nonatomic) NSArray *suggestedList;
@property (strong, nonatomic) NSArray *nonSuggestedList;
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
    
    self.suggestedList = @[];
    self.nonSuggestedList = @[];
    self.selectedContacts = [NSMutableDictionary new];
    self.contactDictionary = [NSMutableDictionary new];
    [[ContactManager sharedManager] fetchContacts:^(NSArray *contacts) {
        self.contactDictionary = [NSMutableDictionary new];
        for (Contact *contact in contacts) {
            [self.contactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
        }
        [self reloadData];
        [self requestSuggested];
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
    NSPredicate *suggestedPredicate = [NSPredicate predicateWithFormat:@"isSuggested = %d",YES];
    self.suggestedList = [allContacts filteredArrayUsingPredicate:suggestedPredicate];
    NSPredicate *nonSuggestedPredicate = [NSPredicate predicateWithFormat:@"isSuggested = %d", NO];
    self.nonSuggestedList = [allContacts filteredArrayUsingPredicate:nonSuggestedPredicate];
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == FindFriendSectionSuggested) {
        title = @"Close Friends";
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
    if (section == FindFriendSectionSuggested) {
        numRows = self.suggestedList.count;
    }
    else if (section == FindFriendSectionContacts) {
        numRows = self.nonSuggestedList.count;
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
    if (indexPath.section == FindFriendSectionSuggested) {
        contact = self.suggestedList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        contact = self.nonSuggestedList[indexPath.row];
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
    if (indexPath.section == FindFriendSectionSuggested) {
        contact = self.suggestedList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        contact = self.nonSuggestedList[indexPath.row];
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
- (void)requestSuggested
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getPath:@"friends/" parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                                  NSArray *contacts = responseObject[@"contacts"];
                                  NSArray *users = responseObject[@"users"];
                                  for (NSDictionary *contactData in contacts) {
                                      NSString *phoneNumber = contactData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          contact.isSuggested = YES;
                                          [self.selectedContacts setObject:contact forKey:normalizedPhoneNumber];
                                      }
                                  }
                                  for (NSDictionary *userData in users) {
                                      NSString *phoneNumber = userData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          contact.isSuggested = YES;
                                          contact.isUser = YES;
                                          [self.selectedContacts setObject:contact forKey:normalizedPhoneNumber];
                                      }
                                  }
                                  [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

- (void)sendFollowersToServer
{
    if (!self.selectedContacts.count) {
        return;
    }
    NSMutableArray *invites = [NSMutableArray new];
    for (Contact *contact in self.selectedContacts.allValues) {
        NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
        [invites addObject:contactString];
    }
    NSDictionary *parameters = @{@"invite" : invites};
    [[APIClient sharedClient] postPath:@"beacon/me/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   
                               }];
}


@end
