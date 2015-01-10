//
//  MenuViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 2/24/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "MenuViewController.h"
#import <MSDynamicsDrawerViewController.h>
#import "UIView+Shadow.h"
#import "NSDate+Day.h"
#import "NSDate+FormattedDate.h"
#import "Utilities.h"
#import "BeaconTableViewCell.h"
#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "LoadingIndictor.h"
#import "Beacon.h"
#import "BeaconManager.h"
#import "BeaconProfileViewController.h"
#import "SettingsViewController.h"
#import "GroupsViewController.h"
#import "Theme.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *menuViewContainer;
@property (strong, nonatomic) UIView *dealsContainer;
@property (strong, nonatomic) UIView *groupContainer;
@property (strong, nonatomic) UIView *shareContainer;
@property (strong, nonatomic) UIView *settingContainer;
//@property (strong, nonatomic) UIView *buttonContainerView;
@property (strong, nonatomic) UIView *customHeaderView;
@property (strong, nonatomic) UIButton *dealsButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *groupsButton;
@property (strong, nonatomic) UIButton *inviteFriendsButton;
@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) NSDictionary *daySeparatedBeacons;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//    self.buttonContainerView = [[UIView alloc] init];
//    CGRect containerFrame = CGRectZero;
//    containerFrame.size.width = [[AppDelegate sharedAppDelegate].sideNavigationViewController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
//    containerFrame.size.height = 108;
//    containerFrame.origin.y = self.view.frame.size.height - containerFrame.size.height;
//    self.buttonContainerView.frame = containerFrame;
//    self.buttonContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    self.buttonContainerView.backgroundColor = [UIColor colorWithWhite:61/255.0 alpha:1.0];
//    [self.view addSubview:self.buttonContainerView];
    
    CGRect tableViewFrame = CGRectZero;
    tableViewFrame.size.width = [[AppDelegate sharedAppDelegate].sideNavigationViewController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
    tableViewFrame.size.height = self.view.frame.size.height;
    self.menuViewContainer = [[UIView alloc] initWithFrame:tableViewFrame];
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.menuViewContainer.backgroundColor = [UIColor unnormalizedColorWithRed:30 green:30 blue:30 alpha:255];
//    [self.tableViewContainer setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    [self.view addSubview:self.menuViewContainer];
    
    NSArray *beacons = [BeaconManager sharedManager].beacons;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.width, 50*beacons.count) style:UITableViewStylePlain];
        //    self.tableView.tableHeaderView = self.customHeaderView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.separatorColor = [UIColor unnormalizedColorWithRed:30 green:30 blue:30 alpha:255];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor unnormalizedColorWithRed:30 green:30 blue:30 alpha:255];

//    UIView *dealsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.tableView.frame.size.width, 50 + self.tableView.size.height)];
//    UILabel *dealLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, dealsContainer.size.width, 50)];
//    dealLabel.font = [ThemeManager boldFontOfSize:18];
//    dealLabel.textAlignment = NSTextAlignmentLeft;
//    dealLabel.textColor = [UIColor whiteColor];
//    dealLabel.text = @"DEALS";
//    [dealsContainer addSubview:dealLabel];
//
//    [self.menuViewContainer addSubview:dealsContainer];
    
    self.dealsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, 50 + self.tableView.size.height)];
    [self.menuViewContainer addSubview:self.dealsContainer];
    self.dealsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dealsButton setTitle:@"DEALS" forState:UIControlStateNormal];
    self.dealsButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.dealsButton.titleLabel.textColor = [UIColor whiteColor];
    [self.dealsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.dealsButton setFrame:CGRectMake(0, 0, self.dealsContainer.size.width, 50)];
    self.dealsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.dealsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.dealsButton addTarget:self action:@selector(dealsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *dealsIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dealsIcon"]];
    dealsIcon.frame = CGRectMake(20, 16, 20, 18);
    dealsIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.dealsButton addSubview:dealsIcon];
    [self.dealsContainer addSubview:self.tableView];
    [self.dealsContainer addSubview:self.dealsButton];
    
