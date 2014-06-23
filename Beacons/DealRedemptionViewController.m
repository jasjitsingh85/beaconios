//
//  DealRedemptionViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealRedemptionViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "DashedBorderButton.h"
#import "Deal.h"
#import "DealStatus.h"
#import "APIClient.h"

@interface DealRedemptionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) DashedBorderButton *redeemButton;
@property (strong, nonatomic) UILabel *redeemLabel;
@property (strong, nonatomic) UILabel *countdownLabel;
@property (strong, nonatomic) UILabel *timeLeftLabel;

@end

@implementation DealRedemptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.countdownLabel = [[UILabel alloc] init];
    self.countdownLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    self.countdownLabel.textColor = [[ThemeManager sharedTheme] redColor];
    
    self.timeLeftLabel = [[UILabel alloc] init];
    self.timeLeftLabel.font = [ThemeManager lightFontOfSize:1.3*19];
    self.timeLeftLabel.textColor = [[ThemeManager sharedTheme] redColor];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    
    self.redeemButton = [DashedBorderButton buttonWithType:UIButtonTypeCustom];
    self.redeemButton.layer.cornerRadius = 4;
    self.redeemButton.size = CGSizeMake(280, 42);
    [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.redeemLabel = [[UILabel alloc] init];
    self.redeemLabel.size = CGSizeMake(186, 44);
    self.redeemLabel.font = [ThemeManager regularFontOfSize:1.3*9];
    self.redeemLabel.textColor = [UIColor colorWithWhite:205/255.0 alpha:1.0];
    self.redeemLabel.numberOfLines = 2;
    self.redeemLabel.textAlignment = NSTextAlignmentCenter;
    self.redeemLabel.text = @"When you arrive, show them this deal. Then, tap to redeem!";
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
    footerView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    [footerView addSubview:self.redeemLabel];
    self.redeemLabel.centerX = footerView.width/2.0;
    self.redeemButton.centerX = footerView.width/2.0;
    self.redeemButton.bottom = footerView.height - 18;
    [footerView addSubview:self.redeemButton];
    self.tableView.tableFooterView = footerView;
}

- (BOOL)dealPassed
{
    return [self.dealStatus.endDate timeIntervalSinceDate:[NSDate date]] < 0;
}

- (BOOL)dealUpcoming
{
    return [self.dealStatus.startDate timeIntervalSinceDate:[NSDate date]] > 0;
}

- (BOOL)dealNow
{
    return ![self dealPassed] && ![self dealUpcoming];
}

- (void)updateCountdown
{
    if (!self.dealStatus) {
        return;
    }
    NSDate *now = [NSDate date];
    NSTimeInterval interval;
    if ([self dealPassed]) {
        self.countdownLabel.textColor = [UIColor colorWithWhite:205/255.0 alpha:1.0];
        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
        self.countdownLabel.text = @"Deal has passed";
        return;
    }
    else if ([self dealNow]) {
        self.countdownLabel.textColor = [UIColor colorWithRed:92/255.0 green:191/255.0 blue:69/255.0 alpha:1.0];;
        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
        self.countdownLabel.text = @"Ends in:";
        interval = [self.dealStatus.endDate timeIntervalSinceDate:now];
    }
    else {
        self.countdownLabel.textColor = [[ThemeManager sharedTheme] redColor];
        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
        self.countdownLabel.text = @"Begins in";
        interval = [self.dealStatus.startDate timeIntervalSinceDate:now];
    }
    NSInteger hours = floor(interval/(60.0*60.0));
    NSInteger minutes = floor((interval - hours*60*60)/60.0);
    NSInteger seconds = interval - 60*60*hours - 60*minutes;
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
}

- (void)setDeal:(Deal *)deal andDealStatus:(DealStatus *)dealStatus
{
    [self view];
    
    self.deal = deal;
    self.dealStatus = dealStatus;
    [self updateRedeemButtonAppearance];
    [self.tableView reloadData];
}

- (void)redeemButtonTouched:(id)sender
{
    if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"This deal has already been redeemed and can't be redeemed again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if ([self dealNow]) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Redeem this deal?" message:@"You can only redeem a deal once"];
        [alertView bk_addButtonWithTitle:@"Yes" handler:^{
            [self redeemDeal];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alertView show];
        return;
    }
    NSString *message;
    NSString *title = @"Sorry";
    if ([self dealUpcoming]) {
        message = @"This deal isn't going on right now.";
    }
    else {
        message = @"This deal has passed.";
    }
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
    [alertView bk_setCancelButtonWithTitle:@"OK" handler:nil];
    [alertView show];
}

- (void)redeemDeal
{
    [[APIClient sharedClient] redeemDeal:self.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *message = responseObject[@"message"];
        NSString *dealStatus = responseObject[@"deal_status"];
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        self.dealStatus.dealStatus = dealStatus;
        [self updateRedeemButtonAppearance];
    } failure:nil];
}

- (void)updateRedeemButtonAppearance
{
    UIColor *inactiveColor = [UIColor colorWithWhite:205/255.0 alpha:1.0];
    UIColor *activeColor = [[ThemeManager sharedTheme] redColor];
    UIColor *color;
    NSString *title;
    if ([self dealNow] && ![self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
        color = activeColor;
        title = @"Redeem this Deal";
    }
    else {
        color = inactiveColor;
        if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
            title = @"Deal Redeemed";
        }
        else if ([self dealPassed]){
            title = @"Deal Passed";
        }
        else {
            title = @"Redeem this Deal";
        }
    }
    self.redeemButton.border.strokeColor = color.CGColor;
    [self.redeemButton setTitleColor:color forState:UIControlStateNormal];
    [self.redeemButton setTitle:title forState:UIControlStateNormal];
}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (!indexPath.row) {
        height = 74;
    }
    else if (indexPath.row == 1) {
        height = 90;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (!indexPath.row) {
        cell = [self countdownCell];
    }
    else if (indexPath.row == 1) {
        cell = [self dealDescriptionCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)countdownCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    [cell.contentView addSubview:self.countdownLabel];
    self.countdownLabel.size = CGSizeMake(cell.contentView.width, 23);
    self.countdownLabel.y = 18;
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    
    [cell.contentView addSubview:self.timeLeftLabel];
    self.timeLeftLabel.size = CGSizeMake(cell.contentView.width, 31);
    self.timeLeftLabel.y = 37;
    self.timeLeftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UITableViewCell *)dealDescriptionCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.indentationLevel = 1;
    cell.indentationWidth = 19;
    cell.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    cell.textLabel.text = @"Here's the deal:";
    cell.textLabel.font = [ThemeManager lightFontOfSize:1.3*13];
    cell.textLabel.textColor = [[ThemeManager sharedTheme] redColor];
    cell.detailTextLabel.text = self.deal.dealDescription;
    cell.detailTextLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:102/255.0 alpha:1.0];
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
    
}



@end