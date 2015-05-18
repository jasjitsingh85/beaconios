//
//  VoucherRedemptionView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/17/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

//
//  DealRedemptionViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "VoucherRedemptionViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "DashedBorderButton.h"
#import "Deal.h"
#import "Venue.h"
#import "DealStatus.h"
#import "LoadingIndictor.h"
#import "APIClient.h"

@interface VoucherRedemptionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) DashedBorderButton *redeemButton;
@property (strong, nonatomic) UIButton *feedbackButton;
@property (strong, nonatomic) UILabel *countdownLabel;
@property (strong, nonatomic) UILabel *voucherTitle;
@property (strong, nonatomic) UILabel *itemName;
@property (strong, nonatomic) UILabel *venueName;
@property (strong, nonatomic) UILabel *serverMessage;
//@property (strong, nonatomic) UILabel *timeLeftLabel;

@end

@implementation VoucherRedemptionViewController

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
}

- (void) loadPaymentDeal
{
    //    self.countdownLabel = [[UILabel alloc] init];
    //    self.countdownLabel.font = [ThemeManager boldFontOfSize:16];
    //    self.countdownLabel.textColor = [UIColor unnormalizedColorWithRed:53 green:194 blue:211 alpha:255];
    //
    //    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    
    self.redeemButton = [DashedBorderButton buttonWithType:UIButtonTypeCustom];
    self.redeemButton.layer.cornerRadius = 6;
    self.redeemButton.border.lineWidth = 4;
    self.redeemButton.border.strokeColor = [UIColor colorWithRed:138/255. green:136/255. blue:136/255. alpha:1].CGColor;
    self.redeemButton.border.fillColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1].CGColor;
    self.redeemButton.border.lineDashPattern = @[@10, @10];
    self.redeemButton.size = CGSizeMake(280, 185);
    [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.voucherTitle = [[UILabel alloc] init];
    self.voucherTitle.size = CGSizeMake(self.redeemButton.width, 34);
    self.voucherTitle.y = 20;
    self.voucherTitle.textAlignment = NSTextAlignmentCenter;
    self.voucherTitle.text = @"VOUCHER FOR:";
    [self.redeemButton addSubview:self.voucherTitle];
    
    self.itemName = [[UILabel alloc] init];
    self.itemName.size = CGSizeMake(self.redeemButton.width, 34);
    self.itemName.font = [ThemeManager boldFontOfSize:34];
    self.itemName.y = 55;
    self.itemName.textAlignment = NSTextAlignmentCenter;
    self.itemName.text = [self.deal.itemName uppercaseString];
    [self.redeemButton addSubview:self.itemName];
    
    self.venueName = [[UILabel alloc] init];
    self.venueName.size = CGSizeMake(self.redeemButton.width, 34);
    self.venueName.textAlignment = NSTextAlignmentCenter;
    self.venueName.y = 95;
    self.venueName.text = [NSString stringWithFormat:@"AT %@", [self.deal.venue.name uppercaseString]];
    [self.redeemButton addSubview:self.venueName];
    
    self.serverMessage = [[UILabel alloc] init];
    self.serverMessage.size = CGSizeMake(self.redeemButton.width, 34);
    self.serverMessage.textAlignment = NSTextAlignmentCenter;
    self.serverMessage.y = 135;
    self.serverMessage.text = @"SERVER ONLY: TAP TO REDEEM";
    self.serverMessage.font = [ThemeManager boldFontOfSize:14];
    [self.redeemButton addSubview:self.serverMessage];
    
    self.feedbackButton = [[UIButton alloc] init];
    self.feedbackButton.size = CGSizeMake(self.view.width, 34);
    self.feedbackButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    self.feedbackButton.backgroundColor = [UIColor unnormalizedColorWithRed:48 green:48 blue:48 alpha:255];
    self.feedbackButton.titleLabel.textColor = [UIColor whiteColor];
    self.feedbackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    footerView.backgroundColor = [UIColor whiteColor];
    self.feedbackButton.bottom = 264;
    self.feedbackButton.centerX = footerView.width/2.0;
    [self.tableView addSubview:self.feedbackButton];
    [self.feedbackButton addTarget:self action:@selector(feedbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.redeemButton.centerX = footerView.width/2.0;
    self.redeemButton.bottom = 205;
    [self.tableView addSubview:self.redeemButton];
    //[self.tableView addSubview:footerView];
    //self.tableView.tableFooterView = footerView;
    
}

- (void)loadCouponDeal
{
    
    self.countdownLabel = [[UILabel alloc] init];
    self.countdownLabel.font = [ThemeManager boldFontOfSize:16];
    self.countdownLabel.textColor = [UIColor unnormalizedColorWithRed:53 green:194 blue:211 alpha:255];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    
    self.redeemButton = [DashedBorderButton buttonWithType:UIButtonTypeCustom];
    self.redeemButton.layer.cornerRadius = 6;
    self.redeemButton.size = CGSizeMake(280, 42);
    [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.feedbackButton = [[UIButton alloc] init];
    self.feedbackButton.size = CGSizeMake(self.view.width, 34);
    self.feedbackButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    self.feedbackButton.backgroundColor = [UIColor unnormalizedColorWithRed:48 green:48 blue:48 alpha:255];
    self.feedbackButton.titleLabel.textColor = [UIColor whiteColor];
    self.feedbackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
    footerView.backgroundColor = [UIColor whiteColor];
    self.feedbackButton.bottom = footerView.height + 10;
    [footerView addSubview:self.feedbackButton];
    self.feedbackButton.centerX = footerView.width/2.0;
    self.redeemButton.centerX = footerView.width/2.0;
    self.redeemButton.bottom = footerView.height - 40;
    [self.feedbackButton addTarget:self action:@selector(feedbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
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
        //        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
        self.countdownLabel.text = @"DEAL HAS PASSED";
        return;
    }
    else if ([self dealNow]) {
        self.countdownLabel.textColor = [UIColor colorWithRed:53/255.0 green:194/255.0 blue:211/255.0 alpha:1.0];;
        //        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
        self.countdownLabel.text = @"ENDS IN";
        interval = [self.dealStatus.endDate timeIntervalSinceDate:now];
    }
    else {
        self.countdownLabel.textColor = [[ThemeManager sharedTheme] redColor];
        //        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
        self.countdownLabel.text = @"STARTS IN";
        interval = [self.dealStatus.startDate timeIntervalSinceDate:now];
    }
    NSInteger hours = floor(interval/(60.0*60.0));
    NSInteger minutes = floor((interval - hours*60*60)/60.0);
    NSInteger seconds = interval - 60*60*hours - 60*minutes;
    NSString *timeLeft = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    self.countdownLabel.text = [NSString stringWithFormat:@"%@ %@", self.countdownLabel.text, timeLeft];
}

- (void)setDeal:(Deal *)deal andVoucher:(Voucher *)voucher
{
    [self view];
    
    self.deal = deal;
    self.dealStatus = dealStatus;
    [self loadPaymentDeal];
    [self updateRedeemButtonAppearance];
    [self updateFeedbackButtonAppearance];
    [self.tableView reloadData];
}

- (void)feedbackButtonTouched:(id)sender
{
    [self feedbackDeal];
    //    [self.feedbackButton setTitle:@"Feedback submitted" forState:UIControlStateNormal];
}

- (void)redeemButtonTouched:(id)sender
{
    if (self.dealStatus.paymentAuthorization || !self.deal.inAppPayment) {
        if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This voucher has already been redeemed and can't be reused" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        if ([self dealNow]) {
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Redeem this deal?" message:@"Only staff should redeem deal"];
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
            message = @"This voucher isn't available yet.";
        }
        else {
            message = @"This voucher has expired.";
        }
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
        [alertView bk_setCancelButtonWithTitle:@"OK" handler:nil];
        [alertView show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Voucher Inactive" message:@"The host hasn't opened a tab" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
}

- (void)feedbackDeal
{
    [[APIClient sharedClient] feedbackDeal:self.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *feedbackStatus = responseObject[@"feedback_status"];
        self.dealStatus.feedback = [feedbackStatus boolValue];
        [self updateFeedbackButtonAppearance];
    } failure:nil];
}

- (void)updateFeedbackButtonAppearance
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:[ThemeManager regularFontOfSize:14],
                            NSParagraphStyleAttributeName:style}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:[ThemeManager boldFontOfSize:14],
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:[UIColor colorWithRed:0/255. green:162/255. blue:255/255. alpha:1]}; // Added line
    if (!self.dealStatus.feedback) {
        NSLog(@"%d", self.dealStatus.feedback);
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Had a problem? " attributes:dict1]];
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Tap here." attributes:dict2]];
        [self.feedbackButton setAttributedTitle:attString forState:UIControlStateNormal];
    }
    else {
        NSLog(@"Submitted");
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Feedback submitted" attributes:dict1]];
        [self.feedbackButton setAttributedTitle:attString forState:UIControlStateNormal];
    }
    
}

- (void)redeemDeal
{
    //[LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] redeemDeal:self.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *dealStatus = responseObject[@"deal_status"];
        self.dealStatus.dealStatus = dealStatus;
        [self updateRedeemButtonAppearance];
        //[LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:nil];
}

- (void)updateRedeemButtonAppearance
{
    NSString *title;
    NSString *voucherTitleText;
    NSString *itemNameText;
    NSString *venueNameText;
    NSString *serverMessageText;
    
    if (self.deal.inAppPayment) {
        title = @"";
        UIColor *activeColor = [UIColor colorWithRed:105/255. green:193/255. blue:98/255. alpha:1];
        UIColor *inactiveColor = [UIColor unnormalizedColorWithRed:110 green:110 blue:110 alpha:255];
        UIColor *backgroundColor;
        UIColor *color;
        
        if ([self dealNow] && ![self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed] && self.dealStatus.paymentAuthorization) {
            color = activeColor;
            backgroundColor = [UIColor unnormalizedColorWithRed:229 green:243 blue:228 alpha:255];
            voucherTitleText = @"VOUCHER FOR:";
            itemNameText = [self.deal.itemName uppercaseString];
            venueNameText = [NSString stringWithFormat:@"AT %@", [self.deal.venue.name uppercaseString]];
            serverMessageText = @"SERVER ONLY: TAP TO REDEEM";
        }
        else {
            color = inactiveColor;
            backgroundColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1];
            if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
                voucherTitleText = [self.deal.itemName uppercaseString];
                itemNameText = @"REDEEMED";
                venueNameText = [NSString stringWithFormat:@"AT %@", [self.deal.venue.name uppercaseString]];
                serverMessageText = @"VOUCHER CANNOT BE REUSED";
            }
            else if ([self dealPassed]){
                voucherTitleText = @"";
                itemNameText = @"EXPIRED";
                venueNameText = @"";
                serverMessageText = @"";
            } else if (!self.dealStatus.paymentAuthorization) {
                voucherTitleText = @"VOUCHER";
                itemNameText = @"INACTIVE";
                venueNameText = @"TAB HASN'T BEEN OPENED";
                serverMessageText = @"VOUCHER CANNOT BE USED";
            }
            else {
                voucherTitleText = @"";
                itemNameText = @"INACTIVE";
                venueNameText = @"";
                serverMessageText = @"";
            }
        }
        self.voucherTitle.textColor = color;
        self.itemName.textColor = color;
        self.venueName.textColor = color;
        self.serverMessage.textColor = color;
        
        self.redeemButton.border.strokeColor = color.CGColor;
        self.voucherTitle.text = voucherTitleText;
        self.itemName.text = itemNameText;
        self.venueName.text = venueNameText;
        self.serverMessage.text = serverMessageText;
        self.redeemButton.border.fillColor = backgroundColor.CGColor;
        
    } else {
        UIColor *inactiveColor = [UIColor colorWithWhite:205/255.0 alpha:1.0];
        UIColor *activeColor = [UIColor unnormalizedColorWithRed:138 green:136 blue:136 alpha:255];
        UIColor *color;
        if ([self dealNow] && ![self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
            color = activeColor;
            title = @"Show Staff to Redeem";
        } else {
            color = inactiveColor;
            if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
                title = @"Deal Redeemed";
            }
            else if ([self dealPassed]){
                title = @"Deal Passed";
            }
            else {
                title = @"Show Staff to Redeem";
            }
        }
        self.redeemButton.border.strokeColor = color.CGColor;
        [self.redeemButton setTitleColor:color forState:UIControlStateNormal];
    }
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
    cell.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:self.countdownLabel];
    cell.indentationLevel = 1;
    cell.indentationWidth = 15;
    self.countdownLabel.size = CGSizeMake(cell.contentView.width, 23);
    self.countdownLabel.y = 30;
    self.countdownLabel.x = 20;
    self.countdownLabel.textAlignment = NSTextAlignmentLeft;
    
    //    [cell.contentView addSubview:self.timeLeftLabel];
    //    self.timeLeftLabel.size = CGSizeMake(cell.contentView.width, 31);
    //    self.timeLeftLabel.y = 37;
    //    self.timeLeftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UITableViewCell *)dealDescriptionCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (self.deal.inAppPayment){
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
    } else {
        cell.indentationLevel = 1;
        cell.indentationWidth = 5;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = @"HERE'S THE DEAL:";
        cell.textLabel.font = [ThemeManager boldFontOfSize:16];
        cell.textLabel.textColor = [[ThemeManager sharedTheme] redColor];
        cell.detailTextLabel.y = 45;
        cell.detailTextLabel.text = self.deal.dealDescription;
        cell.detailTextLabel.font = [ThemeManager lightFontOfSize:16];
        cell.detailTextLabel.textColor = [UIColor unnormalizedColorWithRed:56 green:56 blue:56 alpha:255];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    return cell;
}



@end