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
#import "Venue.h"
#import "Beacon.h"
#import "DealStatus.h"
#import "LoadingIndictor.h"
#import "APIClient.h"
#import "BeaconManager.h"
#import "FindFriendsViewController.h"
#import "BeaconStatus.h"

@interface DealRedemptionViewController () <UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) UIButton *redeemButton;
@property (strong, nonatomic) UIButton *inviteFriendsButton;
@property (strong, nonatomic) UILabel *countdownLabel;
@property (strong, nonatomic) UILabel *voucherTitle;
@property (strong, nonatomic) UILabel *itemName;
@property (strong, nonatomic) UILabel *venueName;
@property (strong, nonatomic) UILabel *serverMessage;
@property (strong, nonatomic) UIImageView *voucherIcon;
@property (strong, nonatomic) UIImageView *headerIcon;
@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *headerExplanationText;
//@property (strong, nonatomic) UILabel *timeLeftLabel;

@end

@implementation DealRedemptionViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.headerIcon = [[UIImageView alloc] init];
    self.headerIcon.height = 30;
    self.headerIcon.width = 30;
    self.headerIcon.centerX = self.view.width/2;
    self.headerIcon.y = 0;
    [self.tableView addSubview:self.headerIcon];
    
    self.headerTitle = [[UILabel alloc] init];
    self.headerTitle.height = 20;
    self.headerTitle.width = self.tableView.width;
    self.headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    self.headerTitle.font = [ThemeManager boldFontOfSize:11];
    self.headerTitle.y = 30;
    [self.tableView addSubview:self.headerTitle];
    
    self.headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.width - 50, 50)];
    self.headerExplanationText.centerX = self.view.width/2;
    self.headerExplanationText.font = [ThemeManager lightFontOfSize:12];
    self.headerExplanationText.textAlignment = NSTextAlignmentCenter;
    self.headerExplanationText.numberOfLines = 2;
    [self.tableView addSubview:self.headerExplanationText];
    
