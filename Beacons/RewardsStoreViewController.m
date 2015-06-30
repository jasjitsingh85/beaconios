//
//  RewardsStoreViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 5/12/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

//
//  DealsTableViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "RewardsStoreViewController.h"
#import "UIView+BounceAnimation.h"
//#import <FacebookSDK.h>
#import "UIView+Shadow.h"
//#import "SetDealViewController.h"
#import "CenterNavigationController.h"
#import "AppDelegate.h"
#import "RewardTableViewCell.h"
//#import "BounceButton.h"
#import "APIClient.h"
#import "LocationTracker.h"
#import "Deal.h"
#import "Venue.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"
//#import "RewardsViewController.h"
#import "UIButton+HSNavButton.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "RewardManager.h"

@interface RewardsStoreViewController ()

@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) UIView *enableLocationView;
@property (strong, nonatomic) NSDate *lastUpdatedDeals;
@property (strong, nonatomic) UIButton *enableLocationButton;
@property (strong, nonatomic) UILabel *enableLocationLabel;
@property (assign, nonatomic) BOOL loadingDeals;
@property (assign, nonatomic) BOOL locationEnabled;
//@property (assign, nonatomic) BOOL groupDeal;
@property (strong, nonatomic) NSArray *allDeals;
//@property (strong, nonatomic) RewardsViewController *rewardsViewController;

@end

@implementation RewardsStoreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    UIButton *cancelButton = [UIButton navButtonWithTitle:@"Cancel"];
    [cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    
//    self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
//    [self.rewardsViewController updateRewardsScore];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    //self.tableView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.loadingDeals && !self.lastUpdatedDeals) {
        [self reloadDeals];
    }
    
    //[self.rewardsViewController updateRewardsScore];
    
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
    [[APIClient sharedClient] getRewardsNearCoordinate:coordinate success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *deals = [[NSMutableArray alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        for (NSDictionary *dealJSON in responseObject[@"unlocked_deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            deal.locked = NO;
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            [deals addObject:deal];
        }
        for (NSDictionary *dealJSON in responseObject[@"locked_deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            deal.locked = YES;
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            [deals addObject:deal];
        }
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"venue.distance" ascending:YES];
        self.allDeals = deals;
        self.deals = self.allDeals;
        
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
    return self.deals.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

-(void)tappedOnCell:(UITapGestureRecognizer *)sender
{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    //NSIndexPath *indexPath = [[self getTableView]  indexPathForCell:self];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    Deal *deal;
    if (indexPath.row != 0) {
        deal = self.deals[indexPath.row - 1];
        
        
        if (!deal.locked) {
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Purchase Voucher?" message:@"Would you like to purchase this voucher?"];
            [alertView bk_addButtonWithTitle:@"Yes" handler:^{
                [[RewardManager sharedManager] purchaseRewardItem:deal.dealID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRewardsUpdated object:self];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Working");
                }];
            }];
            
            [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
            [alertView show];
            return;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Not Enough Points" message:@"You don't have enough points to purchase this item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
//
//
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Deal *deal;
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    RewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[RewardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
    [recognizer setNumberOfTapsRequired:1];
    [cell.contentView addGestureRecognizer:recognizer];
    
    if (indexPath.row == 0) {
        cell.deal = nil;
    } else {
        deal = self.deals[indexPath.row - 1];
        cell.deal = deal;
    }

    return cell;
    
}

- (void)appSettingsButtonTouched:(id)sender
{
    if (&UIApplicationOpenSettingsURLString != NULL) {
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettings];
    }
}

-(void)cancelButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
