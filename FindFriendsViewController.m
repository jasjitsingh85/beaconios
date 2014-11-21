//
//  FindFriendsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FindFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "GroupsViewController.h"
#import "UIButton+HSNavButton.h"
#import "Contact.h"
#import "Theme.h"
#import "APIClient.h"
#import "User.h"
#import "Group.h"
#import "Deal.h"
#import "Utilities.h"
#import "ContactManager.h"
#import "LoadingIndictor.h"
#import "NavigationBarTitleLabel.h"

@interface FindFriendsViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *usersInContactsList;
@property (strong, nonatomic) NSArray *recentsList;
@property (strong, nonatomic) NSArray *suggestedList;
@property (strong, nonatomic) NSArray *nonSuggestedList;
@property (strong, nonatomic) NSMutableDictionary *contactDictionary;
@property (strong, nonatomic) NSMutableDictionary *selectedContactDictionary;
@property (strong, nonatomic) NSMutableDictionary *inactiveContactDictionary;
@property (strong, nonatomic) NSMutableDictionary *tableViewHeaderPool;
@property (strong, nonatomic) NSMutableDictionary *selectAllButtonPool;
@property (strong, nonatomic) NSMutableSet *collapsedSections;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *inviteButton;
@property (assign, nonatomic) BOOL inviteButtonShown;
@property (assign, nonatomic) BOOL inSearchMode;
@property (strong, nonatomic) NSArray *groups;
@property (readonly) NSInteger findFriendSectionAllUsers;
@property (readonly) NSInteger findFriendSectionRecents;
@property (readonly) NSInteger findFriendSectionSuggested;
@property (readonly) NSInteger findFriendSectionContacts;

@end

#define selectedTransform CGAffineTransformMakeScale(1.35, 1.35)

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

- (NSMutableSet *)collapsedSections
{
    if (!_collapsedSections) {
        _collapsedSections = [[NSMutableSet alloc] init];
    }
    return _collapsedSections;
}

- (NSInteger)findFriendSectionAllUsers
{
    return self.groups.count;
}

- (NSInteger)findFriendSectionRecents
{
    return self.groups.count + 1;
}

- (NSInteger)findFriendSectionSuggested
{
    return self.groups.count + 2;
}

