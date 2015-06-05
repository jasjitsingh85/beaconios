//
//  DealsTableViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealsTableViewController.h"
#import "UIView+BounceAnimation.h"
//#import <FacebookSDK.h>
#import "UIView+Shadow.h"
#import "SetDealViewController.h"
#import "CenterNavigationController.h"
#import "AppDelegate.h"
#import "DealTableViewCell.h"
#import "DealTableViewEventCell.h"
//#import "BounceButton.h"
#import "APIClient.h"
#import "LocationTracker.h"
#import "Deal.h"
#import "Venue.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"
#import "RewardsViewController.h"
#import "UIButton+HSNavButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MaveSDK.h>


@interface DealsTableViewController ()

@property (strong, nonatomic) DealTableViewEventCell *currentEventCell;
@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) UIView *enableLocationView;
@property (strong, nonatomic) UIView *dealTypeToggle;
@property (strong, nonatomic) NSDate *lastUpdatedDeals;
@property (strong, nonatomic) UIButton *enableLocationButton;
//@property (strong, nonatomic) UIButton *textOneFriend;
//@property (strong, nonatomic) UIButton *textManyFriends;
@property (strong, nonatomic) UILabel *enableLocationLabel;
@property (assign, nonatomic) BOOL hasEvents;
@property (assign, nonatomic) BOOL loadingDeals;
@property (assign, nonatomic) BOOL locationEnabled;
//@property (assign, nonatomic) BOOL groupDeal;
@property (strong, nonatomic) NSArray *allDeals;
@property (strong, nonatomic) RewardsViewController *rewardsViewController;

@end

@implementation DealsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    
    self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
    [self addChildViewController:self.rewardsViewController];
    [self.rewardsViewController updateRewardsScore];
    
//    CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 124, [[UIScreen mainScreen] bounds].size.width, 60);
//    self.dealTypeToggle = [[UIView alloc] initWithFrame:frame];
//    self.dealTypeToggle.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
//    [self.view addSubview:self.dealTypeToggle];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self checkToLaunchInvitationModal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];

}

- (void) checkToLaunchInvitationModal
{
    
    NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    
    if ((launchCount + 1) % 3 == 0) {
        [[MaveSDK sharedInstance] presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
            // Code to present Mave's view controller from yours, e.g:
            //[[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:inviteController animated:YES];
            [self presentViewController:inviteController animated:YES completion:nil];
        } dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
            // Code to transition back to your view controller after Mave's
            // is dismissed (sent invites or cancelled), e.g:
            [controller dismissViewControllerAnimated:YES completion:nil];
        } inviteContext:@"Popup"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.loadingDeals && !self.lastUpdatedDeals) {
        [self reloadDeals];
    }

    [self.rewardsViewController updateRewardsScore];
//    self.groupDeal = YES;
    
    [[AnalyticsManager sharedManager] viewedDealTable];
}

- (UIView *)enableLocationView
{
    if (!_enableLocationView) {
        _enableLocationView = [[UIView alloc] init];
        _enableLocationView.size = CGSizeMake(self.tableView.width, 200);
        _enableLocationView.backgroundColor = [UIColor whiteColor];
        [_enableLocationView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
        
        self.enableLocationLabel = [[UILabel alloc] init];
        self.enableLocationLabel.size = CGSizeMake(250, 200);
        self.enableLocationLabel.font = [ThemeManager regularFontOfSize:14.];
        self.enableLocationLabel.textColor = [UIColor colorWithWhite:102/255.0 alpha:1.0];
        self.enableLocationLabel.numberOfLines = 6;
        self.enableLocationView.hidden = YES;
        self.enableLocationLabel.textAlignment = NSTextAlignmentCenter;
        self.enableLocationLabel.text = @"Want to see great deals nearby? Hotspot needs to know your location.\n\nAllow Location Access in Privacy > Location Services";
        //        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
        //        footerView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
        self.enableLocationLabel.centerX = self.enableLocationView.width/2.0;
        self.enableLocationLabel.bottom = self.enableLocationView.height - 30;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.enableLocationView.height)];
        footerView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
        [footerView addSubview:self.enableLocationLabel];
        [self.enableLocationView addSubview:footerView];
        
        if (&UIApplicationOpenSettingsURLString != NULL) {
            self.enableLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.enableLocationButton.size = CGSizeMake(200, 35);
            self.enableLocationButton.centerX = self.enableLocationView.width/2.0;
            self.enableLocationButton.bottom = self.enableLocationView.height - 20;
            self.enableLocationButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
            [self.enableLocationButton setTitle:@"Go to Hotspot Settings" forState:UIControlStateNormal];
            self.enableLocationButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.enableLocationButton.frame.size.width - ( 50.), 0., 0.);
            self.enableLocationButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 0.);
            self.enableLocationButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
            [self.enableLocationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.enableLocationButton addTarget:self action:@selector(appSettingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.enableLocationView addSubview:self.enableLocationButton];
        }
    }
    return _enableLocationView;
}

