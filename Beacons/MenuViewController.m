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
#import "Voucher.h"
#import "BeaconManager.h"
#import "RewardManager.h"
#import "BeaconProfileViewController.h"
#import "SettingsViewController.h"
#import "PromoViewController.h"
#import "GroupsViewController.h"
#import "Theme.h"
#import "VoucherTableViewCell.h"
#import "APIClient.h"
#import "PaymentsViewController.h"
#import <MaveSDK.h>
#import "AppInviteViewController.h"
#import "ContactManager.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *menuViewContainer;
@property (strong, nonatomic) UIView *dealsContainer;
@property (strong, nonatomic) UIView *groupContainer;
@property (strong, nonatomic) UIView *shareContainer;
@property (strong, nonatomic) UIView *homeContainer;
@property (strong, nonatomic) UIView *settingContainer;
@property (strong, nonatomic) UIView *paymentContainer;
@property (strong, nonatomic) UIView *promoContainer;
//@property (strong, nonatomic) UIView *buttonContainerView;
@property (strong, nonatomic) UIView *customHeaderView;
@property (strong, nonatomic) UILabel *dealsLabel;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *promoButton;
@property (strong, nonatomic) UIButton *groupsButton;
@property (strong, nonatomic) UIButton *paymentButton;
@property (strong, nonatomic) UIButton *inviteFriendsButton;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) NSDictionary *daySeparatedBeacons;
@property (strong, nonatomic) NSArray *vouchers;
@property (strong, nonatomic) NSArray *beacons;
@property (strong, nonatomic) PaymentsViewController *paymentsViewController;

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
    self.menuViewContainer.backgroundColor = [UIColor unnormalizedColorWithRed:51 green:40 blue:65 alpha:255];
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
    
    
    self.homeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.homeContainer];
    
    self.homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.homeButton setTitle:@"HOME" forState:UIControlStateNormal];
    [self.homeButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.homeButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.homeButton.titleLabel.textColor = [UIColor whiteColor];
    [self.homeButton setFrame:CGRectMake(0, 0, self.view.size.width, 50)];
    self.homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.homeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.homeButton addTarget:self action:@selector(dealsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *homeIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"homeIcon"]];
    homeIcon.frame = CGRectMake(20, 12, 27, 27);
    homeIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.homeButton addSubview:homeIcon];
    
    [self.homeContainer addSubview:self.homeButton];
    
    self.dealsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.tableView.frame.size.width, 50 + self.tableView.size.height)];
    [self.menuViewContainer addSubview:self.dealsContainer];
    self.dealsLabel = [[UILabel alloc] init];
    self.dealsLabel.text = @"HOTSPOTS";
    self.dealsLabel.font = [ThemeManager boldFontOfSize:18];
    self.dealsLabel.textColor = [UIColor whiteColor];
    self.dealsLabel.frame =  CGRectMake(60, 0, self.dealsContainer.size.width, 50);
    self.dealsLabel.textAlignment = NSTextAlignmentLeft;
//    self.dealsLabel. = UIEdgeInsetsMake(0, 60, 0, 0);
//    [self.dealsButton addTarget:self action:@selector(dealsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *dealsIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dealsIcon"]];
    dealsIcon.frame = CGRectMake(20, 12, 30, 30);
    dealsIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.dealsContainer addSubview:dealsIcon];
    
    [self.dealsContainer addSubview:self.tableView];
    [self.dealsContainer addSubview:self.dealsLabel];
    
//    UIView *groupContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100 + dealsContainer.size.height, self.menuViewContainer.frame.size.width, 50)];
//    UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, groupContainer.size.width, 50)];
//    groupLabel.font = [ThemeManager boldFontOfSize:18];
//    groupLabel.textAlignment = NSTextAlignmentLeft;
//    groupLabel.textColor = [UIColor whiteColor];
//    groupLabel.text = @"GROUPS";
//    [groupContainer addSubview:groupLabel];
//    [self.menuViewContainer addSubview:groupContainer];
    
