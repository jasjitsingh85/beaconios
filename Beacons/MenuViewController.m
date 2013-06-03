//
//  MenuViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Theme.h"
#import "CenterNavigationController.h"
#import "LoginViewController.h"
#import "MapViewController.h"

typedef enum {
    MenuTableViewRowHome=0,
    MenuTableViewRowFind,
    MenuTableViewRowSettings,
    MenuTableViewRowLogout,
} MenuTableViewRows;

@interface MenuViewController ()

@end

@implementation MenuViewController

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

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuBackground"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 65;
}

- (CGFloat)visibleTableViewWidth
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CGFloat visibleWidth = self.view.frame.size.width - appDelegate.sideNavigationViewController.leftSize;
    return visibleWidth;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [self tableViewCellWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell ForIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == MenuTableViewRowHome) {
        
    }
    else if (indexPath.row == MenuTableViewRowFind) {
        [self findSelected];
    }
    else if (indexPath.row == MenuTableViewRowSettings) {

    }
    else if (indexPath.row == MenuTableViewRowLogout) {
        [self logoutSelected];
    }
}

- (void)logoutSelected
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.centerNavigationController setSelectedViewController:[LoginViewController new] animated:YES];
}

- (void)findSelected
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.centerNavigationController setSelectedViewController:appDelegate.mapViewController animated:YES];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [peoplePicker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell Customization
#define ICON_IMAGE_TAG 1
#define TEXT_LABEL_TAG 3
- (UITableViewCell *)tableViewCellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    //set up image view
    CGRect frame = CGRectZero;
    frame.size.height = 32;
    frame.size.width = 32;
    frame.origin.y = 0.5*(self.tableView.rowHeight - frame.size.height) - 10;
    frame.origin.x = 0.5*([self visibleTableViewWidth] - frame.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = ICON_IMAGE_TAG;
    [cell.contentView addSubview:imageView];
    
    
    //set up name label
    UILabel *label = [[UILabel alloc] init];
    label.font = [ThemeManager boldFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = TEXT_LABEL_TAG;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    frame = CGRectZero;
    frame.size.width = [self visibleTableViewWidth];
    frame.size.height = label.font.pointSize;
    frame.origin.x = 0;
    frame.origin.y = self.tableView.rowHeight - frame.size.height - 10;
    label.frame = frame;
    [cell.contentView addSubview:label];
    
    UIImageView *hairlineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hairlineSeparator"]];
    frame = hairlineImageView.frame;
    frame.origin.y = CGRectGetHeight(cell.contentView.frame) - frame.size.height;
    hairlineImageView.frame = frame;
    hairlineImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [cell.contentView addSubview:hairlineImageView];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell ForIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:ICON_IMAGE_TAG];
    UILabel *label = (UILabel *)[cell viewWithTag:TEXT_LABEL_TAG];
    if (indexPath.row == MenuTableViewRowHome) {
        label.text = @"You";
    }
    else if (indexPath.row == MenuTableViewRowFind) {
        label.text = @"Find";
        imageView.image = [UIImage imageNamed:@"menuBeacons"];
    }
    else if (indexPath.row == MenuTableViewRowSettings) {
        label.text = @"Settings";
        imageView.image = [UIImage imageNamed:@"menuSettings"];
    }
    else if (indexPath.row == MenuTableViewRowLogout) {
        label.text = @"Logout";
        imageView.image = [UIImage imageNamed:@"menuLogout"];
    }
}


@end
