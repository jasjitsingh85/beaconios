//
//  FindFriendsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FindFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>
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

@interface FindFriendsViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *recentsList;
@property (strong, nonatomic) NSArray *suggestedList;
@property (strong, nonatomic) NSArray *nonSuggestedList;
@property (strong, nonatomic) NSMutableDictionary *contactDictionary;
@property (strong, nonatomic) NSMutableDictionary *selectedContactDictionary;
@property (strong, nonatomic) NSMutableDictionary *inactiveContactDictionary;
@property (strong, nonatomic) NSMutableDictionary *tableViewHeaderPool;
@property (strong, nonatomic) NSMutableDictionary *selectAllButtonPool;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *inviteButton;
@property (strong, nonatomic) UIButton *skipButton;
@property (assign, nonatomic) BOOL inviteButtonShown;
@property (assign, nonatomic) BOOL inSearchMode;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *searchBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBarBackgroundView.backgroundColor = [[ThemeManager sharedTheme] redColor];
    [self.view addSubview:searchBarBackgroundView];
    self.searchBar = [[UISearchBar alloc] initWithFrame:searchBarBackgroundView.bounds];
    self.searchBar.delegate = self;
//    self.searchBar.backgroundColor = [[ThemeManager sharedTheme] redColor];
    self.searchBar.barTintColor = [UIColor clearColor];
//    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.translucent = NO;
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    [searchBarBackgroundView addSubview:self.searchBar];
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    self.inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    self.inviteButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.inviteButton.backgroundColor = [UIColor colorWithRed:120/255.0 green:183/255.0 blue:200/255.0 alpha:1.0];
    self.inviteButton.titleLabel.font = [ThemeManager lightFontOfSize:16];
    [self.inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.inviteButton setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    self.inviteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 270, 0, 0);
    [self.inviteButton addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inviteButton];
    self.inviteButtonShown = YES;
    [self hideInviteButton:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Invite Friends";
    self.skipButton = [[UIButton alloc] init];
    self.skipButton.frame = CGRectMake(0, 0, 50, 30);
    self.skipButton.backgroundColor = [UIColor whiteColor];
    self.skipButton.layer.cornerRadius = 4;
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = [ThemeManager regularFontOfSize:12];
    [self.skipButton addTarget:self action:@selector(doneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *skipButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.skipButton];
    self.navigationItem.rightBarButtonItem = skipButtonItem;
    
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
    self.nonSuggestedList = allContacts;
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.recentsList = [self.recentsList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

- (void)reloadDataWithSearchText:(NSString *)searchText
{
    NSArray *allContacts = self.contactDictionary.allValues;
    //separate users and nonusers
    self.recentsList = @[];
    self.suggestedList = @[];
    NSPredicate *nonsuggestedPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", searchText];
    self.nonSuggestedList = [allContacts filteredArrayUsingPredicate:nonsuggestedPredicate];
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.recentsList = [self.recentsList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

- (void)showInviteButton:(BOOL)animated
{
    if (self.inviteButtonShown) {
        return;
    }
    self.inviteButtonShown = YES;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.inviteButton.transform = CGAffineTransformIdentity;
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = self.inviteButton.frame.size.height;
        self.tableView.contentInset = insets;
    }];
}

- (void)hideInviteButton:(BOOL)animated
{
    if (!self.inviteButtonShown) {
        return;
    }
    self.inviteButtonShown = NO;
    self.inviteButton.transform = CGAffineTransformIdentity;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.inviteButton.transform = CGAffineTransformMakeTranslation(0, self.inviteButton.frame.size.height);
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = 0;
        self.tableView.contentInset = insets;
    }];
}

- (void)hideSkipButton:(BOOL)animated
{
    if (!self.skipButton.alpha) {
        return;
    }
    
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.skipButton.alpha = 0.0;
    }];
}

- (void)showSkipButton:(BOOL)animated
{
    if (self.skipButton.alpha) {
        return;
    }
    
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.skipButton.alpha = 1.0;
    }];
}

- (void)updateInviteButtonText:(Contact *)lastSelectedContact
{
    NSString *inviteButtonText = @"";
    if (self.selectedContactDictionary.count) {
        [self hideSkipButton:YES];
        Contact *contact = lastSelectedContact ? lastSelectedContact : [self.selectedContactDictionary.allValues firstObject];
        if (self.selectedContactDictionary.count == 1) {
            inviteButtonText = [NSString stringWithFormat:@"Invite %@", contact.firstName];
        }
        else {
            inviteButtonText = [NSString stringWithFormat:@"%@ +%d", contact.firstName, self.selectedContactDictionary.count - 1];
        }
    }
    else {
        [self showSkipButton:YES];
    }
    [self.inviteButton setTitle:inviteButtonText forState:UIControlStateNormal];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = self.inSearchMode ? 0 : 30;
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.inSearchMode) {
        return nil;
    }
    if (!self.tableViewHeaderPool) {
        self.tableViewHeaderPool = [NSMutableDictionary new];
    }
    NSString *key = @(section).stringValue;
    if ([self.tableViewHeaderPool valueForKey:key]) {
        return [self.tableViewHeaderPool valueForKey:key];
    }
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height)];
    view.backgroundColor = [[ThemeManager sharedTheme] redColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 83, height)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [ThemeManager boldFontOfSize:14.0];
    title.textColor = [UIColor whiteColor];
    [view addSubview:title];
    title.text = [self tableView:tableView titleForHeaderInSection:section];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1;
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = CGSizeMake(95, 3/4.0*height);
    buttonFrame.origin.x = self.tableView.frame.size.width - buttonFrame.size.width - 30;
    buttonFrame.origin.y = 0.5*(height - buttonFrame.size.height);
    button.frame = buttonFrame;
    [view addSubview:button];
    button.titleLabel.font = [ThemeManager lightFontOfSize:12.0];
    [button setTitle:@"Select All" forState:UIControlStateNormal];
    [button setTitle:@"Unselect All" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selectAllButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 4;
    button.backgroundColor = [UIColor clearColor];
    [self.tableViewHeaderPool setValue:view forKey:key];
    [self setSelectAllButton:button forSection:section];
    return view;
}