//    UIImageView *inviteFriendsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupIcon"]];
//    //    self.headerIcon.height = 30;
//    //    self.headerIcon.width = 30;
//    inviteFriendsIcon.centerX = self.view.width/2;
//    inviteFriendsIcon.y = 230;
//    [self.tableView addSubview:inviteFriendsIcon];
//    
//    UILabel *inviteFriendsTitle = [[UILabel alloc] init];
//    inviteFriendsTitle.height = 30;
//    inviteFriendsTitle.width = self.tableView.width;
//    inviteFriendsTitle.textAlignment = NSTextAlignmentCenter;
//    //self.headerTitle.centerX = self.tableView.width/2;
//    inviteFriendsTitle.font = [ThemeManager boldFontOfSize:11];
//    inviteFriendsTitle.y = 250;
//    inviteFriendsTitle.text = @"TEXT FRIENDS TO MEET HERE?";
//    [self.tableView addSubview:inviteFriendsTitle];
    
    UILabel *inviteFriendsExplanation = [[UILabel alloc] initWithFrame:CGRectMake(0, 260, self.view.width - 50, 50)];
    inviteFriendsExplanation.centerX = self.view.width/2;
    inviteFriendsExplanation.font = [ThemeManager lightFontOfSize:12];
    inviteFriendsExplanation.textAlignment = NSTextAlignmentCenter;
    inviteFriendsExplanation.text = @"Tap below to text more friends to meet you here.";
    inviteFriendsExplanation.numberOfLines = 1;
    [self.tableView addSubview:inviteFriendsExplanation];
    
    self.redeemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redeemButton.y = 100; // +25
    //self.redeemButton.layer.cornerRadius = 6;
    //self.redeemButton.border.lineWidth = 4;
    //self.redeemButton.border.strokeColor = [UIColor colorWithRed:138/255. green:136/255. blue:136/255. alpha:1].CGColor;
    //self.redeemButton.border.fillColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1].CGColor;
    //self.redeemButton.border.lineDashPattern = @[@10, @10];
    self.redeemButton.size = CGSizeMake(self.view.width, 150);
    [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.voucherTitle = [[UILabel alloc] init];
    self.voucherTitle.size = CGSizeMake(self.redeemButton.width, 34);
    self.voucherTitle.y = 15;
    self.voucherTitle.font = [ThemeManager boldFontOfSize:11];
    self.voucherTitle.textAlignment = NSTextAlignmentCenter;
    self.voucherTitle.text = @"VOUCHER FOR:";
    [self.redeemButton addSubview:self.voucherTitle];
    
    self.itemName = [[UILabel alloc] init];
    self.itemName.size = CGSizeMake(self.redeemButton.width, 20);
    self.itemName.font = [ThemeManager boldFontOfSize:16];
    self.itemName.y = 36;
    self.itemName.textAlignment = NSTextAlignmentCenter;
    self.itemName.text = [self.deal.itemName uppercaseString];
    [self.redeemButton addSubview:self.itemName];
    
    self.venueName = [[UILabel alloc] init];
    self.venueName.size = CGSizeMake(self.redeemButton.width, 20);
    self.venueName.font = [ThemeManager boldFontOfSize:16];
    self.venueName.textAlignment = NSTextAlignmentCenter;
    self.venueName.y = 52;
    self.venueName.text = [NSString stringWithFormat:@"@ %@", [self.deal.venue.name uppercaseString]];
    [self.redeemButton addSubview:self.venueName];
    
    self.voucherIcon = [[UIImageView alloc] init];
    self.voucherIcon.height = 30;
    self.voucherIcon.width = 30;
    self.voucherIcon.centerX = self.view.width/2;
    self.voucherIcon.y = 75;
    [self.redeemButton addSubview:self.voucherIcon];
    
    self.serverMessage = [[UILabel alloc] init];
    self.serverMessage.size = CGSizeMake(self.redeemButton.width, 20);
    self.serverMessage.textAlignment = NSTextAlignmentCenter;
    self.serverMessage.y = 108;
    self.serverMessage.text = @"SERVER ONLY: TAP TO REDEEM";
    self.serverMessage.font = [ThemeManager boldFontOfSize:11];
    [self.redeemButton addSubview:self.serverMessage];
    
    self.inviteFriendsButton = [[UIButton alloc] init];
    self.inviteFriendsButton.size = CGSizeMake(self.view.width, 40);
    self.inviteFriendsButton.titleLabel.font = [ThemeManager boldFontOfSize:15];
    self.inviteFriendsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    self.inviteFriendsButton.titleLabel.textColor = [UIColor whiteColor];
    self.inviteFriendsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    footerView.backgroundColor = [UIColor whiteColor];
    [self.inviteFriendsButton setTitle:@"TEXT MORE FRIENDS" forState:UIControlStateNormal];
    self.inviteFriendsButton.y = 300;
    [self.tableView addSubview:self.inviteFriendsButton];
    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //self.redeemButton.centerX = footerView.width/2.0;
    [self.tableView addSubview:self.redeemButton];
    //[self.tableView addSubview:footerView];
    //self.tableView.tableFooterView = footerView;
}
//
//- (void) loadPaymentDeal
//{
////    self.countdownLabel = [[UILabel alloc] init];
////    self.countdownLabel.font = [ThemeManager boldFontOfSize:16];
////    self.countdownLabel.textColor = [UIColor unnormalizedColorWithRed:53 green:194 blue:211 alpha:255];
////    
////    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
//    
//    
//
//    
//}

//- (void)loadCouponDeal
//{
//    
//        self.countdownLabel = [[UILabel alloc] init];
//        self.countdownLabel.font = [ThemeManager boldFontOfSize:16];
//        self.countdownLabel.textColor = [UIColor unnormalizedColorWithRed:53 green:194 blue:211 alpha:255];
//    
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
//    
//        self.redeemButton = [DashedBorderButton buttonWithType:UIButtonTypeCustom];
//        self.redeemButton.layer.cornerRadius = 6;
//        self.redeemButton.size = CGSizeMake(280, 42);
//        [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    
////        self.feedbackButton = [[UIButton alloc] init];
////        self.feedbackButton.size = CGSizeMake(self.view.width, 34);
////        self.feedbackButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
////        self.feedbackButton.backgroundColor = [UIColor unnormalizedColorWithRed:48 green:48 blue:48 alpha:255];
////        self.feedbackButton.titleLabel.textColor = [UIColor whiteColor];
////        self.feedbackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
//        footerView.backgroundColor = [UIColor whiteColor];
////        self.feedbackButton.bottom = footerView.height + 10;
////        [footerView addSubview:self.feedbackButton];
////        self.feedbackButton.centerX = footerView.width/2.0;
//        self.redeemButton.centerX = footerView.width/2.0;
//        self.redeemButton.bottom = footerView.height - 40;
//        //[self.feedbackButton addTarget:self action:@selector(feedbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [footerView addSubview:self.redeemButton];
//        self.tableView.tableFooterView = footerView;
//    
//}