- (UIView *)emptyBeaconView
{
    if (!_emptyBeaconView) {
        _emptyBeaconView = [[UIView alloc] init];
        _emptyBeaconView.size = CGSizeMake(self.tableView.width, 149);
        _emptyBeaconView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noDealsPlaceholder"]];
        [_emptyBeaconView addSubview:imageView];
        [_emptyBeaconView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(happyHoursButtonTouched:)];
        [_emptyBeaconView addGestureRecognizer:tap];
    }
    return _emptyBeaconView;
}

- (void)didUpdateLocation:(NSNotification *)notification
{
    if (self.loadingDeals) {
        return;
    }
    if (!self.lastUpdatedDeals) {
        [self reloadDeals];
    }
    else {
        NSTimeInterval durationSinceUpdate = [[NSDate date] timeIntervalSinceDate:self.lastUpdatedDeals];
        if (durationSinceUpdate > 60*3) {
            [self reloadDeals];
        }
    }
}

- (void)showEnableLocationView
{
    [self.tableView addSubview:self.enableLocationView];
    self.enableLocationView.hidden = NO;
}

- (void)hideEnableLocationView
{
    self.enableLocationView.hidden = YES;
}

- (void)showEmptyDealsView
{
    [self.tableView addSubview:self.emptyBeaconView];
    self.emptyBeaconView.hidden = NO;
}

- (void)hideEmptyDealsView
{
    self.emptyBeaconView.hidden = YES;
}

- (void)reloadDeals
{
    self.loadingDeals = YES;
    [self hideEnableLocationView];
    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    LocationTracker *locationTracker = [[LocationTracker alloc] init];
    if (locationTracker.authorized) {
        [locationTracker fetchCurrentLocation:^(CLLocation *location) {
            //REMOVE THIS LINE AFTER DEMO
            //CLLocation *staticLocation = [[CLLocation alloc] initWithLatitude:47.667759 longitude:-122.312766];
            //REMOVE THIS LINE AFTER DEMO
            [self loadDealsNearCoordinate:location.coordinate withCompletion:^{
            //[self loadDealsNearCoordinate:staticLocation.coordinate withCompletion:^{
                self.loadingDeals = NO;
                [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
                [[AnalyticsManager sharedManager] viewedDeals:self.deals.count];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDealsUpdatedNotification object:nil];
            }];
        } failure:^(NSError *error) {
            self.loadingDeals = NO;
            [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
        }];
    } else {
        [self showEnableLocationView];
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    }
}

- (void)loadDealsNearCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)())completion
{
    [[APIClient sharedClient] getDealsNearCoordinate:coordinate success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        NSMutableArray *deals = [[NSMutableArray alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        for (NSDictionary *eventJSON in responseObject[@"events"]) {
            Deal *event = [[Deal alloc] initWithDictionary:eventJSON];
            [events addObject:event];
        }
        for (NSDictionary *dealJSON in responseObject[@"deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            [deals addObject:deal];
        }
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"venue.distance" ascending:YES];
        self.events = events;
        if (self.events.count > 0) {
            self.hasEvents = YES;
        } else {
           self.hasEvents = NO;
        }
        self.allDeals = deals;
        self.deals = self.allDeals;
        
//        NSPredicate *predicate;
//        predicate = [NSPredicate predicateWithFormat:@"groupDeal = NO"];
//        NSLog(@"%lu", (unsigned long)[[self.allDeals filteredArrayUsingPredicate:predicate] count]);
//        if ([[self.allDeals filteredArrayUsingPredicate:predicate] count] > 0) {
//            self.dealTypeToggle.hidden = NO;
//        };
        
        [self reloadTableView];
        self.lastUpdatedDeals = [NSDate date];
        if (completion) {
            completion();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion();
        }
    }];
}

- (void)reloadTableView
{
    if (self.deals && self.deals.count) {
        [self hideEmptyDealsView];
//        NSPredicate *predicate;
//        if (self.groupDeal) {
//            predicate = [NSPredicate predicateWithFormat:@"groupDeal = YES"];
//            self.textManyFriends.backgroundColor = [UIColor colorWithRed:37./255 green:37./255 blue:37./255 alpha:1.0];
//            self.textOneFriend.backgroundColor = [UIColor clearColor];
//        }
//        else {
//            predicate = [NSPredicate predicateWithFormat:@"groupDeal = NO"];
//            self.textOneFriend.backgroundColor = [UIColor colorWithRed:37./255 green:37./255 blue:37./255 alpha:1.0];
//            self.textManyFriends.backgroundColor = [UIColor clearColor];
//        }
        //self.deals = [self.allDeals filteredArrayUsingPredicate:predicate];
        self.deals = self.allDeals;
    }
    else {
        [self showEmptyDealsView];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.deals.count ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.hasEvents) {
        return (self.deals.count + 1);
    } else {
        return self.deals.count;
    }
    
    //return self.deals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasEvents && indexPath.row==0) {
        return 253;
    } else {
        return 203;
    }
}

