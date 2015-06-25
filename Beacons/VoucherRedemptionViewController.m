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
#import "Voucher.h"
#import "DealStatus.h"
#import "LoadingIndictor.h"
#import "APIClient.h"

@interface VoucherRedemptionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *redeemButton;
@property (strong, nonatomic) UIButton *feedbackButton;
@property (strong, nonatomic) UILabel *countdownLabel;
@property (strong, nonatomic) UILabel *voucherTitle;
@property (strong, nonatomic) UILabel *itemName;
@property (strong, nonatomic) UILabel *venueName;
@property (strong, nonatomic) UILabel *serverMessage;
@property (assign) BOOL feedback;
@property (assign) BOOL dealRedeemed;
@property (strong, nonatomic) UIImageView *headerIcon;
@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *headerExplanationText;
@property (strong, nonatomic) UIImageView *voucherIcon;
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
    self.dealRedeemed = NO;
    [self.view addSubview:self.tableView];
    
    self.headerIcon = [[UIImageView alloc] init];
    self.headerIcon.height = 30;
    self.headerIcon.width = 30;
    self.headerIcon.centerX = self.view.width/2;
    self.headerIcon.y = -10;
    [self.tableView addSubview:self.headerIcon];
    
    self.headerTitle = [[UILabel alloc] init];
    self.headerTitle.height = 30;
    self.headerTitle.width = self.tableView.width;
    self.headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    self.headerTitle.font = [ThemeManager boldFontOfSize:11];
    self.headerTitle.y = 15;
    [self.tableView addSubview:self.headerTitle];
    
    self.headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.width - 50, 50)];
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
    
//    UILabel *inviteFriendsExplanation = [[UILabel alloc] initWithFrame:CGRectMake(0, 260, self.view.width - 50, 50)];
//    inviteFriendsExplanation.centerX = self.view.width/2;
//    inviteFriendsExplanation.font = [ThemeManager lightFontOfSize:12];
//    inviteFriendsExplanation.textAlignment = NSTextAlignmentCenter;
//    inviteFriendsExplanation.text = @"Tap below to text more friends to meet you here.";
//    inviteFriendsExplanation.numberOfLines = 1;
//    [self.tableView addSubview:inviteFriendsExplanation];
    
    self.redeemButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    self.voucherTitle.textColor = [UIColor colorWithRed:73/255. green:115/255. blue:68/255. alpha:1];
    [self.redeemButton addSubview:self.voucherTitle];
    
    self.itemName = [[UILabel alloc] init];
    self.itemName.size = CGSizeMake(self.redeemButton.width, 20);
    self.itemName.font = [ThemeManager boldFontOfSize:16];
    self.itemName.y = 36;
    self.itemName.textAlignment = NSTextAlignmentCenter;
    self.itemName.text = [self.voucher.deal.itemName uppercaseString];
    self.itemName.textColor = [UIColor colorWithRed:73/255. green:115/255. blue:68/255. alpha:1];
    [self.redeemButton addSubview:self.itemName];
    
    self.venueName = [[UILabel alloc] init];
    self.venueName.size = CGSizeMake(self.redeemButton.width, 20);
    self.venueName.font = [ThemeManager boldFontOfSize:16];
    self.venueName.textAlignment = NSTextAlignmentCenter;
    self.venueName.y = 52;
    self.venueName.textColor = [UIColor colorWithRed:73/255. green:115/255. blue:68/255. alpha:1];
    self.venueName.text = [NSString stringWithFormat:@"@ %@", [self.voucher.deal.venue.name uppercaseString]];
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
    self.serverMessage.textColor = [UIColor colorWithRed:73/255. green:115/255. blue:68/255. alpha:1];
    self.serverMessage.text = @"SERVER ONLY: TAP TO REDEEM";
    self.serverMessage.font = [ThemeManager boldFontOfSize:11];
    [self.redeemButton addSubview:self.serverMessage];
    
    //self.redeemButton.centerX = footerView.width/2.0;
    self.redeemButton.y = 105;
    [self.tableView addSubview:self.redeemButton];
    //[self.tableView addSubview:footerView];
    //self.tableView.tableFooterView = footerView;
    
    [self.headerIcon setImage:[UIImage imageNamed:@"redeemedIcon"]];
    self.headerTitle.text = @"GET THINGS STARTED!";
    self.headerExplanationText.text = @"Have your server tap the voucher below to receive your drink. You’re only charged once it’s redeemed.";
    [self.redeemButton setImage:[UIImage imageNamed:@"activeVoucher"] forState:UIControlStateNormal];
    [self.voucherIcon setImage:[UIImage imageNamed:@"fingerprintIcon"]];
}

