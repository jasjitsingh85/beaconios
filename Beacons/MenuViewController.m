//
//  MenuViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "AppDelegate.h"
#import "Theme.h"
#import "CenterNavigationController.h"
#import "LoginViewController.h"
#import "MapViewController.h"
#import "FindFriendsViewController.h"
#import "BeaconDetailViewController.h"
#import "CreateBeaconViewController.h"
#import "SettingsViewController.h"
#import "User.h"
#import "RandomObjectManager.h"

typedef enum {
    MenuTableViewRowFind=0,
    MenuTableViewRowInvite,
    MenuTableViewRowSettings,
} MenuTableViewRows;

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:90/255.0 green:84/255.0 blue:85/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 65;
    self.tableView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height + 10, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    return 3;
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

#pragma mark - Cell Customization
#define ICON_IMAGE_TAG 1
#define TEXT_LABEL_TAG 3
- (UITableViewCell *)tableViewCellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    //set up image view
    CGRect frame = CGRectZero;
    frame.size.height = 29;
    frame.size.width = 29;
    frame.origin.y = 0.5*(self.tableView.rowHeight - frame.size.height) - 10;
    frame.origin.x = 0.5*([self visibleTableViewWidth] - frame.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = ICON_IMAGE_TAG;
    [cell.contentView addSubview:imageView];
    
    
    //set up name label
    UILabel *label = [[UILabel alloc] init];
    label.font = [ThemeManager lightFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = TEXT_LABEL_TAG;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    frame = CGRectZero;
    frame.size.width = [self visibleTableViewWidth];
    frame.size.height = [@"template" sizeWithAttributes:@{NSFontAttributeName : label.font}].height;
    frame.origin.x = 0;
    frame.origin.y = self.tableView.rowHeight - frame.size.height - 10;
    label.frame = frame;
    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell ForIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:ICON_IMAGE_TAG];
    UILabel *label = (UILabel *)[cell viewWithTag:TEXT_LABEL_TAG];
    if (indexPath.row == MenuTableViewRowInvite) {
        label.text = @"Invite";
        imageView.image = [UIImage imageNamed:@"menuInvite"];

    }
    else if (indexPath.row == MenuTableViewRowFind) {
        label.text = @"Home";
        imageView.image = [UIImage imageNamed:@"menuHome"];
    }
    else if (indexPath.row == MenuTableViewRowSettings) {
        label.text = @"Settings";
        imageView.image = [UIImage imageNamed:@"menuSettings"];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == MenuTableViewRowInvite) {
        [self inviteSelected];
    }
    else if (indexPath.row == MenuTableViewRowFind) {
        [self findSelected];
    }
    else if (indexPath.row == MenuTableViewRowSettings) {
        [self settingsSelected];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)inviteSelected
{
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    NSString *text = [[RandomObjectManager sharedManager] randomInviteFriendsToAppString];
    [activityItems addObject:text];

    [activityItems addObject:[NSURL URLWithString:@"http://gethotspotapp.com"]];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    activityViewController.excludedActivityTypes =  @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {

    };
    [[AppDelegate sharedAppDelegate].window.rootViewController presentViewController:activityViewController animated:YES completion:^{}];
}

- (void)settingsSelected
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:settingsViewController animated:YES];
}

- (void)findSelected
{
    [[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:[AppDelegate sharedAppDelegate].mapViewController animated:YES];
}

@end
