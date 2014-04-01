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
#import "Theme.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *tableViewContainer;
@property (strong, nonatomic) UIView *buttonContainerView;
@property (strong, nonatomic) UIView *customHeaderView;
@property (strong, nonatomic) UIButton *setBeaconButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *inviteFriendsButton;
@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) NSDictionary *daySeparatedBeacons;

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
    [self.tableViewContainer setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    [self.view addSubview:self.tableViewContainer];
    self.tableView = [[UITableView alloc] initWithFrame:self.tableViewContainer.bounds style:UITableViewStylePlain];
    self.tableView.tableHeaderView = self.customHeaderView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuBackground"]];
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
    
    UIImage *inviteFriendsImage = [UIImage imageNamed:@"menuInvite"];
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

- (UIView *)emptyBeaconView
{
    if (!_emptyBeaconView) {
        _emptyBeaconView = [[UIView alloc] init];
        _emptyBeaconView.size = CGSizeMake(self.tableView.width, 100);
        _emptyBeaconView.center = CGPointMake(self.tableView.width/2.0, self.tableView.height/2.0);
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.size = CGSizeMake(self.tableView.width, 20);
        titleLabel.text = @"No active Hotspots";
        titleLabel.font = [ThemeManager boldFontOfSize:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.size = CGSizeMake(self.tableView.width, 20);
        subtitleLabel.y = titleLabel.bottom;
        subtitleLabel.text = @"Set one and get your friends to come!";
        subtitleLabel.font = [ThemeManager regularFontOfSize:15];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_emptyBeaconView addSubview:titleLabel];
        [_emptyBeaconView addSubview:subtitleLabel];
        _emptyBeaconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _emptyBeaconView;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height)];
    view.backgroundColor = [UIColor colorWithRed:91/255.0 green:81/255.0 blue:79/255.0 alpha:1.0];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.width - 15, height)];
    [view addEdge:UIRectEdgeTop | UIRectEdgeBottom width:1 color:[UIColor colorWithRed:63/255.0 green:59/255.0 blue:57/255.0 alpha:1.0]];
    title.backgroundColor = [UIColor clearColor];
    title.font = [ThemeManager regularFontOfSize:1.3*11.0];
    title.textColor = [[self dateForSection:section] sameDay:[NSDate today]] ? [UIColor whiteColor] : [UIColor colorWithWhite:205/255.0 alpha:1.0];
    [view addSubview:title];
    NSDate *date = [self dateForSection:section];
    title.text = date.formattedDay.uppercaseString;
    return view;
}


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
    return 92;
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
