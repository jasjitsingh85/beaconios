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
    FindFriendSectionRecents=0,
    FindFriendSectionSuggested,
    FindFriendSectionContacts,
} FindFriendSection;

@interface FindFriendsViewController ()

@property (strong, nonatomic) NSArray *recentsList;
@property (strong, nonatomic) NSArray *suggestedList;
@property (strong, nonatomic) NSArray *nonSuggestedList;
@property (strong, nonatomic) NSMutableDictionary *contactDictionary;
@property (strong, nonatomic) NSMutableDictionary *selectedContactDictionary;
@property (strong, nonatomic) NSMutableDictionary *inactiveContactDictionary;

@end

@implementation FindFriendsViewController

- (NSMutableDictionary *)selectedContactDictionary
{
    if (!_selectedContactDictionary) {
        _selectedContactDictionary = [NSMutableDictionary new];
    }
    return _selectedContactDictionary;
}

- (NSMutableDictionary *)inactiveContactDictionary
{
    if (!_inactiveContactDictionary) {
        _inactiveContactDictionary = [NSMutableDictionary new];
    }
    return _inactiveContactDictionary;
}

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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Invite Friends";
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    
    self.suggestedList = @[];
    self.nonSuggestedList = @[];
    self.contactDictionary = [NSMutableDictionary new];
    [[ContactManager sharedManager] fetchContacts:^(NSArray *contacts) {
        self.contactDictionary = [NSMutableDictionary new];
        for (Contact *contact in contacts) {
            [self.contactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
        }
        [self reloadData];
        [self requestSuggested];
        if (self.selectedContacts) {
            for (Contact *contact in self.selectedContacts) {
                [self.selectedContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
            }
        }
        if (self.inactiveContacts) {
            for (Contact *contact in self.inactiveContacts) {
                [self.inactiveContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
}

- (void)reloadData
{
    NSArray *allContacts = self.contactDictionary.allValues;
    //separate users and nonusers
    NSPredicate *recentPredicate = [NSPredicate predicateWithFormat:@"isRecent = %d", YES];
    self.recentsList = [allContacts filteredArrayUsingPredicate:recentPredicate];
    NSPredicate *suggestedPredicate = [NSPredicate predicateWithFormat:@"isSuggested = %d && isRecent = %d",YES, NO];
    self.suggestedList = [allContacts filteredArrayUsingPredicate:suggestedPredicate];
    NSPredicate *nonSuggestedPredicate = [NSPredicate predicateWithFormat:@"isSuggested = %d", NO];
    self.nonSuggestedList = [allContacts filteredArrayUsingPredicate:nonSuggestedPredicate];
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.recentsList = [self.recentsList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == FindFriendSectionRecents) {
        title = @"Recents";
    }
    else if (section == FindFriendSectionSuggested) {
        title = @"Suggested";
    }
    else if (section == FindFriendSectionContacts) {
        title = @"Contacts";
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == FindFriendSectionRecents) {
        numRows = self.recentsList.count;
    }
    else if (section == FindFriendSectionSuggested) {
        numRows = self.suggestedList.count;
    }
    else if (section == FindFriendSectionContacts) {
        numRows = self.nonSuggestedList.count;
    }
    return numRows;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    if (self.isDisplayingKeyboard) {
//        return nil;
//    }
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    BOOL found = NO;
    NSInteger i = 0;
    NSInteger newRow = 0;
    while (!found && i < self.nonSuggestedList.count) {
        Contact *contact = self.nonSuggestedList[i];
        NSString *contactName = contact.firstName;
        NSRange range = NSMakeRange(0, 1);
        if (contactName.length && [[contactName substringWithRange:range] isEqualToString:title]) {
            found = YES;
            newRow = [self.nonSuggestedList indexOfObject:contact];
        }
        i++;
    }
    
    if (found) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:FindFriendSectionContacts];
        [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    return index;
}

#define TAG_NAME_LABEL 2
#define TAG_CHECK_IMAGE 3
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
    if (indexPath.section == FindFriendSectionRecents) {
        contact = self.recentsList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionSuggested) {
        contact = self.suggestedList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        contact = self.nonSuggestedList[indexPath.row];
    }
    nameLabel.text = contact.fullName;
    normalizedPhoneNumber = contact.normalizedPhoneNumber;
    BOOL contactInactive = [self.inactiveContactDictionary.allKeys containsObject:normalizedPhoneNumber];
    BOOL contactSelected = [self.selectedContactDictionary.allKeys containsObject:normalizedPhoneNumber];
    addFriendImageView.image = contactSelected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
    if (contactInactive) {
        nameLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        nameLabel.textColor = contact.isUser ? [[ThemeManager sharedTheme] orangeColor] : [UIColor blackColor];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact;
    if (indexPath.section == FindFriendSectionRecents) {
        contact = self.recentsList[indexPath.row];
    }
    if (indexPath.section == FindFriendSectionSuggested) {
        contact = self.suggestedList[indexPath.row];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        contact = self.nonSuggestedList[indexPath.row];
    }
    
    BOOL inactiveContact = [self.inactiveContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
    if (inactiveContact) {
        return;
    }
    
    BOOL currentlySelected = [self.selectedContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
    if (currentlySelected) {
        [self.selectedContactDictionary removeObjectForKey:contact.normalizedPhoneNumber];
    }
    else {
        [self.selectedContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - buttons
- (void)doneButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(findFriendViewController:didPickContacts:)]) {
        NSMutableSet *contactSet = [NSMutableSet setWithArray:self.selectedContactDictionary.allValues];
        [contactSet minusSet:[NSSet setWithArray:self.inactiveContactDictionary.allValues]];
        [self.delegate findFriendViewController:self didPickContacts:contactSet.allObjects];
    }
}

#pragma mark - Networking
- (void)requestSuggested
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getPath:@"friends/" parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                                  if (self.autoCheckSuggested) {
                                      self.selectedContactDictionary = [NSMutableDictionary new];
                                  }
                                  NSArray *contacts = responseObject[@"contacts"];
                                  NSArray *users = responseObject[@"users"];
                                  NSArray *recentUsers = responseObject[@"profile_recents"];
                                  NSArray *recentContacts = responseObject[@"contacts_recents"];
                                  for (NSDictionary *contactData in contacts) {
                                      NSString *phoneNumber = contactData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          contact.isSuggested = YES;
                                      }
                                  }
                                  for (NSDictionary *contactData in recentContacts) {
                                      NSString *phoneNumber = contactData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          contact.isSuggested = YES;
                                          contact.isRecent = YES;
                                          if (self.autoCheckSuggested) {
                                              [self.selectedContactDictionary setObject:contact forKey:normalizedPhoneNumber];
                                          }
                                      }
                                  }
                                  for (NSDictionary *userData in users) {
                                      NSString *phoneNumber = userData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          contact.isSuggested = YES;
                                          contact.isUser = YES;
                                      }
                                  }
                                  for (NSDictionary *userData in recentUsers) {
                                      NSString *phoneNumber = userData[@"phone_number"];
                                      NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
                                      Contact *contact = self.contactDictionary[normalizedPhoneNumber];
                                      if (contact) {
                                          contact.isSuggested = YES;
                                          contact.isUser = YES;
                                          contact.isRecent = YES;
                                          if (self.autoCheckSuggested) {
                                              [self.selectedContactDictionary setObject:contact forKey:normalizedPhoneNumber];
                                          }
                                      }
                                  }
                                  [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}


@end