//    UIView *groupContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100 + dealsContainer.size.height, self.menuViewContainer.frame.size.width, 50)];
//    UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, groupContainer.size.width, 50)];
//    groupLabel.font = [ThemeManager boldFontOfSize:18];
//    groupLabel.textAlignment = NSTextAlignmentLeft;
//    groupLabel.textColor = [UIColor whiteColor];
//    groupLabel.text = @"GROUPS";
//    [groupContainer addSubview:groupLabel];
//    [self.menuViewContainer addSubview:groupContainer];
    
    self.groupContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.dealsContainer.y + self.tableView.height, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.groupContainer];
    self.groupsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.groupsButton setTitle:@"GROUPS" forState:UIControlStateNormal];
    self.groupsButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.groupsButton.titleLabel.textColor = [UIColor whiteColor];
    [self.groupsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.groupsButton setFrame:CGRectMake(0, 0, self.groupContainer.size.width, 50)];
    self.groupsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.groupsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.groupsButton addTarget:self action:@selector(groupButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *groupsIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupsIcon"]];
    groupsIcon.frame = CGRectMake(21, 16, 20, 18);
    groupsIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.groupsButton addSubview:groupsIcon];
    
    [self.groupContainer addSubview:self.groupsButton];
    
    self.shareContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.groupContainer.y + self.groupContainer.size.height, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.shareContainer];
    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inviteFriendsButton setTitle:@"SHARE" forState:UIControlStateNormal];
    [self.inviteFriendsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.inviteFriendsButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.inviteFriendsButton.titleLabel.textColor = [UIColor whiteColor];
    [self.inviteFriendsButton setFrame:CGRectMake(0, 0, self.shareContainer.size.width, 50)];
    self.inviteFriendsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.inviteFriendsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *shareIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shareIcon"]];
    shareIcon.frame = CGRectMake(21, 16, 20, 18);
    shareIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.inviteFriendsButton addSubview:shareIcon];
    
    [self.shareContainer addSubview:self.inviteFriendsButton];
    
    self.settingContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.shareContainer.y + self.shareContainer.size.height, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.settingContainer];
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton setTitle:@"SETTINGS" forState:UIControlStateNormal];
    self.settingsButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.settingsButton.titleLabel.textColor = [UIColor whiteColor];
    [self.settingsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.settingsButton setFrame:CGRectMake(0, 0, self.menuViewContainer.size.width, 50)];
    self.settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.settingsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.settingsButton addTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *settingsIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settingsIcon"]];
    settingsIcon.frame = CGRectMake(22, 16, 20, 18);
    settingsIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.settingsButton addSubview:settingsIcon];
    
    [self.settingContainer addSubview:self.settingsButton];
    
//    CGFloat numButtons = 3;
//    CGSize buttonSize = CGSizeMake(50, 50);
//    UIImage *setBeaconSpotImage = [UIImage imageNamed:@"menuSetHotspot"];
//    self.setBeaconButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGRect setBeaconFrame = CGRectZero;
//    setBeaconFrame.size = buttonSize;
//    setBeaconFrame.origin.x = 0.5*(self.buttonContainerView.frame.size.width/numButtons - buttonSize.width);
//    setBeaconFrame.origin.y = 18;
//    self.setBeaconButton.frame = setBeaconFrame;
//    [self.setBeaconButton setImage:setBeaconSpotImage forState:UIControlStateNormal];
//    [self.setBeaconButton addTarget:self action:@selector(setBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [self.buttonContainerView addSubview:self.setBeaconButton];
//    
//    UILabel *setHotSpotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(setBeaconFrame), self.tableView.frame.size.width/3.0, 30)];
//    setHotSpotLabel.font = [ThemeManager lightFontOfSize:1.3*10];
//    setHotSpotLabel.text = @"Deals";
//    setHotSpotLabel.textAlignment = NSTextAlignmentCenter;
//    setHotSpotLabel.textColor = [UIColor whiteColor];
//    [self.buttonContainerView addSubview:setHotSpotLabel];
//    
//    UIImage *inviteFriendsImage = [UIImage imageNamed:@"menuInvite"];
//    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGRect inviteFrame = CGRectZero;
//    inviteFrame.size = buttonSize;
//    inviteFrame.origin.x = self.buttonContainerView.frame.size.width/numButtons + 0.5*(self.buttonContainerView.frame.size.width/numButtons - buttonSize.width);
//    inviteFrame.origin.y = 18;
//    self.inviteFriendsButton.frame = inviteFrame;
//    [self.inviteFriendsButton setImage:inviteFriendsImage forState:UIControlStateNormal];
//    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [self.buttonContainerView addSubview:self.inviteFriendsButton];
//    
//    UILabel *inviteFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(setHotSpotLabel.frame), setHotSpotLabel.frame.origin.y, self.tableView.frame.size.width/3.0, 30)];
//    inviteFriendsLabel.font = [ThemeManager lightFontOfSize:1.3*10];
//    inviteFriendsLabel.text = @"Share";
//    inviteFriendsLabel.textAlignment = NSTextAlignmentCenter;
//    inviteFriendsLabel.textColor = [UIColor whiteColor];
//    [self.buttonContainerView addSubview:inviteFriendsLabel];
//    
//    UIImage *settingsImage = [UIImage imageNamed:@"menuSettings"];
//    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGRect settingsFrame = CGRectZero;
//    settingsFrame.size = buttonSize;
//    settingsFrame.origin.x = 2*self.buttonContainerView.frame.size.width/numButtons + 0.5*(self.buttonContainerView.frame.size.width/numButtons - buttonSize.width);
//    settingsFrame.origin.y = 18;
//    self.settingsButton.frame = settingsFrame;
//    [self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
//    [self.settingsButton addTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [self.buttonContainerView addSubview:self.settingsButton];
//    
//    UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(inviteFriendsLabel.frame), setHotSpotLabel.frame.origin.y, self.tableView.frame.size.width/3.0, 30)];
//    settingsLabel.font = [ThemeManager lightFontOfSize:1.3*10];
//    settingsLabel.text = @"Settings";
//    settingsLabel.textAlignment = NSTextAlignmentCenter;
//    settingsLabel.textColor = [UIColor whiteColor];
//    [self.buttonContainerView addSubview:settingsLabel];
    
    [[BeaconManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(beacons)) options:0 context:NULL];
    [[BeaconManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isUpdatingBeacons)) options:0 context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconUpdated:) name:kNotificationBeaconUpdated object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == [BeaconManager sharedManager]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(beacons))]) {
            [self beaconsChanged];
        }
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUpdatingBeacons))]) {
            [self isUpdatingBeaconsChanged];
        }
    }
}