-(void)tappedOnCell:(UITapGestureRecognizer *)sender
{
    
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    //NSIndexPath *indexPath = [[self getTableView]  indexPathForCell:self];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Deal *deal;
    if (self.hasEvents){
        if (indexPath.row == 0) {
            deal = self.events[self.currentEventCell.pageControl.currentPage];
        } else {
            deal = self.deals[indexPath.row - 1];
        }
    } else {
        deal = self.deals[indexPath.row];
    }
    
    SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
    dealViewController.deal = deal;
    [self.navigationController pushViewController:dealViewController animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Deal *deal;
    if (self.hasEvents) {
        if (indexPath.row == 0) {
            //static NSString *CellIdentifier = @"CellIdentifier";
            NSString *CellIdentifier = [NSString stringWithFormat:@"%d", (int)indexPath.row];
            DealTableViewEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[DealTableViewEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.events = self.events;
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.currentEventCell = cell;
            }
            
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
            [recognizer setNumberOfTapsRequired:1];
            [cell.contentView addGestureRecognizer:recognizer];
        
            return cell;
        } else {
            deal = self.deals[indexPath.row - 1];
            NSString *CellIdentifier = [NSString stringWithFormat:@"%d", (int)indexPath.row - 1];
            DealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
            [recognizer setNumberOfTapsRequired:1];
            [cell.contentView addGestureRecognizer:recognizer];
            
            cell.deal = deal;
            return cell;
        }
    } else {
        deal = self.deals[indexPath.row];
        
        NSString *CellIdentifier = [NSString stringWithFormat:@"%d", (int)indexPath.row];
        DealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
        [recognizer setNumberOfTapsRequired:1];
        [cell.contentView addGestureRecognizer:recognizer];
        
        cell.deal = deal;
        return cell;
        
    }
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    Deal *deal;
//    if (self.hasEvents){
//        if (indexPath.row == 0) {
//            deal = self.events[0];
//        } else {
//            deal = self.deals[indexPath.row - 1];
//        }
//    } else {
//        deal = self.deals[indexPath.row];
//    }
//
//    SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
//    dealViewController.deal = deal;
//    [self.navigationController pushViewController:dealViewController animated:YES];
//}

- (void)happyHoursButtonTouched:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"hotspotHappyHours://"];
    BOOL hasHappyHours = [[UIApplication sharedApplication] canOpenURL:url];
    if (!hasHappyHours) {
        url = [NSURL URLWithString:@"http://itunes.apple.com/app/id879840229"];
    }
    [[UIApplication sharedApplication] openURL:url];
}

- (void)appSettingsButtonTouched:(id)sender
{
    if (&UIApplicationOpenSettingsURLString != NULL) {
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettings];
    }
}

//- (void)tabButtonTouched:(UIButton *)sender
//{
////    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//
//    if (sender == self.textOneFriend) {
//        self.groupDeal = NO;
//        [self showTextOneFriendAnimated:YES];
//    }
//    else if (sender == self.textManyFriends) {
//        self.groupDeal = YES;
//        [self showTextManyFriendsAnimated:YES];
//    }
//    
//    [self reloadTableView];
//}

//- (void)showTextOneFriendAnimated:(BOOL)animated
//{
//    self.textOneFriend.selected = YES;
//    self.textManyFriends.selected = NO;
//    //self.beaconChatViewController.view.alpha = 1;
////    NSTimeInterval duration = animated ? 0.3 : 0.0;
////    [UIView animateWithDuration:duration animations:^{
//////        self.inviteListViewController.view.transform = CGAffineTransformMakeTranslation(self.inviteListViewController.view.frame.size.width, 0);
//////        self.beaconChatViewController.view.transform = CGAffineTransformIdentity;
//////        self.inviteListViewController.view.alpha = 0.0;
//////    } completion:^(BOOL finished) {
//////        self.inviteListViewController.view.alpha = 0;
////    }];
//}

//- (void)showTextManyFriendsAnimated:(BOOL)animated
//{
//    self.textOneFriend.selected = NO;
//    self.textManyFriends.selected = YES;
//    //self.dealRedemptionViewController.view.alpha = 1;
////    NSTimeInterval duration = animated ? 0.3 : 0.0;
////    [UIView animateWithDuration:duration animations:^{
//////        self.beaconChatViewController.view.transform = CGAffineTransformMakeTranslation(self.beaconChatViewController.view.frame.size.width, 0);
//////        self.inviteListViewController.view.transform = self.beaconChatViewController.view.transform;
//////        self.dealRedemptionViewController.view.transform = CGAffineTransformIdentity;
//////        self.beaconChatViewController.view.alpha = 0.0;
//////        self.inviteListViewController.view.alpha = self.beaconChatViewController.view.alpha;
////    } completion:^(BOOL finished) {
//////        self.beaconChatViewController.view.alpha = 0;
////        
////        //self.textManyFriends.backgroundColor = [UIColor redColor];
////    }];
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect newFrame = self.dealTypeToggle.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.tableView.contentOffset.y+(self.tableView.frame.size.height - 60);
    self.dealTypeToggle.frame = newFrame;
}

@end