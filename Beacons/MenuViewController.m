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
#import "Utilities.h"
#import "BeaconTableViewCell.h"
#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "LoadingIndictor.h"
#import "Beacon.h"
#import "BeaconManager.h"
#import "BeaconProfileViewController.h"
#import "SettingsViewController.h"
#import "Theme.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *tableViewContainer;
@property (strong, nonatomic) UIView *buttonContainerView;
@property (strong, nonatomic) NSArray *beacons;
@property (strong, nonatomic) UIView *customHeaderView;
@property (strong, nonatomic) UIButton *setBeaconButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *inviteFriendsButton;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.buttonContainerView = [[UIView alloc] init];
    CGRect containerFrame = CGRectZero;
    containerFrame.size.width = [[AppDelegate sharedAppDelegate].sideNavigationViewController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
    containerFrame.size.height = 108;
    containerFrame.origin.y = self.view.frame.size.height - containerFrame.size.height;
    self.buttonContainerView.frame = containerFrame;
    self.buttonContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.buttonContainerView.backgroundColor = [UIColor colorWithWhite:61/255.0 alpha:1.0];
    [self.view addSubview:self.buttonContainerView];
    
    CGRect tableViewFrame = CGRectZero;
    tableViewFrame.size.width = [[AppDelegate sharedAppDelegate].sideNavigationViewController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
    tableViewFrame.size.height = self.view.frame.size.height - self.buttonContainerView.frame.size.height;
    self.tableViewContainer = [[UIView alloc] initWithFrame:tableViewFrame];
    self.tableViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableViewContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuBackground"]];
    [self.tableViewContainer setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    [self.view addSubview:self.tableViewContainer];
    self.tableView = [[UITableView alloc] initWithFrame:self.tableViewContainer.bounds style:UITableViewStylePlain];
    self.tableView.tableHeaderView = self.customHeaderView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableViewContainer addSubview:self.tableView];
    
    CGFloat numButtons = 3;
    CGSize buttonSize = CGSizeMake(50, 50);
    UIImage *setBeaconSpotImage = [UIImage imageNamed:@"menuSetHotspot"];
    self.setBeaconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect setBeaconFrame = CGRectZero;
    setBeaconFrame.size = buttonSize;
    setBeaconFrame.origin.x = 0.5*(self.buttonContainerView.frame.size.width/numButtons - buttonSize.width);
    setBeaconFrame.origin.y = 18;
    self.setBeaconButton.frame = setBeaconFrame;
    [self.setBeaconButton setImage:setBeaconSpotImage forState:UIControlStateNormal];
    [self.setBeaconButton addTarget:self action:@selector(setBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainerView addSubview:self.setBeaconButton];
    
    UILabel *setHotSpotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(setBeaconFrame), self.tableView.frame.size.width/3.0, 30)];
    setHotSpotLabel.font = [ThemeManager lightFontOfSize:1.3*10];
    setHotSpotLabel.text = @"Set Hotspot";
    setHotSpotLabel.textAlignment = NSTextAlignmentCenter;
    setHotSpotLabel.textColor = [UIColor whiteColor];
    [self.buttonContainerView addSubview:setHotSpotLabel];
    
    UIImage *inviteFriendsImage = [UIImage imageNamed:@"menuInvite@2x"];
    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect inviteFrame = CGRectZero;
    inviteFrame.size = buttonSize;
    inviteFrame.origin.x = self.buttonContainerView.frame.size.width/numButtons + 0.5*(self.buttonContainerView.frame.size.width/numButtons - buttonSize.width);
    inviteFrame.origin.y = 18;
    self.inviteFriendsButton.frame = inviteFrame;
    [self.inviteFriendsButton setImage:inviteFriendsImage forState:UIControlStateNormal];
    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainerView addSubview:self.inviteFriendsButton];
    
    UILabel *inviteFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(setHotSpotLabel.frame), setHotSpotLabel.frame.origin.y, self.tableView.frame.size.width/3.0, 30)];
    inviteFriendsLabel.font = [ThemeManager lightFontOfSize:1.3*10];
    inviteFriendsLabel.text = @"Add Friends";
    inviteFriendsLabel.textAlignment = NSTextAlignmentCenter;
    inviteFriendsLabel.textColor = [UIColor whiteColor];
    [self.buttonContainerView addSubview:inviteFriendsLabel];
    
    UIImage *settingsImage = [UIImage imageNamed:@"menuSettings"];
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect settingsFrame = CGRectZero;
    settingsFrame.size = buttonSize;
    settingsFrame.origin.x = 2*self.buttonContainerView.frame.size.width/numButtons + 0.5*(self.buttonContainerView.frame.size.width/numButtons - buttonSize.width);
    settingsFrame.origin.y = 18;
    self.settingsButton.frame = settingsFrame;
    [self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainerView addSubview:self.settingsButton];
    
    UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(inviteFriendsLabel.frame), setHotSpotLabel.frame.origin.y, self.tableView.frame.size.width/3.0, 30)];
    settingsLabel.font = [ThemeManager lightFontOfSize:1.3*10];
    settingsLabel.text = @"Settings";
    settingsLabel.textAlignment = NSTextAlignmentCenter;
    settingsLabel.textColor = [UIColor whiteColor];
    [self.buttonContainerView addSubview:settingsLabel];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconUpdated:) name:kNotificationBeaconUpdated object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self hasActiveBeacons]) {
        [self requestBeaconsShowLoadingIndicator:YES];
    }
    else {
        [self requestBeaconsShowLoadingIndicator:NO];
    }
}