- (void)isUpdatingBeaconsChanged
{
    if ([BeaconManager sharedManager].isUpdatingBeacons) {
        [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    }
    else {
        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    }
}

- (void)beaconsChanged
{
    NSInteger beaconCount = 0;
    NSArray *beacons = [BeaconManager sharedManager].beacons;
    if (beacons) {
        beaconCount = beacons.count;
        self.tableView.frame = CGRectMake(0, 50, self.view.width, 50*beaconCount);
        self.dealsContainer.frame = CGRectMake(0, 50, self.tableView.frame.size.width, 50 + self.tableView.size.height);
        self.groupContainer.frame = CGRectMake(0, self.dealsContainer.origin.y + self.tableView.size.height + 50, self.menuViewContainer.frame.size.width, 50);
        self.shareContainer.frame = CGRectMake(0, self.groupContainer.origin.y + self.groupContainer.size.height, self.menuViewContainer.frame.size.width, 50);
        self.settingContainer.frame = CGRectMake(0, self.shareContainer.origin.y + self.shareContainer.size.height, self.menuViewContainer.frame.size.width, 50);
        
        NSMutableDictionary *daySeparatedBeacons = [[NSMutableDictionary alloc] init];
        for (Beacon *beacon in beacons) {
            NSDate *day = beacon.time.day;
            if (![daySeparatedBeacons.allKeys containsObject:day]) {
                daySeparatedBeacons[day] = [[NSMutableArray alloc] init];
            }
            NSMutableArray *dates = daySeparatedBeacons[day];
            [dates addObject:beacon];
        }
        self.daySeparatedBeacons = [NSDictionary dictionaryWithDictionary:daySeparatedBeacons];
        jadispatch_main_qeue(^{
            [self.tableView reloadData];
            if (!beacons || !beacons.count) {
                [self showEmptyBeaconView:YES];
            }
            else {
                [self hideEmptyBeaconView:NO];
            }
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[BeaconManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(beacons))];
}

//- (UIView *)emptyBeaconView
//{
//    if (!_emptyBeaconView) {
//        _emptyBeaconView = [[UIView alloc] init];
//        _emptyBeaconView.size = CGSizeMake(self.tableView.width, 100);
//        _emptyBeaconView.center = CGPointMake(self.tableView.width/2.0, self.tableView.height/2.0);
//        UILabel *titleLabel = [[UILabel alloc] init];
//        titleLabel.size = CGSizeMake(self.tableView.width, 20);
//        titleLabel.text = @"No active Hotspots";
//        titleLabel.font = [ThemeManager boldFontOfSize:15];
//        titleLabel.textColor = [UIColor whiteColor];
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        
//        UILabel *subtitleLabel = [[UILabel alloc] init];
//        subtitleLabel.size = CGSizeMake(self.tableView.width, 20);
//        subtitleLabel.y = titleLabel.bottom;
//        subtitleLabel.text = @"Set one and get your friends to come!";
//        subtitleLabel.font = [ThemeManager regularFontOfSize:15];
//        subtitleLabel.textColor = [UIColor lightGrayColor];
//        subtitleLabel.textAlignment = NSTextAlignmentCenter;
//        
//        [_emptyBeaconView addSubview:titleLabel];
//        [_emptyBeaconView addSubview:subtitleLabel];
//        _emptyBeaconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//    }
//    return _emptyBeaconView;
//}

- (UIView *)customHeaderView
{
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotbotSmileCircle"]];
//        CGRect imageViewFrame = imageView.frame;
//        imageViewFrame.origin.y = 0.5*(_customHeaderView.frame.size.height - imageViewFrame.size.height);
//        imageViewFrame.origin.x = 13;
//        imageView.frame = imageViewFrame;
//        [_customHeaderView addSubview:imageView];
        
        CGRect labelFrame = CGRectZero;
        labelFrame.size = CGSizeMake(100, 50);
        labelFrame.origin.x = 71;
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
//        label.text = @"Hotspots";
        label.textColor = [UIColor whiteColor];
        label.font = [ThemeManager boldFontOfSize:1.3*13];
        [_customHeaderView addSubview:label];
    }
        return _customHeaderView;
}

- (void)showEmptyBeaconView:(BOOL)animated
{
    if (self.emptyBeaconView.alpha && [self.tableView.subviews containsObject:self.emptyBeaconView]) {
        return;
    }
    self.emptyBeaconView.alpha = 0;
    [self.tableView addSubview:self.emptyBeaconView];
    NSTimeInterval duration = animated ? 0.5 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.emptyBeaconView.alpha = 1;
    }];
}