- (void) loadPaymentDeal
{
    if (!self.dealRedeemed) {
//        UIColor *activeColor = [UIColor colorWithRed:105/255. green:193/255. blue:98/255. alpha:1];
//        
//        self.redeemButton = [DashedBorderButton buttonWithType:UIButtonTypeCustom];
//        self.redeemButton.layer.cornerRadius = 6;
//        self.redeemButton.border.lineWidth = 4;
//        //self.redeemButton.border.strokeColor = [UIColor colorWithRed:138/255. green:136/255. blue:136/255. alpha:1].CGColor;
//        //self.redeemButton.border.fillColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1].CGColor;
//        self.redeemButton.border.lineDashPattern = @[@10, @10];
//        self.redeemButton.size = CGSizeMake(280, 185);
//        [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
//        self.voucherTitle = [[UILabel alloc] init];
//        self.voucherTitle.size = CGSizeMake(self.redeemButton.width, 34);
//        self.voucherTitle.y = 20;
//        self.voucherTitle.textAlignment = NSTextAlignmentCenter;
//        self.voucherTitle.text = @"VOUCHER FOR:";
//        [self.redeemButton addSubview:self.voucherTitle];
        
//        self.itemName = [[UILabel alloc] init];
//        self.itemName.size = CGSizeMake(self.redeemButton.width, 34);
//        self.itemName.font = [ThemeManager boldFontOfSize:34];
//        self.itemName.y = 55;
//        self.itemName.textAlignment = NSTextAlignmentCenter;
        self.itemName.text = [self.voucher.deal.itemName uppercaseString];
//        [self.redeemButton addSubview:self.itemName];
        
//        self.venueName = [[UILabel alloc] init];
//        self.venueName.size = CGSizeMake(self.redeemButton.width, 34);
//        self.venueName.textAlignment = NSTextAlignmentCenter;
//        self.venueName.y = 95;
        self.venueName.text = [NSString stringWithFormat:@"@ %@", [self.voucher.deal.venue.name uppercaseString]];
//        [self.redeemButton addSubview:self.venueName];
        
//        self.serverMessage = [[UILabel alloc] init];
//        self.serverMessage.size = CGSizeMake(self.redeemButton.width, 34);
//        self.serverMessage.textAlignment = NSTextAlignmentCenter;
//        self.serverMessage.y = 135;
//        self.serverMessage.text = @"SERVER ONLY: TAP TO REDEEM";
//        self.serverMessage.font = [ThemeManager boldFontOfSize:14];
//        [self.redeemButton addSubview:self.serverMessage];
        
//        self.feedbackButton = [[UIButton alloc] init];
//        self.feedbackButton.size = CGSizeMake(self.view.width, 34);
//        self.feedbackButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
//        self.feedbackButton.backgroundColor = [UIColor unnormalizedColorWithRed:48 green:48 blue:48 alpha:255];
//        self.feedbackButton.titleLabel.textColor = [UIColor whiteColor];
//        self.feedbackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
//        footerView.backgroundColor = [UIColor whiteColor];
//        self.feedbackButton.bottom = 264;
//        self.feedbackButton.centerX = footerView.width/2.0;
//        [self.tableView addSubview:self.feedbackButton];
//        [self.feedbackButton addTarget:self action:@selector(feedbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
//        self.redeemButton.centerX = footerView.width/2.0;
//        self.redeemButton.bottom = 205;
//        [self.tableView addSubview:self.redeemButton];
        
//        UIColor *backgroundColor = [UIColor unnormalizedColorWithRed:229 green:243 blue:228 alpha:255];
//        self.voucherTitle.text = @"VOUCHER FOR:";
//        self.itemName.text = [self.deal.itemName uppercaseString];
//        self.venueName.text = [NSString stringWithFormat:@"AT %@", [self.deal.venue.name uppercaseString]];
//        self.serverMessage.text = @"SERVER ONLY: TAP TO REDEEM";
        
//        self.voucherTitle.textColor = activeColor;
//        self.itemName.textColor = activeColor;
//        self.venueName.textColor = activeColor;
//        self.serverMessage.textColor = activeColor;
//        
//        self.redeemButton.border.strokeColor = activeColor.CGColor;
//        self.redeemButton.border.fillColor = backgroundColor.CGColor;
//        
//        self.redeemButton.border.strokeColor = activeColor.CGColor;
//        [self.redeemButton setTitleColor:activeColor forState:UIControlStateNormal];
        //[self.redeemButton setTitle:title forState:UIControlStateNormal];
        //[self.tableView addSubview:footerView];
        //self.tableView.tableFooterView = footerView;
    }
    
}