- (void)setSelectAllButton:(UIButton *)button forSection:(NSInteger)section
{
    if (!self.selectAllButtonPool) {
        self.selectAllButtonPool = [NSMutableDictionary new];
    }
    NSString *key = @(section).stringValue;
    [self.selectAllButtonPool setValue:button forKey:key];
}

- (UIButton *)selectAllButtonForSection:(NSInteger)section
{
    return [self.selectAllButtonPool valueForKey:@(section).stringValue];
}

- (void)selectAllButtonTouched:(UIButton *)button
{
    button.selected = !button.selected;
    NSInteger section = [[self.selectAllButtonPool allKeysForObject:button][0] integerValue];
    [self setSelected:button.selected forAllContactsInSection:section];
}

- (void)setSelected:(BOOL)selected forAllContactsInSection:(FindFriendSection)section
{
    [self reloadData];
    NSArray *contactList;
    if (section == FindFriendSectionRecents) {
        contactList = self.recentsList;
    }
    else if (section == FindFriendSectionSuggested) {
        contactList = self.suggestedList;
    }
    else if (section == FindFriendSectionContacts) {
        contactList = self.nonSuggestedList;
    }
    for (Contact *contact in contactList) {
        if (selected) {
            [self selectContact:contact];
        }
        else {
            [self unselectContact:contact];
        }
    }
    UIButton *selectAllButton = [self.selectAllButtonPool valueForKey:@(section).stringValue];
    selectAllButton.selected = selected;
    selectAllButton.backgroundColor = selectAllButton.selected ? [UIColor whiteColor] : [UIColor clearColor];
    [self.tableView reloadData];
}

- (void)selectContact:(Contact *)contact
{
    BOOL contactInactive = [self.inactiveContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
    if (contactInactive) {
        return;
    }
    [self.selectedContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
    [self updateInviteButtonText:contact];
    if (self.selectedContactDictionary.count) {
        [self showInviteButton:YES];
    }
}

- (void)unselectContact:(Contact *)contact
{
    [self.selectedContactDictionary removeObjectForKey:contact.normalizedPhoneNumber];
    [self updateInviteButtonText:nil];
    if (!self.selectedContactDictionary.count) {
        [self hideInviteButton:YES];
    }
}

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
        frame.origin.x = 60;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        nameLabel.frame = frame;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [ThemeManager regularFontOfSize:14];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.tag = TAG_NAME_LABEL;
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *addFriendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriendNormal"]];
        frame = addFriendImageView.frame;
        frame.size = CGSizeMake(30, 30);
        frame.origin.x = 15;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        addFriendImageView.frame = frame;
        addFriendImageView.contentMode = UIViewContentModeCenter;
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
    CGFloat scale = contactSelected ? 1.35 : 1.0;
    addFriendImageView.transform = CGAffineTransformMakeScale(scale, scale);
    if (contactInactive) {
        nameLabel.textColor = [UIColor lightGrayColor];
        addFriendImageView.image = [UIImage imageNamed:@"addFriendInactive"];
        addFriendImageView.transform = CGAffineTransformIdentity;
    }
    else {
        nameLabel.textColor = [UIColor blackColor];
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
        NSString *message = [NSString stringWithFormat:@"%@ has already been invited", contact.fullName];
        [[[UIAlertView alloc] initWithTitle:@"Friends don't spam friends" message:message delegate:nil cancelButtonTitle:@"I'm Sorry" otherButtonTitles:nil] show];
        return;
    }
    
    BOOL currentlySelected = [self.selectedContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
    if (currentlySelected) {
        [self unselectContact:contact];
    }
    else {
        [self selectContact:contact];
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self animateSelectingContactInCell:cell selected:!currentlySelected completion:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.inSearchMode) {
            [self exitSearchMode];
        }
    }];
}

- (void)animateSelectingContactInCell:(UITableViewCell *)cell selected:(BOOL)selected completion:(void(^) ())completion
{
    UIImage *image = selected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
    addFriendImageView.image = image;
    CGFloat scale = selected ? 1.35 : 1.0;
    CGFloat damping = selected ? 0.25 : 0.5;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
        addFriendImageView.transform = CGAffineTransformMakeScale(scale, scale);
        [cell layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length) {
        [self reloadDataWithSearchText:searchText];
    }
    else {
        [self reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

- (void)exitSearchMode
{
    self.searchBar.text = nil;
    [self.searchBar endEditing:YES];
    [self reloadData];
}



#pragma mark - buttons
- (void)doneButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(findFriendViewController:didPickContacts:)]) {
        [self.delegate findFriendViewController:self didPickContacts:self.selectedContactDictionary.allValues];
    }
}

- (void)inviteButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(findFriendViewController:didPickContacts:)]) {
        [self.delegate findFriendViewController:self didPickContacts:self.selectedContactDictionary.allValues];
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.inSearchMode = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.inSearchMode = NO;
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
                                      }
                                  }
                                  if (self.autoCheckSuggested) {
                                      [self setSelected:YES forAllContactsInSection:FindFriendSectionRecents];
                                  }
                                  [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}


@end
