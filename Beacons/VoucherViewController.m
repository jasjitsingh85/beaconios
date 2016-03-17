//
//  VoucherViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 3/16/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoucherViewController.h"
#import "SponsoredEvent.h"
#import "Venue.h"
#import "EventStatus.h"
#import "APIClient.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "WebViewController.h"

@interface VoucherViewController ()

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
@property (strong, nonatomic) UILabel *inviteFriendsExplanation;
@property (strong, nonatomic) WebViewController *webView;

@end

@implementation VoucherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.headerIcon = [[UIImageView alloc] init];
    self.headerIcon.height = 18;
    self.headerIcon.width = 18;
    self.headerIcon.x = 20;
    self.headerIcon.y = 15;
    [self.view addSubview:self.headerIcon];
    
    self.headerTitle = [[UILabel alloc] init];
    self.headerTitle.height = 20;
    self.headerTitle.width = self.view.width;
    self.headerTitle.textAlignment = NSTextAlignmentLeft;
    self.headerTitle.x = 42;
    self.headerTitle.font = [ThemeManager boldFontOfSize:11];
    self.headerTitle.y = 14;
    [self.view addSubview:self.headerTitle];
    
    self.headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.width - 45, 50)];
    self.headerExplanationText.centerX = self.view.width/2;
    self.headerExplanationText.font = [ThemeManager lightFontOfSize:12];
    self.headerExplanationText.textAlignment = NSTextAlignmentLeft;
    self.headerExplanationText.numberOfLines = 2;
    [self.view addSubview:self.headerExplanationText];
    
    self.redeemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redeemButton.y = 270;
    self.redeemButton.size = CGSizeMake(self.view.width, 150);
    
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
    [self.redeemButton addSubview:self.itemName];
    
    self.venueName = [[UILabel alloc] init];
    self.venueName.size = CGSizeMake(self.redeemButton.width, 20);
    self.venueName.font = [ThemeManager boldFontOfSize:16];
    self.venueName.textAlignment = NSTextAlignmentCenter;
    self.venueName.y = 52;
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
    self.inviteFriendsButton.size = CGSizeMake(self.view.width - 50, 35);
    self.inviteFriendsButton.centerX = self.view.width/2;
    self.inviteFriendsButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
    [self.inviteFriendsButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    [self.inviteFriendsButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:.5] forState:UIControlStateSelected];
    self.inviteFriendsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.inviteFriendsButton setTitle:@"SEE IN FACEBOOK" forState:UIControlStateNormal];
    self.inviteFriendsButton.y = 172;
    [self.view addSubview:self.inviteFriendsButton];
    [self.inviteFriendsButton addTarget:self action:@selector(seeFacebookButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.redeemButton];
    [self.redeemButton addTarget:self action:@selector(redeemButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.webView = [[WebViewController alloc] init];
    
//    [self refreshSponsoredEventData];
}

-(void)setSponsoredEvent:(SponsoredEvent *)sponsoredEvent
{
    _sponsoredEvent = sponsoredEvent;
    
    self.itemName.text = [self.sponsoredEvent.title uppercaseString];
    self.venueName.text = [NSString stringWithFormat:@"@ %@", [self.sponsoredEvent.venue.name uppercaseString]];
    
    [self showVoucherViewForSponsoredEvent];
}

-(void)showVoucherViewForSponsoredEvent {
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
    
    if (self.sponsoredEvent.eventStatusOption == EventStatusGoing) {
        color = activeColor;
        backgroundColor = [UIColor unnormalizedColorWithRed:229 green:243 blue:228 alpha:255];
        voucherTitleText = @"VOUCHER FOR:";
        itemNameText = [NSString stringWithFormat:@"%@", [self.sponsoredEvent.title uppercaseString]];
        venueNameText = [NSString stringWithFormat:@"@ %@", [self.sponsoredEvent.venue.name uppercaseString]];
        serverMessageText = @"SERVER ONLY: TAP TO REDEEM";
        accentColor = color;
        [self.headerIcon setImage:[UIImage imageNamed:@"redeemIcon"]];
        self.headerTitle.text = @"SHOW TICKET AT DOOR";
        self.headerExplanationText.text = [NSString stringWithFormat:@"We’ll tap your ticket at the door. You aren’t charged until the ticket is redeemed."];
        [self.redeemButton setImage:[UIImage imageNamed:@"activeVoucher"] forState:UIControlStateNormal];
        [self.voucherIcon setImage:[UIImage imageNamed:@"fingerprintIcon"]];
    } else if (self.sponsoredEvent.eventStatusOption == EventStatusRedeemed) {
        color = inactiveColor;
        backgroundColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1];
        voucherTitleText = @"VOUCHER REDEEMED";
        itemNameText = [NSString stringWithFormat:@"PAID $%@", self.sponsoredEvent.itemPrice];
        venueNameText = [NSString stringWithFormat:@"@ %@", [self.sponsoredEvent.venue.name uppercaseString]];
        serverMessageText = @"REDEEMED";
        accentColor = [[ThemeManager sharedTheme] redColor];
        [self.headerIcon setImage:[UIImage imageNamed:@"newDrinkIcon"]];
        self.headerTitle.text = @"DON'T FORGET TO TIP!";
        self.headerExplanationText.text = [NSString stringWithFormat:@"You're all set. You've been charged $%@. Enjoy your night and don't forget to tip.", self.sponsoredEvent.itemPrice];
        [self.redeemButton setImage:[UIImage imageNamed:@"redeemedVoucher"] forState:UIControlStateNormal];
        [self.voucherIcon setImage:[UIImage imageNamed:@"redeemIcon"]];
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

-(void)refreshSponsoredEventData
{
    if (!self.sponsoredEvent) {
        return;
    }
    
    [[APIClient sharedClient] getSponsoredEvent:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SponsoredEvent *sponsoredEvent = [[SponsoredEvent alloc] initWithDictionary:responseObject[@"sponsored_event"]];
        [self setSponsoredEvent:sponsoredEvent];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed");
    }];
}

- (void)redeemEvent
{
    //    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoadingInRedemptionView" object:self userInfo:nil];
    [[APIClient sharedClient] redeemEvent:self.sponsoredEvent.eventStatus.eventStatusID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"sponsored_event"]) {
            //            [self hideOverlayView];
            [self refreshSponsoredEventData];
            [self showVoucherViewForSponsoredEvent];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Ticket Unavailable" message:@"The ticket will be available for staff to tap 30 minutes before the event begins. Only event staff should tap this ticket." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingInRedemptionView" object:self userInfo:nil];
        //        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingInRedemptionView" object:self userInfo:nil];
    }];
}

- (void)redeemButtonTouched:(id)sender
{
    //    if (self.sponsoredEvent) {
    if ([self.sponsoredEvent.eventStatus.status isEqualToString:@"R"]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This voucher has already been redeemed and can't be reused" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    } else {
        NSString *message;
        message = [NSString stringWithFormat:@"Tap ‘CONFIRM’ and the customer will be charged $%@. They are paying through the Hotspot app, so don’t charge them in person.", self.sponsoredEvent.itemPrice];
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Staff Only" message:message];
        [alertView bk_addButtonWithTitle:@"Confirm" handler:^{
            [self redeemEvent];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alertView show];
        return;
    }
}

- (void) seeFacebookButtonTouched:(id)sender
{
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    if (isInstalled) {;
        [[UIApplication sharedApplication] openURL:self.sponsoredEvent.deepLinkURL];
    } else {
        self.webView.websiteUrl = self.sponsoredEvent.websiteURL;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webView];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}

@end