//    self.groupContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100 + self.tableView.frame.size.height, self.menuViewContainer.frame.size.width, 50)];
//    [self.menuViewContainer addSubview:self.groupContainer];
//    self.groupsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.groupsButton setTitle:@"GROUPS" forState:UIControlStateNormal];
//    self.groupsButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
//    self.groupsButton.titleLabel.textColor = [UIColor whiteColor];
//    [self.groupsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//    [self.groupsButton setFrame:CGRectMake(0, 0, self.groupContainer.size.width, 50)];
//    self.groupsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    self.groupsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
//    [self.groupsButton addTarget:self action:@selector(groupButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIImageView *groupsIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupsIcon"]];
//    groupsIcon.frame = CGRectMake(21, 16, 20, 18);
//    groupsIcon.contentMode=UIViewContentModeScaleAspectFill;
//    [self.groupsButton addSubview:groupsIcon];
//    
//    [self.groupContainer addSubview:self.groupsButton];
    
    self.shareContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100 + self.tableView.frame.size.height, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.shareContainer];
    
    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inviteFriendsButton setTitle:@"FREE DRINKS" forState:UIControlStateNormal];
    [self.inviteFriendsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.inviteFriendsButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.inviteFriendsButton.titleLabel.textColor = [UIColor whiteColor];
    [self.inviteFriendsButton setFrame:CGRectMake(0, 0, self.shareContainer.size.width, 50)];
    self.inviteFriendsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.inviteFriendsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *shareIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"freeDrinks"]];
    shareIcon.frame = CGRectMake(16, 8, 30, 30);
    shareIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.inviteFriendsButton addSubview:shareIcon];
    [self.shareContainer addSubview:self.inviteFriendsButton];
    
    self.promoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 100 + self.tableView.frame.size.height, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.promoContainer];
    
    self.promoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.promoButton setTitle:@"PROMOTIONS" forState:UIControlStateNormal];
    [self.promoButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.promoButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.promoButton.titleLabel.textColor = [UIColor whiteColor];
    [self.promoButton setFrame:CGRectMake(0, 0, self.shareContainer.size.width, 50)];
    self.promoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.promoButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.promoButton addTarget:self action:@selector(promoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *promoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"promoCode"]];
    promoIcon.frame = CGRectMake(16, 12, 30, 30);
    promoIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.promoButton addSubview:promoIcon];
    [self.promoContainer addSubview:self.promoButton];

    self.paymentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.shareContainer.y + self.shareContainer.size.height, self.menuViewContainer.frame.size.width, 50)];
    [self.menuViewContainer addSubview:self.paymentContainer];
    self.paymentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.paymentButton setTitle:@"PAYMENT" forState:UIControlStateNormal];
    self.paymentButton.titleLabel.font = [ThemeManager boldFontOfSize:18];
    self.paymentButton.titleLabel.textColor = [UIColor whiteColor];
    [self.paymentButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.paymentButton setFrame:CGRectMake(0, 0, self.menuViewContainer.size.width, 50)];
    self.paymentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.paymentButton.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.paymentButton addTarget:self action:@selector(paymentButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *paymentIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"creditCardSideNav"]];
    paymentIcon.frame = CGRectMake(17, 10, 30, 30);
    paymentIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.paymentButton addSubview:paymentIcon];
    
    [self.paymentContainer addSubview:self.paymentButton];
    
    self.settingContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.paymentContainer.y + self.paymentContainer.size.height, self.menuViewContainer.frame.size.width, 50)];
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
    settingsIcon.frame = CGRectMake(17, 10, 30, 30);
    settingsIcon.contentMode=UIViewContentModeScaleAspectFill;
    [self.settingsButton addSubview:settingsIcon];
    
    [self.settingContainer addSubview:self.settingsButton];
    
    [[BeaconManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(beacons)) options:0 context:NULL];
    [[BeaconManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isUpdatingBeacons)) options:0 context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconUpdated:) name:kNotificationBeaconUpdated object:nil];
    
    [[RewardManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(vouchers)) options:0 context:NULL];
    [[RewardManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isUpdatingRewards)) options:0 context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rewardsUpdated:) name:kNotificationRewardsUpdated object:nil];
    
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getClientToken:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *clientToken = responseObject[@"client_token"];
        self.paymentsViewController = [[PaymentsViewController alloc] initWithClientToken:clientToken];
        self.paymentsViewController.onlyAddPayment = YES;
        //self.paymentsViewController.beaconProfileViewController = self;
        //self.paymentsViewController.beaconID = self.beacon.beaconID;
        [self addChildViewController:self.paymentsViewController];
        //[self.view addSubview:self.paymentsViewController.view];
        self.paymentsViewController.view.frame = self.view.bounds;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
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
    
    if (object == [RewardManager sharedManager]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(vouchers))]) {
            [self rewardChanged];
        }
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUpdatingRewards))]) {
            [self isUpdatingRewardsChanged];
        }
    }
    
    [self updateNavigationItems];
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