//- (BOOL)dealPassed
//{
//    return [self.dealStatus.endDate timeIntervalSinceDate:[NSDate date]] < 0;
//}
//
//- (BOOL)dealUpcoming
//{
//    return [self.dealStatus.startDate timeIntervalSinceDate:[NSDate date]] > 0;
//}
//
//- (BOOL)dealNow
//{
//    return ![self dealPassed] && ![self dealUpcoming];
//}

//- (void)updateCountdown
//{
//    if (!self.dealStatus) {
//        return;
//    }
//    NSDate *now = [NSDate date];
//    NSTimeInterval interval;
//    if ([self dealPassed]) {
//        self.countdownLabel.textColor = [UIColor colorWithWhite:205/255.0 alpha:1.0];
////        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
//        self.countdownLabel.text = @"DEAL HAS PASSED";
//        return;
//    }
//    else if ([self dealNow]) {
//        self.countdownLabel.textColor = [UIColor colorWithRed:53/255.0 green:194/255.0 blue:211/255.0 alpha:1.0];;
////        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
//        self.countdownLabel.text = @"ENDS IN";
//        interval = [self.dealStatus.endDate timeIntervalSinceDate:now];
//    }
//    else {
//        self.countdownLabel.textColor = [[ThemeManager sharedTheme] redColor];
////        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
//        self.countdownLabel.text = @"STARTS IN";
//        interval = [self.dealStatus.startDate timeIntervalSinceDate:now];
//    }
//    NSInteger hours = floor(interval/(60.0*60.0));
//    NSInteger minutes = floor((interval - hours*60*60)/60.0);
//    NSInteger seconds = interval - 60*60*hours - 60*minutes;
//    NSString *timeLeft = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
//    self.countdownLabel.text = [NSString stringWithFormat:@"%@ %@", self.countdownLabel.text, timeLeft];
//}

- (void)setBeaconDeal:(Beacon *)beacon
{
    [self view];
    _beacon = beacon;
    self.beacon = beacon;
    self.deal = beacon.deal;
    self.dealStatus = beacon.userDealStatus;
    NSLog(@"DEAL STATUS: %@", self.dealStatus.dealStatus);
    //[self loadPaymentDeal];
    [self updateRedeemButtonAppearance];
    //[self updateFeedbackButtonAppearance];
    [self.tableView reloadData];

}

//- (void)feedbackButtonTouched:(id)sender
//{
//    [self feedbackDeal];
////    [self.feedbackButton setTitle:@"Feedback submitted" forState:UIControlStateNormal];
//}

- (void)redeemButtonTouched:(id)sender
{
    
//    if (!self.deal.inAppPayment) {
//        if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This voucher has already been redeemed and can't be reused" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            return;
//        }
//        if ([self dealNow]) {
//            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Redeem this deal?" message:@"Only staff should redeem deal"];
//            [alertView bk_addButtonWithTitle:@"Yes" handler:^{
//                [self redeemDeal];
//            }];
//            [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
//            [alertView show];
//            return;
//        }
//        NSString *message;
//        NSString *title = @"Sorry";
//        if ([self dealUpcoming]) {
//            message = @"This voucher isn't available yet.";
//        }
//        else {
//            message = @"This voucher has expired.";
//        }
//        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
//        [alertView bk_setCancelButtonWithTitle:@"OK" handler:nil];
//        [alertView show];
//    } else {
    if (self.dealStatus.paymentAuthorization) {
        if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This voucher has already been redeemed and can't be reused" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        } else {
            NSString *message = [NSString stringWithFormat:@"Tap ‘CONFIRM’ and the customer will be charged $%@ for a %@. They are paying through the Hotspot app, so don’t charge them for this drink.", self.deal.itemPrice, self.deal.itemName];
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Staff Only" message:message];
            [alertView bk_addButtonWithTitle:@"Confirm" handler:^{
                [self redeemDeal];
            }];
            [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
            [alertView show];
            return;
        }
    } else {
        [[APIClient sharedClient] getRewardsItems:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *rewardItemsString = responseObject[@"number_of_reward_items"];
            if ([rewardItemsString intValue] > 0 && self.beacon.deal.rewardEligibility) {
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                [self promptToUseRewardItems];
            } else {
                [self.delegate initPaymentsViewControllerAndSetDeal];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        }];
    }
}