- (UIView *)customHeaderView
{
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotbotSmileCircle"]];
        CGRect imageViewFrame = imageView.frame;
        imageViewFrame.origin.y = 0.5*(_customHeaderView.frame.size.height - imageViewFrame.size.height);
        imageViewFrame.origin.x = 13;
        imageView.frame = imageViewFrame;
        [_customHeaderView addSubview:imageView];
        
        CGRect labelFrame = CGRectZero;
        labelFrame.size = CGSizeMake(100, 50);
        labelFrame.origin.x = 71;
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = @"Hotspots";
        label.textColor = [UIColor whiteColor];
        label.font = [ThemeManager boldFontOfSize:1.3*13];
        [_customHeaderView addSubview:label];
        
        CGRect separatorFrame = CGRectZero;
        separatorFrame.size = CGSizeMake(_customHeaderView.frame.size.width, 1);
        separatorFrame.origin.y = _customHeaderView.frame.size.height - separatorFrame.size.height;
        UIView *separatorView = [[UIView alloc] initWithFrame:separatorFrame];
        separatorView.backgroundColor = [UIColor colorWithWhite:122/255.0 alpha:1.0];
        [_customHeaderView addSubview:separatorView];
    }
        return _customHeaderView;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    
}

- (void)setBeaconButtonTouched:(id)sender
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

- (void)beaconUpdated:(NSNotification *)notification
{
    
}

- (void)requestBeaconsShowLoadingIndicator:(BOOL)showLoadingIndicator
{
    if (showLoadingIndicator) {
        [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    }
    [[BeaconManager sharedManager] updateBeacons:^(NSArray *beacons) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        self.beacons = [NSArray arrayWithArray:beacons];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

- (BOOL)hasActiveBeacons
{
    BOOL hasActiveBeacons = NO;
    if (self.beacons) {
        NSPredicate *expirePredicate = [NSPredicate predicateWithFormat:@"expirationDate > %@", [NSDate date]];
        NSArray *unexpiredBeacons = [self.beacons filteredArrayUsingPredicate:expirePredicate];
        hasActiveBeacons = unexpiredBeacons.count;
    }
    return hasActiveBeacons;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beacons.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BeaconTableViewCell alloc] init];
    }
    cell.beacon = self.beacons[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Beacon *beacon = self.beacons[indexPath.row];
    BeaconProfileViewController *beaconProfileViewController = [[BeaconProfileViewController alloc] init];
    beaconProfileViewController.beacon = beacon;
    [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
