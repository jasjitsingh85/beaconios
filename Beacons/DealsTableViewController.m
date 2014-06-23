//
//  DealsTableViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealsTableViewController.h"
#import "UIView+BounceAnimation.h"
#import "DealDetailViewController.h"
#import "CenterNavigationController.h"
#import "AppDelegate.h"
#import "DealTableViewCell.h"
#import "APIClient.h"
#import "LocationTracker.h"
#import "Deal.h"
#import "Venue.h"
#import "LoadingIndictor.h"

@interface DealsTableViewController ()

@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) NSDate *lastUpdatedDeals;
@property (assign, nonatomic) BOOL loadingDeals;

@end

@implementation DealsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_background"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotbotSmileCircle"]];
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.origin.y = 0.5*(headerView.frame.size.height - imageViewFrame.size.height);
    imageViewFrame.origin.x = 13;
    imageView.frame = imageViewFrame;
    [headerView addSubview:imageView];
    self.tableView.tableHeaderView = headerView;
    
    CGRect labelFrame = CGRectZero;
    labelFrame.size = CGSizeMake(100, 50);
    labelFrame.origin.x = 71;
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = @"Deals";
    label.textColor = [UIColor whiteColor];
    label.font = [ThemeManager boldFontOfSize:1.3*13];
    [headerView addSubview:label];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIView *)emptyBeaconView
{
    if (!_emptyBeaconView) {
        _emptyBeaconView = [[UIView alloc] init];
        _emptyBeaconView.size = CGSizeMake(self.tableView.width, 100);
        _emptyBeaconView.center = CGPointMake(self.tableView.width/2.0, self.tableView.height/2.0);
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.size = CGSizeMake(self.tableView.width, 20);
        titleLabel.text = @"No Deals in Your Area";
        titleLabel.font = [ThemeManager boldFontOfSize:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.size = CGSizeMake(self.tableView.width, 20);
        subtitleLabel.y = titleLabel.bottom;
        subtitleLabel.text = @"Check out Hotspot's Happy Hour app!";
        subtitleLabel.numberOfLines = 0;
        subtitleLabel.font = [ThemeManager regularFontOfSize:14];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIButton *happyHoursButton = [[UIButton alloc] init];
        happyHoursButton.size = CGSizeMake(75, 75);
        happyHoursButton.centerX = self.tableView.width/2.0;
        happyHoursButton.y = subtitleLabel.bottom + 10;
        happyHoursButton.imageView.layer.cornerRadius = 15;
        happyHoursButton.imageView.clipsToBounds = YES;
        [happyHoursButton setImage:[UIImage imageNamed:@"happyHoursIcon"] forState:UIControlStateNormal];
        [happyHoursButton addTarget:self action:@selector(happyHoursButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [_emptyBeaconView addSubview:titleLabel];
        [_emptyBeaconView addSubview:subtitleLabel];
        [_emptyBeaconView addSubview:happyHoursButton];
        _emptyBeaconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
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
        for (NSDictionary *dealJSON in responseObject[@"deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            [deals addObject:deal];
        }
        self.deals = [NSArray arrayWithArray:deals];
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
    return 92;
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
    title.textColor = [UIColor whiteColor];
    [view addSubview:title];
    title.text = @"TODAY";
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    DealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    Deal *deal = self.deals[indexPath.row];
    cell.deal = deal;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Deal *deal = self.deals[indexPath.row];
    [[AppDelegate sharedAppDelegate] setSelectedViewControllerToDetailForDeal:deal];
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
