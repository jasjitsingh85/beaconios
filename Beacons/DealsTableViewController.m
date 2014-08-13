//
//  DealsTableViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealsTableViewController.h"
#import "UIView+BounceAnimation.h"
#import "UIView+Shadow.h"
#import "DealDetailViewController.h"
#import "SetDealViewController.h"
#import "CenterNavigationController.h"
#import "AppDelegate.h"
#import "DealTableViewCell.h"
#import "APIClient.h"
#import "LocationTracker.h"
#import "Deal.h"
#import "Venue.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"

@interface DealsTableViewController ()

@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) NSDate *lastUpdatedDeals;
@property (assign, nonatomic) BOOL loadingDeals;

@end

@implementation DealsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.loadingDeals && !self.lastUpdatedDeals) {
        [self reloadDeals];
    }
    [[AnalyticsManager sharedManager] viewedDealTable];
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
    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    [[LocationTracker sharedTracker] fetchCurrentLocation:^(CLLocation *location) {
        [self loadDealsNearCoordinate:location.coordinate withCompletion:^{
            self.loadingDeals = NO;
            [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
            [[AnalyticsManager sharedManager] viewedDeals:self.deals.count];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDealsUpdatedNotification object:nil];
        }];
    } failure:^(NSError *error) {
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    }];
}

- (void)loadDealsNearCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)())completion
{
    [[APIClient sharedClient] getDealsNearCoordinate:coordinate success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *deals = [[NSMutableArray alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        for (NSDictionary *dealJSON in responseObject[@"deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            [deals addObject:deal];
        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"venue.distance" ascending:YES];
        self.deals = [deals sortedArrayUsingDescriptors:@[sort]];
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
    return self.deals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 197;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    DealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    Deal *deal = self.deals[indexPath.row];
    cell.deal = deal;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Deal *deal = self.deals[indexPath.row];
    SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
    dealViewController.deal = deal;
    [self.navigationController pushViewController:dealViewController animated:YES];
}

- (void)happyHoursButtonTouched:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"hotspotHappyHours://"];
    BOOL hasHappyHours = [[UIApplication sharedApplication] canOpenURL:url];
    if (!hasHappyHours) {
        url = [NSURL URLWithString:@"http://itunes.apple.com/app/id879840229"];
    }
    [[UIApplication sharedApplication] openURL:url];
}

@end
