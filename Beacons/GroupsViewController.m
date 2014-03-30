//
//  GroupsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "GroupsViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "Theme.h"

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
    

    [self.tableView reloadData];
}

- (void)createGroupButtonTouched:(id)sender
{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Create Group" message:@"What would you like to name this group?"];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView bk_addButtonWithTitle:@"Cancel" handler:nil];
    [alertView bk_setCancelButtonWithTitle:@"Create" handler:^{
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *groupName = textField.text;
    }];
    [alertView show];
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.contentView addSubview:self.createGroupButton];
        return cell;
    }
    static NSString *CellIdentifier = @"CellIdentifier";
    GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *title;
    if (indexPath.row == 1) {
        title = @"Test";
    }
    else if (indexPath.row == 2) {
        title = @"Another test";
    }
    cell.groupNameLabel.text = title;
    cell.memberCountLabel.text = [NSString stringWithFormat:@"%@ Contacts", @(100).stringValue];
    return cell;
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
