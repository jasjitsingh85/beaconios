//
//  EditGroupViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "EditGroupViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UIButton+HSNavButton.h"
#import "ContactManager.h"
#import "Theme.h"
#import "Contact.h"
#import "LoadingIndictor.h"

@interface GroupContactTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *contactNameLabel;
@property (strong, nonatomic) UIImageView *contactImageView;

@end

@interface EditGroupViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSArray *filteredGroupContacts;
@property (strong, nonatomic) NSArray *filteredContacts;
@property (strong, nonatomic) NSMutableOrderedSet *contactsToAdd;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (assign, nonatomic) BOOL inSearchMode;

@end

#define selectedTransform CGAffineTransformMakeScale(1.35, 1.35)

@implementation EditGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    //weird hack for black search bar issue
    self.searchBar.backgroundImage = [UIImage new];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [[ThemeManager sharedTheme] redColor];
    self.searchBar.translucent = NO;
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    [self.view addSubview:self.searchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.height -= self.searchBar.height;
    self.tableView.y = self.searchBar.bottom;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.contactsToAdd = [[NSMutableOrderedSet alloc] init];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    self.doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.doneButton.backgroundColor = [UIColor colorWithRed:120/255.0 green:183/255.0 blue:200/255.0 alpha:1.0];
    self.doneButton.titleLabel.font = [ThemeManager lightFontOfSize:16];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    self.doneButton.imageEdgeInsets = UIEdgeInsetsMake(0, 270, 0, 0);
    [self.doneButton addTarget:self action:@selector(doneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
    [self updateDoneButtonText];
    [self hideDoneButton:NO];
    
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
    if (self.group) {
        self.navigationItem.title = self.group.name;
    }
    UIButton *deleteButton = [UIButton navButtonWithTitle:@"Delete"];
    [deleteButton addTarget:self action:@selector(deleteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
}

- (void)setGroup:(Group *)group
{
    [self view];
    _group = group;
    self.navigationItem.title = group.name;
    [self reloadData];
}

- (void)deleteButtonTouched:(id)sender
{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Are you sure you want to delete this group?" message:@"This operation can't be undone"];
    [alertView bk_addButtonWithTitle:@"Delete" handler:^{
        [[ContactManager sharedManager] deleteGroup:self.group success:^{
            [self.navigationController popViewControllerAnimated:YES];
        } failure:nil];
    }];
    [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [alertView show];
}

- (void)doneButtonTouched:(id)sender
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[ContactManager sharedManager] addContacts:self.contactsToAdd.array toGroup:self.group success:^{
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Failed to update group" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)updateDoneButtonText
{
    NSString *title = @"";
    if (self.contactsToAdd.count) {
        Contact *lastContactAdded = [self.contactsToAdd lastObject];
        title = [NSString stringWithFormat:@"Add %@", lastContactAdded.firstName];
        if (self.contactsToAdd.count >= 2) {
            NSString *otherPlural = self.contactsToAdd.count > 2 ? @"others" : @"other";
            title = [title stringByAppendingString:[NSString stringWithFormat:@" and %@ %@", @(self.contactsToAdd.count - 1), otherPlural]];
        }
    }
    [self.doneButton setTitle:title forState:UIControlStateNormal];
}

- (void)showDoneButton:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.3 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.doneButton.transform = CGAffineTransformIdentity;
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.doneButton.height, 0);
}

- (void)hideDoneButton:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.3 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.doneButton.transform = CGAffineTransformMakeTranslation(0, self.doneButton.height);
    }];
    self.tableView.contentInset = UIEdgeInsetsZero;
}

- (void)reloadData
{
    __weak typeof(self) weakSelf = self;
    [[ContactManager sharedManager] fetchAddressBookContacts:^(NSArray *contacts) {
        [self.searchBar resignFirstResponder];
        self.searchBar.text = nil;
        weakSelf.contacts = contacts;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
        weakSelf.contacts = [contacts sortedArrayUsingDescriptors:@[sortDescriptor]];
        weakSelf.filteredContacts = weakSelf.contacts;
        weakSelf.filteredGroupContacts = weakSelf.group.contacts;
        [weakSelf.tableView reloadData];
    } failure:nil];
}

- (void)reloadDataWithSearchText:(NSString *)searchText
{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", searchText];
    self.filteredContacts = [self.contacts filteredArrayUsingPredicate:searchPredicate];
    self.filteredGroupContacts = [self.group.contacts filteredArrayUsingPredicate:searchPredicate];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [[ThemeManager sharedTheme] redColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    titleLabel.x = 32;
    titleLabel.width -= titleLabel.x;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [ThemeManager regularFontOfSize:1.3*13];
    [headerView addSubview:titleLabel];
    titleLabel.text = !section ? self.group.name : @"Contacts";
    
    UILabel *contactCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.width - 32, headerView.height)];
    contactCountLabel.textAlignment = NSTextAlignmentRight;
    contactCountLabel.font = [ThemeManager lightFontOfSize:1.3*8];
    contactCountLabel.textColor = [UIColor whiteColor];
    NSInteger contactCount = !section ? self.group.contacts.count : self.contacts.count;
    contactCountLabel.text = [NSString stringWithFormat:@"%d contacts", contactCount];
    [headerView addSubview:contactCountLabel];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !section ?  self.filteredGroupContacts.count : self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    GroupContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GroupContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (!indexPath.section) {
        Contact *contact = self.filteredGroupContacts[indexPath.row];
        cell.contactNameLabel.text = contact.fullName;
        cell.contactNameLabel.textColor = [UIColor blackColor];
        cell.contactImageView.image = [UIImage imageNamed:@"minusCircleUnselected"];
    }
    else {
        Contact *contact = self.filteredContacts[indexPath.row];
        BOOL alreadyInGroup = [self.group.contacts containsObject:contact];
        cell.contactNameLabel.text = contact.fullName;
        cell.contactNameLabel.textColor = alreadyInGroup ? [UIColor grayColor] : [UIColor blackColor];
        BOOL selected = [self.contactsToAdd containsObject:contact];
        UIImage *image;
        CGAffineTransform transform = CGAffineTransformIdentity;
        if (alreadyInGroup) {
            image = [UIImage imageNamed:@"plusCircleGray"];
        }
        else if (selected) {
            image = [UIImage imageNamed:@"plusCircleSelected"];
            transform = selectedTransform;
        }
        else {
            image = [UIImage imageNamed:@"plusCircleUnselected"];
        }
        cell.contactImageView.image = image;
        cell.contactImageView.transform = transform;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        Contact *contact = self.filteredGroupContacts[indexPath.row];
        NSString *title = [NSString stringWithFormat:@"Are you sure you want to remove %@ from this group?", contact.firstName];
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:nil message:title];
        [alertView bk_addButtonWithTitle:@"Yes" handler:^{
            [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
            [[ContactManager sharedManager] removeContacts:@[contact] fromGroup:self.group success:^{
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                [self reloadData];
            } failure:^(NSError *error) {
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
            }];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alertView show];
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Contact *contact = self.filteredContacts[indexPath.row];
    BOOL alreadyInGroup = [self.group.contacts containsObject:contact];
    BOOL currentlySelected = [self.contactsToAdd containsObject:contact];
    BOOL willBeSelected = NO;
    BOOL shouldAnimate = NO;
    if (alreadyInGroup) {
        NSString *message = [NSString stringWithFormat:@"%@ has already been added to this group", contact.fullName];
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else if (currentlySelected) {
        [self.contactsToAdd removeObject:contact];
        shouldAnimate = YES;
        willBeSelected = NO;
    }
    else {
        [self.contactsToAdd addObject:contact];
        shouldAnimate = YES;
        willBeSelected = YES;
        
    }
    if (shouldAnimate) {
        [self animateSelectingContactInCell:cell selected:willBeSelected completion:^{
            [self reloadData];
        }];
    }
    else {
        [self reloadData];
    }
    [self updateDoneButtonText];
    if (self.contactsToAdd.count) {
        [self showDoneButton:YES];
    }
    else {
        [self hideDoneButton:YES];
    }
}

- (void)animateSelectingContactInCell:(UITableViewCell *)cell selected:(BOOL)selected completion:(void(^) ())completion
{
    GroupContactTableViewCell *contactCell = (GroupContactTableViewCell *)cell;
    contactCell.contactImageView.image = selected ? [UIImage imageNamed:@"plusCircleSelected"] : [UIImage imageNamed:@"plusCircleUnselected"];
    CGFloat damping = selected ? 0.25 : 0.5;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
        contactCell.contactImageView.transform = selected ? selectedTransform : CGAffineTransformIdentity;
        [contactCell layoutIfNeeded];
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

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    self.inSearchMode = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    CGFloat bottomInset = CGAffineTransformEqualToTransform(self.doneButton.transform, CGAffineTransformIdentity) ? self.doneButton.height : 0;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}


@end

@implementation GroupContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.contactNameLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    self.contactNameLabel.x = 60;
    self.contactNameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.contactNameLabel];
    
    UIImage *image = [UIImage imageNamed:@"plusCircleSelected"];
    self.contactImageView = [[UIImageView alloc] initWithImage:image];
    self.contactImageView.x = 16;
    self.contactImageView.centerY = self.contentView.height/2.0;
    self.contactImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.contactImageView];
    return self;
}

@end