- (void)redeemDeal
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] redeemDeal:self.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self refreshBeaconDataInDeal];
        NSString *dealStatus = responseObject[@"deal_status"];
        //NSLog(@"DealStatus: %@", dealStatus);
        self.dealStatus.dealStatus = dealStatus;
        [self updateRedeemButtonAppearance];
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:nil];
}

- (void)updateRedeemButtonAppearance
{
    NSString *title;
    NSString *voucherTitleText;
    NSString *itemNameText;
    NSString *venueNameText;
    NSString *serverMessageText;

    title = @"";
    UIColor *activeColor = [UIColor colorWithRed:73/255. green:115/255. blue:68/255. alpha:1];
    UIColor *inactiveColor = [UIColor unnormalizedColorWithRed:156 green:156 blue:156 alpha:255];
    UIColor *accentColor;
    UIColor *backgroundColor;
    UIColor *color;
    
    
    
    if (![self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed] && self.dealStatus.paymentAuthorization) {
        color = activeColor;
        backgroundColor = [UIColor unnormalizedColorWithRed:229 green:243 blue:228 alpha:255];
        voucherTitleText = @"VOUCHER FOR:";
        itemNameText = [NSString stringWithFormat:@"ONE %@", [self.deal.itemName uppercaseString]];
        venueNameText = [NSString stringWithFormat:@"@ %@", [self.deal.venue.name uppercaseString]];
        serverMessageText = @"SERVER ONLY: TAP TO REDEEM";
        accentColor = color;
        [self.headerIcon setImage:[UIImage imageNamed:@"redeemedIcon"]];
        self.headerTitle.text = @"YOU'RE ALL SET!";
        self.headerExplanationText.text = [NSString stringWithFormat:@"You haven't been charged yet. Have your server tap the voucher below to redeem your $%@ %@", self.deal.itemPrice, self.deal.itemName];
        [self.redeemButton setImage:[UIImage imageNamed:@"activeVoucher"] forState:UIControlStateNormal];
        [self.voucherIcon setImage:[UIImage imageNamed:@"fingerprintIcon"]];
    } else if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed] && self.dealStatus.paymentAuthorization) {
        color = inactiveColor;
        backgroundColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1];
        voucherTitleText = @"VOUCHER FOR:";
        itemNameText = [NSString stringWithFormat:@"PAID $%@ FOR %@", self.deal.itemPrice, [self.deal.itemName uppercaseString]];
        venueNameText = [NSString stringWithFormat:@"@ %@", [self.deal.venue.name uppercaseString]];
        serverMessageText = @"REDEEMED";
        accentColor = [UIColor unnormalizedColorWithRed:240 green:122 blue:101 alpha:255];
        [self.headerIcon setImage:[UIImage imageNamed:@"drinkIcon"]];
        self.headerTitle.text = @"DON'T FORGET TO TIP!";
        self.headerExplanationText.text = [NSString stringWithFormat:@"You just paid $%@ for %@. Text more friends to meet you to earn free drinks. And don’t forget to tip!", self.deal.itemPrice, self.deal.itemName];
        [self.redeemButton setImage:[UIImage imageNamed:@"redeemedVoucher"] forState:UIControlStateNormal];
        [self.voucherIcon setImage:[UIImage imageNamed:@"redeemedIcon"]];

    } else if (!self.dealStatus.paymentAuthorization) {
        [self.headerIcon setImage:[UIImage imageNamed:@"creditCardIcon"]];
        self.headerTitle.text = @"ALMOST THERE!";
        self.headerExplanationText.text = @"Just add a payment method to pay for your drink. You’re only charged after you receive it.";
        [self.redeemButton setImage:[UIImage imageNamed:@"inactiveVoucher"] forState:UIControlStateNormal];
        accentColor = color;
    }
    
    
    self.voucherTitle.textColor = color;
    self.itemName.textColor = color;
    self.venueName.textColor = color;
    self.serverMessage.textColor = accentColor;
    
    self.voucherTitle.text = voucherTitleText;
    self.itemName.text = itemNameText;
    self.venueName.text = venueNameText;
    self.serverMessage.text = serverMessageText;

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
        height = 54;
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
        //cell = [self countdownCell];
    }
    else if (indexPath.row == 1) {
        cell = [self dealDescriptionCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//- (UITableViewCell *)countdownCell
//{
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    cell.backgroundColor = [UIColor whiteColor];
//    [cell.contentView addSubview:self.countdownLabel];
//    cell.indentationLevel = 1;
//    cell.indentationWidth = 15;
//    self.countdownLabel.size = CGSizeMake(cell.contentView.width, 23);
//    self.countdownLabel.y = 30;
//    self.countdownLabel.x = 20;
//    self.countdownLabel.textAlignment = NSTextAlignmentLeft;
//    
////    [cell.contentView addSubview:self.timeLeftLabel];
////    self.timeLeftLabel.size = CGSizeMake(cell.contentView.width, 31);
////    self.timeLeftLabel.y = 37;
////    self.timeLeftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
////    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
//    return cell;
//}

- (UITableViewCell *)dealDescriptionCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
//    if (self.deal.inAppPayment){
////        cell.indentationLevel = 1;
////        cell.indentationWidth = 5;
////        cell.backgroundColor = [UIColor whiteColor];
////        cell.textLabel.text = @"HERE'S THE DEAL:";
////        cell.textLabel.font = [ThemeManager boldFontOfSize:16];
////        cell.textLabel.textColor = [[ThemeManager sharedTheme] redColor];
////        cell.detailTextLabel.y = 45;
////        cell.detailTextLabel.text = self.deal.dealDescription;
////        cell.detailTextLabel.font = [ThemeManager lightFontOfSize:16];
////        cell.detailTextLabel.textColor = [UIColor unnormalizedColorWithRed:56 green:56 blue:56 alpha:255];
////        cell.detailTextLabel.numberOfLines = 0;
//    } else {
//        cell.indentationLevel = 1;
//        cell.indentationWidth = 5;
//        cell.backgroundColor = [UIColor whiteColor];
//        cell.textLabel.text = @"HERE'S THE DEAL:";
//        cell.textLabel.font = [ThemeManager boldFontOfSize:16];
//        cell.textLabel.textColor = [[ThemeManager sharedTheme] redColor];
//        cell.detailTextLabel.y = 45;
//        cell.detailTextLabel.text = self.deal.dealDescription;
//        cell.detailTextLabel.font = [ThemeManager lightFontOfSize:16];
//        cell.detailTextLabel.textColor = [UIColor unnormalizedColorWithRed:56 green:56 blue:56 alpha:255];
//        cell.detailTextLabel.numberOfLines = 0;
//    }
    
    return cell;
}

- (void)promptToUseRewardItems
{    
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Redeem Free Drink?" message:@"Do you want to pay for your drink or use one of your free drinks?"];
    [alertView bk_addButtonWithTitle:@"Use Free Drink" handler:^{
        [self.delegate redeemRewardItem];
    }];
    [alertView bk_setCancelButtonWithTitle:@"Pay for Drink" handler:^{
        [self.delegate checkPaymentsOnFile];
    }];
    [alertView show];
}

-(void)refreshBeaconDataInDeal
{
    [[BeaconManager sharedManager] getBeaconWithID:self.beacon.beaconID success:^(Beacon *beacon) {
        [self setBeaconDeal:beacon];
    } failure:nil];
}

- (void) inviteFriendsButtonTouched:(id)sender
{
    [self.delegate inviteMoreFriends];
}

//- (void)inviteMoreFriends
//{
//    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
//    findFriendsViewController.delegate = self;
//    NSMutableArray *inactives = [[NSMutableArray alloc] init];
//    for (BeaconStatus *status in self.beacon.guestStatuses.allValues) {
//        if (status.user) {
//            [inactives addObject:status.user];
//        }
//        else if (status.contact) {
//            [inactives addObject:status.contact];
//        }
//    }
//    findFriendsViewController.inactiveContacts = inactives;
//    [self.navigationController pushViewController:findFriendsViewController animated:YES];
//}
//
//#pragma mark - FindFriendsViewControllerDelegate
//- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
//{
//    [self.navigationController popToViewController:self animated:YES];
//    if (!contacts || !contacts.count) {
//        return;
//    }
//    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
//    [[APIClient sharedClient] inviteMoreContacts:contacts toBeacon:self.beacon success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self refreshBeaconData];
//        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again later" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }];
//    [[AnalyticsManager sharedManager] inviteToBeacon:contacts.count];
//}



@end