- (void)isUpdatingRewardsChanged
{
    if ([RewardManager sharedManager].isUpdatingRewards) {
        [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    }
    else {
        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    }
}

- (void)rewardChanged
{
    NSInteger voucherCount = 0;
    NSArray *vouchers = [RewardManager sharedManager].vouchers;
    if (vouchers) {
        voucherCount = vouchers.count;
        self.vouchers = vouchers;
//        self.tableView.frame = CGRectMake(0, 50, self.view.width, 50*beaconCount);
//        self.dealsContainer.frame = CGRectMake(0, 50, self.tableView.frame.size.width, 50 + self.tableView.frame.size.height);
//        self.groupContainer.frame = CGRectMake(0, 100 + self.tableView.frame.size.height, self.menuViewContainer.frame.size.width, 50);
//        self.shareContainer.frame = CGRectMake(0, self.groupContainer.origin.y + self.groupContainer.size.height, self.menuViewContainer.frame.size.width, 50);
//        self.settingContainer.frame = CGRectMake(0, self.shareContainer.origin.y + self.shareContainer.size.height, self.menuViewContainer.frame.size.width, 50);
//        
//        NSMutableDictionary *daySeparatedBeacons = [[NSMutableDictionary alloc] init];
//        for (Beacon *beacon in beacons) {
//            NSDate *day = beacon.time.day;
//            if (![daySeparatedBeacons.allKeys containsObject:day]) {
//                daySeparatedBeacons[day] = [[NSMutableArray alloc] init];
//            }
//            NSMutableArray *dates = daySeparatedBeacons[day];
//            [dates addObject:beacon];
//        }
//        self.daySeparatedBeacons = [NSDictionary dictionaryWithDictionary:daySeparatedBeacons];
//        jadispatch_main_qeue(^{
//            [self.tableView reloadData];
//            if (!beacons || !beacons.count) {
//                [self showEmptyBeaconView:YES];
//            }
//            else {
//                [self hideEmptyBeaconView:NO];
//            }
//        });
    }
}

- (void)beaconsChanged
{
    NSInteger beaconCount = 0;
    self.beacons = [BeaconManager sharedManager].beacons;
    if (self.beacons) {
        beaconCount = self.beacons.count;
//        NSMutableDictionary *daySeparatedBeacons = [[NSMutableDictionary alloc] init];
//        for (Beacon *beacon in self.beacons) {
//            NSDate *day = beacon.time.day;
//            if (![daySeparatedBeacons.allKeys containsObject:day]) {
//                daySeparatedBeacons[day] = [[NSMutableArray alloc] init];
//            }
//            NSMutableArray *dates = daySeparatedBeacons[day];
//            [dates addObject:beacon];
//        }
//        self.daySeparatedBeacons = [NSDictionary dictionaryWithDictionary:daySeparatedBeacons];
        jadispatch_main_qeue(^{
            [self.tableView reloadData];
            if (!self.beacons || !self.beacons.count) {
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
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[BeaconManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(beacons))];
    //[[RewardManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(vouchers))];
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

- (void)promoButtonTouched:(id)sender
{
    PromoViewController *promoViewController = [[PromoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:promoViewController animated:YES];
}

- (void)inviteFriendsButtonTouched:(id)sender
{
    

        AppInviteViewController *appInviteViewController = [[AppInviteViewController alloc] init];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:appInviteViewController];
        navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager lightFontOfSize:17]};
        navigationController.navigationBar.tintColor = [[ThemeManager sharedTheme] redColor];
        [self presentViewController:navigationController animated:YES completion:nil];
        //    [[AnalyticsManager sharedManager] invitedFriendsDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name];
//    } else {
//        [[MaveSDK sharedInstance] presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
//            // Code to present Mave's view controller from yours, e.g:
//            //[[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:inviteController animated:YES];
//            [self presentViewController:inviteController animated:YES completion:nil];
//        } dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
//            // Code to transition back to your view controller after Mave's
//            // is dismissed (sent invites or cancelled), e.g:
//            [controller dismissViewControllerAnimated:YES completion:nil];
//        } inviteContext:@"Menu"];
//    }
    
}

- (void)paymentButtonTouched:(id)sender
{
    [self.paymentsViewController openPaymentModalToAddPayment];
}

- (void)groupButtonTouched:(id)sender
{
    GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
    [[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:groupsViewController animated:YES];
}

- (void)beaconUpdated:(NSNotification *)notification
{
   [self.tableView reloadData];
}

- (void)rewardsUpdated:(NSNotification *)notification
{
    [[RewardManager sharedManager] updateActiveVouchers:^(NSArray *beacons) {
        [self.tableView reloadData];
    } failure:nil];
    
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
//    if ([self.daySeparatedBeacons count] > 0) {
//        NSDate *date = [self dateForSection:section];
//        NSInteger count = [self.daySeparatedBeacons[date] count];
//        return count;
//    } else {
//        return [self.vouchers count];
//    }
    self.tableView.frame = CGRectMake(0, 50, self.view.width, 50 * ([self.beacons count] + [self.vouchers count]));
    return [self.beacons count] + [self.vouchers count];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//}

//- (NSDate *)dateForSection:(NSInteger)section
//{
//        NSArray *sorted = [self.daySeparatedBeacons.allKeys sortedArrayUsingSelector:@selector(compare:)];
//        return sorted[section];
//}

//- (Beacon *)beaconForIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"WORKING");
//    NSDate *date = [self dateForSection:indexPath.section];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
//    NSArray *sortedBeacons =
//    [self.daySeparatedBeacons[date] sortedArrayUsingDescriptors:@[sortDescriptor]];
//    return sortedBeacons[indexPath.row];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Voucher Count: %lu", (unsigned long)[self.vouchers count]);
//    NSLog(@"Beacons Count: %lu", (unsigned long)[self.beacons count]);
//    NSLog(@"IndexPath Count: %lu", (unsigned long)indexPath.row);
    
    if ([self.beacons count] > indexPath.row) {
        static NSString *CellIdentifier = @"Cell";
        BeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[BeaconTableViewCell alloc] init];
        }
        //cell.beacon = [self beaconForIndexPath:indexPath];
        cell.beacon = self.beacons[indexPath.row];
        [self updateNavigationItems];
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        VoucherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[VoucherTableViewCell alloc] init];
        }
        cell.voucher = self.vouchers[indexPath.row - [self.beacons count]];
        [self updateNavigationItems];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Beacon *beacon = [self beaconForIndexPath:indexPath];
    if ([self.beacons count] > indexPath.row){
        Beacon *beacon = self.beacons[indexPath.row];
        [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
//    else {
//        Voucher *voucher = self.vouchers[indexPath.row - [self.beacons count]];
//        [[AppDelegate sharedAppDelegate] setSelectedViewControllerToVoucherViewWithVoucher:voucher];
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
}

- (void)updateNavigationItems
{
    int itemCount = (int)[self.beacons count] + (int)[self.vouchers count];
    self.tableView.frame = CGRectMake(0, 50, self.view.width, 50 * itemCount);
    if (itemCount == 0) {
        self.dealsContainer.height = 0;
        self.dealsContainer.hidden = YES;
        self.tableView.height = 0;
    } else {
        self.dealsContainer.hidden = NO;
        self.dealsContainer.frame = CGRectMake(0, 70, self.tableView.frame.size.width, 50 + self.tableView.frame.size.height);
    }

    if (itemCount == 0) {
        self.shareContainer.frame = CGRectMake(0, 70 + (50 * itemCount), self.menuViewContainer.frame.size.width, 50);
    } else {
        self.shareContainer.frame = CGRectMake(0, 120 + (50 * itemCount), self.menuViewContainer.frame.size.width, 50);
    }
    
    self.promoContainer.frame = CGRectMake(0, self.shareContainer.origin.y + self.shareContainer.size.height, self.menuViewContainer.frame.size.width, 50);
    self.paymentContainer.frame = CGRectMake(0, self.promoContainer.origin.y + self.promoContainer.size.height, self.menuViewContainer.frame.size.width, 50);
    self.settingContainer.frame = CGRectMake(0, self.paymentContainer.origin.y + self.paymentContainer.size.height, self.menuViewContainer.frame.size.width, 50);
    [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
}

@end