//
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
//
//- (void)updateCountdown
//{
//    if (!self.dealStatus) {
//        return;
//    }
//    NSDate *now = [NSDate date];
//    NSTimeInterval interval;
//    if ([self dealPassed]) {
//        self.countdownLabel.textColor = [UIColor colorWithWhite:205/255.0 alpha:1.0];
//        //        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
//        self.countdownLabel.text = @"DEAL HAS PASSED";
//        return;
//    }
//    else if ([self dealNow]) {
//        self.countdownLabel.textColor = [UIColor colorWithRed:53/255.0 green:194/255.0 blue:211/255.0 alpha:1.0];;
//        //        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
//        self.countdownLabel.text = @"ENDS IN";
//        interval = [self.dealStatus.endDate timeIntervalSinceDate:now];
//    }
//    else {
//        self.countdownLabel.textColor = [[ThemeManager sharedTheme] redColor];
//        //        self.timeLeftLabel.textColor = self.countdownLabel.textColor;
//        self.countdownLabel.text = @"STARTS IN";
//        interval = [self.dealStatus.startDate timeIntervalSinceDate:now];
//    }
//    NSInteger hours = floor(interval/(60.0*60.0));
//    NSInteger minutes = floor((interval - hours*60*60)/60.0);
//    NSInteger seconds = interval - 60*60*hours - 60*minutes;
//    NSString *timeLeft = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
//    self.countdownLabel.text = [NSString stringWithFormat:@"%@ %@", self.countdownLabel.text, timeLeft];
//}

- (void)setDeal:(Deal *)deal andVoucher:(Voucher *)voucher
{
    [self view];
    
    self.voucher.deal = deal;
    self.voucher = voucher;
    [self loadPaymentDeal];
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
    if (self.dealRedeemed){
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This voucher has already been redeemed and can't be reused" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    } else {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Redeem this deal?" message:@"Only staff should redeem deal"];
        [alertView bk_addButtonWithTitle:@"Yes" handler:^{
            [self redeemDeal];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alertView show];
        return;
    }
}

- (void)feedbackDeal
{
    [[APIClient sharedClient] feedbackDeal:self.voucher.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *feedbackStatus = responseObject[@"feedback_status"];
        self.feedback = [feedbackStatus boolValue];
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
    if (!self.feedback) {
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

    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] redeemVoucher:self.voucher.voucherID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dealRedeemed = YES;
        [self updateRedeemButtonAppearance];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRewardsUpdated object:self];
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:nil];
}

- (void)updateRedeemButtonAppearance
{
    UIColor *inactiveColor = [UIColor unnormalizedColorWithRed:156 green:156 blue:156 alpha:255];
    UIColor *backgroundColor;
    UIColor *color;
    
    color = inactiveColor;
    self.voucherTitle.text = @"VOUCHER FOR";
    self.itemName.text = [self.voucher.deal.itemName uppercaseString];
    self.venueName.text = [NSString stringWithFormat:@"@ %@", [self.voucher.deal.venue.name uppercaseString]];
    self.serverMessage.text = @"REDEEMED";
    
    [self.redeemButton setImage:[UIImage imageNamed:@"redeemedVoucher"] forState:UIControlStateNormal];
    [self.voucherIcon setImage:[UIImage imageNamed:@"redeemedIcon"]];
    
    self.voucherTitle.textColor = color;
    self.itemName.textColor = color;
    self.venueName.textColor = color;
    self.serverMessage.textColor = [UIColor unnormalizedColorWithRed:240 green:122 blue:101 alpha:255];;
    
//    self.redeemButton.border.strokeColor = color.CGColor;
//    self.redeemButton.border.fillColor = backgroundColor.CGColor;
//    
//    self.redeemButton.border.strokeColor = color.CGColor;
    [self.redeemButton setTitleColor:color forState:UIControlStateNormal];
    //[self.redeemButton setTitle:@"Deal Redeemed" forState:UIControlStateNormal];

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
//    if (!indexPath.row) {
//        cell = [self countdownCell];
//    }
//    else if (indexPath.row == 1) {
//        cell = [self dealDescriptionCell];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
//    //    [cell.contentView addSubview:self.timeLeftLabel];
//    //    self.timeLeftLabel.size = CGSizeMake(cell.contentView.width, 31);
//    //    self.timeLeftLabel.y = 37;
//    //    self.timeLeftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    //    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
//    return cell;
//}

//- (UITableViewCell *)dealDescriptionCell
//{
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//    
//    if (self.deal.inAppPayment){
//        //        cell.indentationLevel = 1;
//        //        cell.indentationWidth = 5;
//        //        cell.backgroundColor = [UIColor whiteColor];
//        //        cell.textLabel.text = @"HERE'S THE DEAL:";
//        //        cell.textLabel.font = [ThemeManager boldFontOfSize:16];
//        //        cell.textLabel.textColor = [[ThemeManager sharedTheme] redColor];
//        //        cell.detailTextLabel.y = 45;
//        //        cell.detailTextLabel.text = self.deal.dealDescription;
//        //        cell.detailTextLabel.font = [ThemeManager lightFontOfSize:16];
//        //        cell.detailTextLabel.textColor = [UIColor unnormalizedColorWithRed:56 green:56 blue:56 alpha:255];
//        //        cell.detailTextLabel.numberOfLines = 0;
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
//    
//    return cell;
//}



@end