- (void)hideEmptyBeaconView:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.5 : 0;
    [UIView animateWithDuration:duration delay:0 options:0 animations:^{
        self.emptyBeaconView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.emptyBeaconView removeFromSuperview];
    }];
}

- (void)dealsButtonTouched:(id)sender
{
    [[AppDelegate sharedAppDelegate] setSelectedViewControllerToHome];
}

- (void)settingsButtonTouched:(id)sender
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:settingsViewController animated:YES];
}

- (void)inviteFriendsButtonTouched:(id)sender
{
    [Utilities presentFriendInviter];
}

- (void)groupButtonTouched:(id)sender
{
    GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
    [[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:groupsViewController animated:YES];
}

- (void)beaconUpdated:(NSNotification *)notification
{
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height)];
//    view.backgroundColor = [UIColor colorWithRed:91/255.0 green:81/255.0 blue:79/255.0 alpha:1.0];
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.width - 15, height)];
//    [view addEdge:UIRectEdgeTop | UIRectEdgeBottom width:1 color:[UIColor colorWithRed:63/255.0 green:59/255.0 blue:57/255.0 alpha:1.0]];
//    title.backgroundColor = [UIColor clearColor];
//    title.font = [ThemeManager regularFontOfSize:1.3*11.0];
//    title.textColor = [[self dateForSection:section] sameDay:[NSDate today]] ? [UIColor whiteColor] : [UIColor colorWithWhite:205/255.0 alpha:1.0];
//    [view addSubview:title];
//    NSDate *date = [self dateForSection:section];
//    title.text = date.formattedDay.uppercaseString;
//    return view;
//}

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *date = [self dateForSection:section];
    NSInteger count = [self.daySeparatedBeacons[date] count];
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.daySeparatedBeacons.allKeys.count;
}

- (NSDate *)dateForSection:(NSInteger)section
{
    NSArray *sorted = [self.daySeparatedBeacons.allKeys sortedArrayUsingSelector:@selector(compare:)];
    return sorted[section];
}

- (Beacon *)beaconForIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self dateForSection:indexPath.section];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    NSArray *sortedBeacons = [self.daySeparatedBeacons[date] sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedBeacons[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BeaconTableViewCell alloc] init];
    }
    
    cell.beacon = [self beaconForIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Beacon *beacon = [self beaconForIndexPath:indexPath];
    [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
