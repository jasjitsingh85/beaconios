//
//  GroupsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "GroupsViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "Group.h"
#import "EditGroupViewController.h"
#import "ContactManager.h"
#import "Theme.h"
#import "LoadingIndictor.h"

@interface GroupTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *groupNameLabel;
@property (strong, nonatomic) UILabel *memberCountLabel;

@end

@interface GroupsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIButton *createGroupButton;

@end

@implementation GroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.createGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.createGroupButton.frame = CGRectMake(0, 0, self.view.width, 46);
    [self.createGroupButton setTitle:@"+ Create a new group" forState:UIControlStateNormal];
    self.createGroupButton.titleLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    [self.createGroupButton setTitleColor:[UIColor colorWithWhite:68/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.createGroupButton.backgroundColor = [UIColor whiteColor];
    [self.createGroupButton addTarget:self action:@selector(createGroupButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Groups";
    
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:NO];
    [[ContactManager sharedManager] getGroups:^(NSArray *groups) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
        self.groups = groups;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)reloadData
{
    [[ContactManager sharedManager] getGroups:^(NSArray *groups) {
        self.groups = groups;
        [self.tableView reloadData];
    } failure:nil];
}

- (void)createGroupButtonTouched:(id)sender
{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Create Group" message:@"What would you like to name this group?"];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [alertView bk_addButtonWithTitle:@"Cancel" handler:nil];
    [alertView bk_setCancelButtonWithTitle:@"Create" handler:^{
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *groupName = textField.text;
        [self createGroupWithName:groupName];
    }];
    [alertView show];
}

- (void)createGroupWithName:(NSString *)groupName
{
    Group *group = [[Group alloc] init];
    group.name = groupName;
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[ContactManager sharedManager] postGroup:group success:^{
        jadispatch_main_qeue(^{
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
            EditGroupViewController *editGroupViewController = [[EditGroupViewController alloc] init];
            editGroupViewController.group = group;
            [self.navigationController pushViewController:editGroupViewController animated:YES];
        });
    } failure:^(NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:NO];
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell addEdge:UIRectEdgeBottom width:1 color:[UIColor colorWithWhite:220/255.0 alpha:1]];
        [cell.contentView addSubview:self.createGroupButton];
        return cell;
    }
    static NSString *CellIdentifier = @"CellIdentifier";
    GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell addEdge:UIRectEdgeBottom width:1 color:[UIColor colorWithWhite:220/255.0 alpha:1]];
    }
    Group *group = self.groups[indexPath.row - 1];
    cell.groupNameLabel.text = group.name;
    cell.memberCountLabel.text = [NSString stringWithFormat:@"%@ Contacts", @(group.contacts.count).stringValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row) {
        Group *group = self.groups[indexPath.row - 1];
        EditGroupViewController *editGroupViewController = [[EditGroupViewController alloc] init];
        editGroupViewController.group = group;
        [self.navigationController pushViewController:editGroupViewController animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

@implementation GroupTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    CGRect groupNameFrame = self.contentView.bounds;
    groupNameFrame.origin.x = 30;
    self.groupNameLabel = [[UILabel alloc] initWithFrame:groupNameFrame];
    self.groupNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.groupNameLabel.font = [ThemeManager boldFontOfSize:1.3*12];
    self.groupNameLabel.textColor = [UIColor colorWithWhite:68/255.0 alpha:1.0];
    [self.contentView addSubview:self.groupNameLabel];
    
    CGRect memberCountFrame = self.contentView.bounds;
    memberCountFrame.size.width -= 30;
    self.memberCountLabel = [[UILabel alloc] initWithFrame:memberCountFrame];
    self.memberCountLabel.textAlignment = NSTextAlignmentRight;
    self.memberCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.memberCountLabel.font = [ThemeManager lightFontOfSize:1.3*8];
    self.memberCountLabel.textColor = [UIColor colorWithWhite:68/255.0 alpha:1.0];
    [self.contentView addSubview:self.memberCountLabel];
    return self;
}

@end
