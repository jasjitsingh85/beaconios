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

@interface EditGroupViewController ()

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSMutableOrderedSet *contactsToAdd;
@property (strong, nonatomic) UIButton *doneButton;

@end

@implementation EditGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    [[ContactManager sharedManager] deleteGroup:self.group success:^{
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
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
        weakSelf.contacts = contacts;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
        weakSelf.contacts = [contacts sortedArrayUsingDescriptors:@[sortDescriptor]];
        [weakSelf.tableView reloadData];
    } failure:nil];
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
    titleLabel.x = 59;
    titleLabel.width -= titleLabel.x;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [ThemeManager regularFontOfSize:1.3*13];
    [headerView addSubview:titleLabel];
    titleLabel.text = !section ? self.group.name : @"Contacts";
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !section ?  self.group.contacts.count : self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (!indexPath.section) {
        Contact *contact = self.group.contacts[indexPath.row];
        cell.textLabel.text = contact.fullName;
        cell.imageView.image = [UIImage imageNamed:@"minusCircleUnselected"];
    }
    else {
        Contact *contact = self.contacts[indexPath.row];
        cell.textLabel.text = contact.fullName;
        BOOL selected = [self.contactsToAdd containsObject:contact];
        cell.imageView.image = selected ? [UIImage imageNamed:@"plusCircleSelected"] : [UIImage imageNamed:@"plusCircleUnselected"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        Contact *contact = self.group.contacts[indexPath.row];
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
    Contact *contact = self.contacts[indexPath.row];
    if ([self.contactsToAdd containsObject:contact]) {
        [self.contactsToAdd removeObject:contact];
    }
    else {
        [self.contactsToAdd addObject:contact];
    }
    [self updateDoneButtonText];
    if (self.contactsToAdd.count) {
        [self showDoneButton:YES];
    }
    else {
        [self hideDoneButton:YES];
    }
    [tableView reloadData];
}


@end