- (NSInteger)findFriendSectionContacts
{
    return self.groups.count + 3;
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
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    //weird hack for black search bar issue
    self.searchBar.backgroundImage = [UIImage new];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [[ThemeManager sharedTheme] redColor];
    self.searchBar.translucent = NO;
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    [self.view addSubview:self.searchBar];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    UIView *inviteButtonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 61, self.view.width, 61)];
    inviteButtonBackground.backgroundColor = [UIColor whiteColor];
    inviteButtonBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:inviteButtonBackground];
    self.inviteButton = [[UIButton alloc] init];
    self.inviteButton.size = CGSizeMake(249, 35);
    self.inviteButton.centerX = inviteButtonBackground.width/2.0;
    self.inviteButton.centerY = inviteButtonBackground.height/2.0;
    self.inviteButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    self.inviteButton.titleLabel.font = [ThemeManager regularFontOfSize:1.3*15];
    [self.inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.inviteButton addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [inviteButtonBackground addSubview:self.inviteButton];
    [self updateInviteButtonText:nil];
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = self.inviteButton.frame.size.height;
    self.tableView.contentInset = insets;
    self.inviteButtonShown = YES;
    
    self.tableView.rowHeight = 40;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Select Friends"];
    if (self.deal) {
        [self updateNavTitleForDeal:self.deal];
    }
    UIButton *groupsButton = [UIButton navButtonWithTitle:@"Groups"];
    [groupsButton addTarget:self action:@selector(groupsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupsButton];
    
    NSOperation *updateFriendsOperation = [ContactManager sharedManager].updateFriendsOperation;
    if (updateFriendsOperation && !updateFriendsOperation.isFinished) {
        [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
        NSBlockOperation *populateOperation = [NSBlockOperation blockOperationWithBlock:^{
            //total hack. wait for url operation completion block to finish before populating contacts
            jadispatch_after_delay(1, dispatch_get_main_queue(), ^{
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                [self populateContacts];
            });
        }];
        [populateOperation addDependency:updateFriendsOperation];
        [[NSOperationQueue mainQueue] addOperation:populateOperation];
    }
    else {
        [self populateContacts];
    }
}

- (void)groupsButtonTouched:(id)sender
{
    GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
    [self.navigationController pushViewController:groupsViewController animated:YES];
}

- (void)setDeal:(Deal *)deal
{
    [self view];
    _deal = deal;
    [self updateNavTitleForDeal:deal];
    [self updateInviteButtonTextForDeal:nil];
}

- (void)updateNavTitleForDeal:(Deal *)deal
{
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:[NSString stringWithFormat:@"Select %@ Friends!", deal.inviteRequirement]];
}

- (void)populateContacts
{
    self.suggestedList = @[];
    self.nonSuggestedList = @[];
    self.contactDictionary = [NSMutableDictionary new];
    [[ContactManager sharedManager] fetchAddressBookContacts:^(NSArray *contacts) {
        self.contactDictionary = [NSMutableDictionary new];
        for (Contact *contact in contacts) {
            [self.contactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
        }
        [[ContactManager sharedManager] getGroups:^(NSArray *groups) {
            self.tableViewHeaderPool = nil;
            self.groups = groups;
            [self collapseGroupSections];
            [self reloadData];
        } failure:nil];
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

- (void)collapseGroupSections
{
    [self.collapsedSections removeAllObjects];
    for (NSInteger i=0;i<self.groups.count;i++) {
        [self.collapsedSections addObject:@(i)];
    }
}

- (void)reloadData
{
    NSArray *allContacts = self.contactDictionary.allValues;
    NSPredicate *allUsersPredicate = [NSPredicate predicateWithFormat:@"isAllUser = %d", YES];
    self.usersInContactsList = [allContacts filteredArrayUsingPredicate:allUsersPredicate];
    //separate users and nonusers
    NSPredicate *recentPredicate = [NSPredicate predicateWithFormat:@"isRecent = %d", YES];
    self.recentsList = [allContacts filteredArrayUsingPredicate:recentPredicate];
    NSPredicate *suggestedPredicate = [NSPredicate predicateWithFormat:@"isSuggested = %d && isRecent = %d",YES, NO];
    self.suggestedList = [allContacts filteredArrayUsingPredicate:suggestedPredicate];
    self.nonSuggestedList = allContacts;
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.usersInContactsList = [self.usersInContactsList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.recentsList = [self.recentsList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

- (void)reloadDataWithSearchText:(NSString *)searchText
{
    NSArray *allContacts = self.contactDictionary.allValues;
    //separate users and nonusers
    self.usersInContactsList = @[];
    self.recentsList = @[];
    self.suggestedList = @[];
    NSPredicate *nonsuggestedPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", searchText];
    self.nonSuggestedList = [allContacts filteredArrayUsingPredicate:nonsuggestedPredicate];
    
    //sort both lists by name
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    self.usersInContactsList = [self.usersInContactsList sortedArrayUsingDescriptors:@[sortDescriptor]];
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
    self.tableView.contentInset = UIEdgeInsetsZero;
}

- (void)updateInviteButtonText:(Contact *)lastSelectedContact
{
    if (self.deal) {
        [self updateInviteButtonTextForDeal:lastSelectedContact];
        return;
    }
    NSString *inviteButtonText = @"Invite";
    if (self.selectedContactDictionary.count) {
        Contact *contact = lastSelectedContact ? lastSelectedContact : [self.selectedContactDictionary.allValues firstObject];
        if (self.selectedContactDictionary.count == 1) {
            inviteButtonText = [NSString stringWithFormat:@"Invite %@", contact.firstName];
        }
        else {
            NSInteger otherCount = self.selectedContactDictionary.count - 1;
            NSString *plural = otherCount == 1 ? @"other" : @"others";
            inviteButtonText = [NSString stringWithFormat:@"Invite %@ and %d %@", contact.firstName, otherCount, plural];
        }
    }
    [self.inviteButton setTitle:inviteButtonText forState:UIControlStateNormal];
}

- (void)updateInviteButtonTextForDeal:(Contact *)lastSelectedContact
{
    [self.inviteButton setTitle:@"Unlock Deal" forState:UIControlStateNormal];
    
    UIImage *chevronImage = [UIImage imageNamed:@"whiteChevron"];
    [self.inviteButton setImage:[UIImage imageNamed:@"whiteChevron"] forState:UIControlStateNormal];
    self.inviteButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteButton.frame.size.width - (chevronImage.size.width + 55.), 0., 0.);
    
}

#pragma mark - Table view data source
- (Group *)groupForSection:(NSInteger)section
{
    Group *group;
    if (section < self.groups.count) {
        group = self.groups[section];
    }
    return group;
}

- (BOOL)sectionIsCollapsed:(NSInteger)section
{
    return [self.collapsedSections containsObject:@(section)];
}

- (void)collapseSection:(NSInteger)section
{
    [self.collapsedSections addObject:@(section)];
    NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<numRowsExpanded; i++) {
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
}

- (void)uncollapseSection:(NSInteger)section
{
    [self.collapsedSections removeObject:@(section)];
    NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<numRowsExpanded; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = self.inSearchMode ? 0 : tableView.rowHeight;
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
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(59, 0, 150, height)];
    title.adjustsFontSizeToFitWidth = YES;
    title.backgroundColor = [UIColor clearColor];
    title.font = [ThemeManager boldFontOfSize:14.0];
    title.textColor = [UIColor whiteColor];
    [view addSubview:title];
    title.text = [self tableView:tableView titleForHeaderInSection:section];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = CGSizeMake(height, height);
    buttonFrame.origin.x = 15 + (30 - buttonFrame.size.width)/2.0;
    buttonFrame.origin.y = 0.5*(height - buttonFrame.size.height);
    button.frame = buttonFrame;
    [view addSubview:button];
    [button setImage:[UIImage imageNamed:@"addFriendWhite"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"addFriendSelected"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selectAllButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *contactCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.width - 32, height)];
    contactCountLabel.textAlignment = NSTextAlignmentRight;
    contactCountLabel.font = [ThemeManager lightFontOfSize:1.3*8];
    contactCountLabel.textColor = [UIColor whiteColor];
    NSInteger contactCount = [self tableView:tableView  numberOfRowsInExpandedSection:section];
    NSString *contactPlural = contactCount == 1 ? @"Contact" : @"Contacts";
    contactCountLabel.text = [NSString stringWithFormat:@"%d %@", contactCount, contactPlural];
    [view addSubview:contactCountLabel];
    
    [self.tableViewHeaderPool setValue:view forKey:key];
    [self setSelectAllButton:button forSection:section];
    view.tag = section;
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    [view addGestureRecognizer:headerTap];
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

- (void)headerTapped:(UITapGestureRecognizer *)tap
{
    NSInteger section = tap.view.tag;
    if ([self sectionIsCollapsed:section]) {
        [self uncollapseSection:section];
    }
    else {
        [self collapseSection:section];
    }
}

- (void)selectAllButtonTouched:(UIButton *)button
{
    button.selected = !button.selected;
    NSInteger section = [[self.selectAllButtonPool allKeysForObject:button][0] integerValue];
    [self setSelected:button.selected forAllContactsInSection:section];
}

- (void)setSelected:(BOOL)selected forAllContactsInSection:(NSInteger)section
{
    NSArray *contactList;
    Group *group = [self groupForSection:section];
    if (group) {
        contactList = group.contacts;
    } else if (section == self.findFriendSectionAllUsers) {
        contactList = self.usersInContactsList;
    }
    else if (section == self.findFriendSectionRecents) {
        contactList = self.recentsList;
    }
    else if (section == self.findFriendSectionSuggested) {
        contactList = self.suggestedList;
    }
    else if (section == self.findFriendSectionContacts) {
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
    CGFloat damping = selected ? 0.25 : 0.5;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
        selectAllButton.transform = selected ? selectedTransform : CGAffineTransformIdentity;
    } completion:nil];
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
}

- (void)unselectContact:(Contact *)contact
{
    [self.selectedContactDictionary removeObjectForKey:contact.normalizedPhoneNumber];
    [self updateInviteButtonText:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    Group *group = [self groupForSection:section];
    if (group) {
        title = group.name;
    } else  if (section == self.findFriendSectionAllUsers) {
        title = @"Friends on Hotspot";
    }
    else  if (section == self.findFriendSectionRecents) {
        title = @"Recents";
    }
    else if (section == self.findFriendSectionSuggested) {
        title = @"Suggested";
    }
    else if (section == self.findFriendSectionContacts) {
        title = @"Contacts";
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4 + self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if ([self sectionIsCollapsed:section]) {
        numRows = 0;
    }
    else {
        numRows = [self tableView:tableView numberOfRowsInExpandedSection:section];
    }
    return numRows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInExpandedSection:(NSInteger)section
{
    NSInteger numRows = 0;
    Group *group = [self groupForSection:section];
    if (group) {
        Group *group = self.groups[section];
        numRows = group.contacts.count;
    } else if (section == self.findFriendSectionAllUsers) {
        numRows = self.usersInContactsList.count;
    }
    else if (section == self.findFriendSectionRecents) {
        numRows = self.recentsList.count;
    }
    else if (section == self.findFriendSectionSuggested) {
        numRows = self.suggestedList.count;
    }
    else if (section == self.findFriendSectionContacts) {
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
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:self.findFriendSectionContacts];
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
        frame.size = CGSizeMake(160, tableView.rowHeight);
        frame.origin.x = 60;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        nameLabel.frame = frame;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [ThemeManager lightFontOfSize:14];
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
    if (indexPath.section < self.groups.count) {
        Group *group = self.groups[indexPath.section];
        contact = group.contacts[indexPath.row];
    }
    if (!contact) {
    if (indexPath.section == self.findFriendSectionRecents) {
        contact = self.recentsList[indexPath.row];
    } else if (indexPath.section == self.findFriendSectionAllUsers) {
        contact = self.usersInContactsList[indexPath.row];
    }
    else if (indexPath.section == self.findFriendSectionSuggested) {
        contact = self.suggestedList[indexPath.row];
    }
    else if (indexPath.section == self.findFriendSectionContacts) {
        contact = self.nonSuggestedList[indexPath.row];
    }
    }
    nameLabel.text = contact.fullName;
    normalizedPhoneNumber = contact.normalizedPhoneNumber;
    BOOL contactInactive = [self.inactiveContactDictionary.allKeys containsObject:normalizedPhoneNumber];
    BOOL contactSelected = [self.selectedContactDictionary.allKeys containsObject:normalizedPhoneNumber];
    addFriendImageView.image = contactSelected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
    addFriendImageView.transform = contactSelected ? selectedTransform : CGAffineTransformIdentity;
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
    if (indexPath.section < self.groups.count) {
        Group *group = self.groups[indexPath.section];
        contact = group.contacts[indexPath.row];
    }
    else if (indexPath.section == self.findFriendSectionAllUsers) {
        contact = self.usersInContactsList[indexPath.row];
    }
    else if (indexPath.section == self.findFriendSectionRecents) {
        contact = self.recentsList[indexPath.row];
    }
    else if (indexPath.section == self.findFriendSectionSuggested) {
        contact = self.suggestedList[indexPath.row];
    }
    else if (indexPath.section == self.findFriendSectionContacts) {
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
        [self.tableView reloadData];
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
    CGFloat damping = selected ? 0.25 : 0.5;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
        addFriendImageView.transform = selected ? selectedTransform : CGAffineTransformIdentity;
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar endEditing:YES];
    [self reloadDataWithSearchText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exitSearchMode];
}

- (void)exitSearchMode
{
    self.inSearchMode = NO;
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
    if (!self.isVisible) {
        return;
    }
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.inSearchMode = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!self.isVisible) {
        return;
    }
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

@end
