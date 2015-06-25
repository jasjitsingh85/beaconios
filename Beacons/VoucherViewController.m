//
//  BeaconProfileViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/12/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "VoucherViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "NSDate+FormattedDate.h"
#import "UIButton+HSNavButton.h"
#import "UIImage+Resize.h"
#import "UIView+Shadow.h"
#import "VoucherRedemptionViewController.h"
#import "SetBeaconViewController.h"
#import "HSNavigationController.h"
#import "Beacon.h"
#import "Deal.h"
#import "Venue.h"
#import "Theme.h"
#import "User.h"
#import "BeaconManager.h"
#import "FindFriendsViewController.h"
#import "APIClient.h"
#import "LoadingIndictor.h"
#import "PhotoManager.h"
#import "BeaconImage.h"
#import "ChatMessage.h"
#import "ImageViewController.h"
#import "Utilities.h"
#import "BeaconStatus.h"
#import "TextMessageManager.h"
#import "AppDelegate.h"
#import "BounceButton.h"
#import "NavigationBarTitleLabel.h"
#import "AnalyticsManager.h"
#import "ContactManager.h"
#import "RewardsViewController.h"
#import "Voucher.h"

@interface VoucherViewController () <SetBeaconViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) VoucherRedemptionViewController *voucherRedemptionViewController;
@property (strong, nonatomic) RewardsViewController *rewardsViewController;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *imageViewGradient;
//@property (strong, nonatomic) UILabel *timeLabel;
//@property (strong, nonatomic) UILabel *descriptionLabelLineOne;
//@property (strong, nonatomic) UILabel *descriptionLabelLineTwo;
//@property (strong, nonatomic) UILabel *locationLabel;
//@property (strong, nonatomic) UILabel *invitedLabel;
//@property (strong, nonatomic) UIButton *joinButton;
//@property (strong, nonatomic) UIButton *inviteButton;
@property (strong, nonatomic) UIButton *feedbackButton;
@property (strong, nonatomic) UILabel *descriptionLabelLineOne;
@property (strong, nonatomic) UILabel *descriptionLabelLineTwo;
//@property (strong, nonatomic) UIButton *editButton;
//@property (strong, nonatomic) UIView *addPictureView;
@property (assign, nonatomic) BOOL fullDescriptionViewShown;
@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) BOOL promptShowing;
@property (assign, nonatomic) BOOL dealMode;

@end

@implementation VoucherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
        [self addChildViewController:self.rewardsViewController];
        self.voucherRedemptionViewController = [[VoucherRedemptionViewController alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    }
    return self;
}

- (void) refreshDeal
{
    //[self refreshVoucherData];
    //[self.voucherRedemptionViewController setDeal:self.voucher.deal andVoucher:self.voucher];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UIColor *boneWhiteColor = [UIColor colorWithRed:248/255.0 green:243/255.0 blue:236/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:self.voucherRedemptionViewController];
    [self.view addSubview:self.voucherRedemptionViewController.view];
    self.voucherRedemptionViewController.view.frame = self.view.bounds;
    self.voucherRedemptionViewController.view.y = 90;
    //self.voucherRedemptionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    [self.rewardsViewController updateRewardsScore];
    
    self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 146)];
    //    self.descriptionView.backgroundColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    [self.descriptionView setShadowWithColor:[UIColor whiteColor] opacity:0.7 radius:5.0 offset:CGSizeMake(0, 10) shouldDrawPath:YES];
    [self.view addSubview:self.descriptionView];
    self.fullDescriptionViewShown = YES;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.descriptionView.frame.size.width, 146)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    //self.imageView.placeholder = [UIImage imageNamed:@"mapPlaceholder"];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    imageTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:imageTap];
    self.imageView.userInteractionEnabled = YES;
    [self.descriptionView addSubview:self.imageView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.imageView.bounds];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.descriptionView addSubview:backgroundView];
    
    self.feedbackButton = [[UIButton alloc] init];
    self.feedbackButton.size = CGSizeMake(90, 25);
    //button.backgroundColor = [UIColor clearColor];
    self.feedbackButton.layer.cornerRadius = 2;
    self.feedbackButton.layer.borderColor = [[UIColor unnormalizedColorWithRed:167 green:167 blue:167 alpha:255] CGColor];
    self.feedbackButton.layer.borderWidth = 1.0;
    [self.feedbackButton setTitle:@"REPORT ISSUE" forState:UIControlStateNormal];
    [self.feedbackButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.feedbackButton.titleLabel.font = [ThemeManager regularFontOfSize:10];
    [self.feedbackButton addTarget:self action:@selector(feedbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.feedbackButton];
    
    [self.voucherRedemptionViewController setDeal:self.voucher.deal andVoucher:self.voucher];
    
    self.descriptionLabelLineOne = [[UILabel alloc] initWithFrame:CGRectMake(5, 55 + 64, self.descriptionView.width, 30)];
    //    self.descriptionLabelLineOne.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabelLineOne.font = [ThemeManager boldFontOfSize:28];
    self.descriptionLabelLineOne.textColor = [UIColor whiteColor];
    self.descriptionLabelLineOne.textColor = [UIColor whiteColor];
    self.descriptionLabelLineOne.numberOfLines = 1;
    self.descriptionLabelLineOne.textAlignment = NSTextAlignmentLeft;
    [self.descriptionView addSubview:self.descriptionLabelLineOne];
    
    self.descriptionLabelLineTwo = [[UILabel alloc] initWithFrame:CGRectMake(5, 79 + 64, self.descriptionView.width, 46)];
    //    self.descriptionLabelLineOne.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabelLineTwo.font = [ThemeManager boldFontOfSize:36];
    self.descriptionLabelLineTwo.font = [ThemeManager boldFontOfSize:46];
    self.descriptionLabelLineTwo.textColor = [UIColor whiteColor];
    self.descriptionLabelLineTwo.numberOfLines = 1;
    self.descriptionLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    [self.descriptionView addSubview:self.descriptionLabelLineTwo];
    
    NSMutableDictionary *dealTitle = [self parseStringIntoTwoLines:self.voucher.deal.venue.name];
    self.descriptionLabelLineOne.text = [[dealTitle objectForKey:@"firstLine"] uppercaseString];
    self.descriptionLabelLineTwo.text = [[dealTitle objectForKey:@"secondLine"] uppercaseString];
    //NSString *venueString = [NSString stringWithFormat:@"@ %@", [self.voucher.deal.venue.name uppercaseString]];
    
    [self refreshVoucherData];
    
    //self.imageViewGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundGradient"]];
    //CGRect backgroundGradientFrame = self.imageViewGradient.frame;
    //backgroundGradientFrame.origin.y = self.imageView.frame.size.height - backgroundGradientFrame.size.height;
    //self.imageViewGradient.frame = backgroundGradientFrame;
    //[self.imageView addSubview:self.imageViewGradient];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
//    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:titleImage]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateDealRedemptionInsets];
}

//- (void)setDealMode:(BOOL)dealMode
//{
//    [self view];
//    _dealMode = dealMode;
//    if (dealMode) {
//        self.dealButton.size = CGSizeMake(40, 22);
//        self.dealButton.x = self.descriptionView.size.width/6.0 - 20;
//        self.dealButton.bottom = self.descriptionView.height - 18;
//        [self.descriptionView addSubview:self.dealButton];
//        
//        UILabel *dealButtonLabel = [[UILabel alloc]init];
//        dealButtonLabel.bottom = self.descriptionView.height - 17;
//        dealButtonLabel.x = 0;
//        dealButtonLabel.width = self.descriptionView.size.width/3;
//        dealButtonLabel.height = 12;
//        dealButtonLabel.textAlignment = NSTextAlignmentCenter;
//        dealButtonLabel.font = [ThemeManager boldFontOfSize:10];
//        dealButtonLabel.textColor = [UIColor whiteColor];
//        [self.descriptionView addSubview:dealButtonLabel];
//        
//        self.chatTabButton.size = CGSizeMake(30, 25);
//        self.chatTabButton.x = self.dealButton.x + self.descriptionView.width/3.0 + 5;
//        self.chatTabButton.bottom = self.descriptionView.height - 18;
//        [self.descriptionView addSubview:self.dealButton];
//        
//        UILabel *chatButtonLabel = [[UILabel alloc]init];
//        chatButtonLabel.bottom = self.descriptionView.height - 17;
//        chatButtonLabel.x = self.descriptionView.size.width/3;
//        chatButtonLabel.width = self.descriptionView.size.width/3;
//        chatButtonLabel.height = 12;
//        chatButtonLabel.textAlignment = NSTextAlignmentCenter;
//        chatButtonLabel.font = [ThemeManager boldFontOfSize:10];
//        chatButtonLabel.textColor = [UIColor whiteColor];
//        chatButtonLabel.text = @"MESSAGES";
//        [self.descriptionView addSubview:chatButtonLabel];
//        
//        self.inviteTabButton.size = CGSizeMake(40, 25);
//        self.inviteTabButton.x = self.dealButton.x + (2 * self.descriptionView.width/3.0);
//        self.inviteTabButton.bottom = self.descriptionView.height - 18;
//        [self.descriptionView addSubview:self.inviteTabButton];
//        
//        UILabel *inviteButtonLabel = [[UILabel alloc]init];
//        inviteButtonLabel.bottom = self.descriptionView.height - 16;
//        inviteButtonLabel.x = 2 * self.descriptionView.size.width/3 + 1;
//        inviteButtonLabel.width = self.descriptionView.size.width/3;
//        inviteButtonLabel.height = 12;
//        inviteButtonLabel.textAlignment = NSTextAlignmentCenter;
//        inviteButtonLabel.font = [ThemeManager boldFontOfSize:10];
//        inviteButtonLabel.textColor = [UIColor whiteColor];
//        inviteButtonLabel.text = @"INVITEES";
//        [self.descriptionView addSubview:inviteButtonLabel];
//        if (self.beaconChatViewController.beacon.deal.inAppPayment)
//        {
//            dealButtonLabel.text = @"VOUCHER";
//        } else {
//            dealButtonLabel.text = @"DEAL";
//        }
//    }
//    else {
//        CGRect chatTabButtonFrame;
//        chatTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
//        chatTabButtonFrame.origin = CGPointMake(0, self.descriptionView.frame.size.height - chatTabButtonFrame.size.height);
//        self.chatTabButton.frame = chatTabButtonFrame;
//        [self.descriptionView addSubview:self.chatTabButton];
//        
//        CGRect inviteTabButtonFrame;
//        inviteTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
//        inviteTabButtonFrame.origin = CGPointMake(CGRectGetMaxX(self.chatTabButton.frame), self.descriptionView.frame.size.height - inviteTabButtonFrame.size.height);
//        self.inviteTabButton.frame = inviteTabButtonFrame;
//        [self.descriptionView addSubview:self.inviteTabButton];
//        [self.dealButton removeFromSuperview];
//    }
//}

- (void)refreshVoucherData
{
    if (self.voucher.deal) {
        self.dealMode = YES;
        //[self.voucherRedemptionViewController setDeal:self.voucher.deal andVoucher:self.voucher];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView sd_setImageWithURL:self.voucher.deal.venue.imageURL];
        //[self.imageView sd_setImageWithURL:self.voucher.deal.venue.imageURL];
    }
}

//- (void)setBeacon:(Voucher *)voucher
//{
//    [self view];
//    _voucher = voucher;
//    
//    if (self.voucher.deal) {
//        self.dealMode = YES;
//        [self.dealRedemptionViewController setDeal:self.voucher.deal];
//        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        NSLog(@"IMAGE URL: %@", self.voucher.deal.venue.imageURL);
//        [self.imageView sd_setImageWithURL:self.voucher.deal.venue.imageURL];
//    }
//
//    //let server know that user has seen this hotspot
//}

- (void)updateDealRedemptionInsets
{
    CGFloat topInset = CGRectGetMaxY(self.descriptionView.frame);
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = topInset;
    self.voucherRedemptionViewController.tableView.contentInset = insets;
}

//- (void)showPartialDescriptionViewAnimated:(BOOL)animated
//{
//    self.fullDescriptionViewShown = NO;
//    NSTimeInterval duration = animated ? 0.3 : 0.0;
//    [UIView animateWithDuration:duration animations:^{
//        CGRect frame = self.descriptionView.frame;
//        frame.origin.y = -CGRectGetMinY(self.chatTabButton.frame);
//        self.descriptionView.frame = frame;
//        [self updateDealRedemptionInsets];
//    }];
//}

#pragma mark - UIGestureRecognzierDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//#pragma mark - Keyboard
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    self.keyboardShown = YES;
//    [self showPartialDescriptionViewAnimated:YES];
//}

//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    self.keyboardShown = NO;
//}

//#pragma mark - Buttons
//
//- (void)tabButtonTouched:(UIButton *)sender
//{
//    //    if (self.fullDescriptionViewShown && sender.selected) {
//    //        [self showPartialDescriptionViewAnimated:YES];
//    //    }
//    //    else if (!self.fullDescriptionViewShown && sender.selected) {
//    //        [self showFullDescriptionViewAnimated:YES];
//    //    }
//    if (sender == self.chatTabButton) {
//        [self showChatAnimated:YES];
//        self.inviteButton.hidden = YES;
//    }
//    else if (sender == self.inviteTabButton) {
//        [self showInviteAnimated:YES];
//        self.inviteButton.hidden = NO;
//    }
//    else if (sender == self.dealButton) {
//        [self showDealAnimated:YES];
//        self.inviteButton.hidden = YES;
//    }
//    [self.beaconChatViewController dismissKeyboard];
//}


#pragma mark - SetBeaconViewControllerDelegate
- (void)setBeaconViewController:(SetBeaconViewController *)setBeaconViewController didUpdateBeacon:(Voucher *)voucher
{
    self.voucher = voucher;
    [self.navigationController popToViewController:self animated:YES];
}


-(NSMutableDictionary *)parseStringIntoTwoLines:(NSString *)originalString
{
    NSMutableDictionary *firstAndSecondLine = [[NSMutableDictionary alloc] init];
    NSArray *arrayOfStrings = [originalString componentsSeparatedByString:@" "];
    if ([arrayOfStrings count] == 1) {
        [firstAndSecondLine setObject:@"" forKey:@"firstLine"];
        [firstAndSecondLine setObject:originalString forKey:@"secondLine"];
    } else {
        NSMutableString *firstLine = [[NSMutableString alloc] init];
        NSMutableString *secondLine = [[NSMutableString alloc] init];
        NSInteger firstLineCharCount = 0;
        for (int i = 0; i < [arrayOfStrings count]; i++) {
            if ((firstLineCharCount + [arrayOfStrings[i] length] < 12 && i + 1 != [arrayOfStrings count]) || i == 0) {
                if ([firstLine  length] == 0) {
                    [firstLine appendString:arrayOfStrings[i]];
                } else {
                    [firstLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
                firstLineCharCount = firstLineCharCount + [arrayOfStrings[i] length];
            } else {
                if ([secondLine length] == 0) {
                    [secondLine appendString:arrayOfStrings[i]];
                } else {
                    [secondLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
            }
        }
        [firstAndSecondLine setObject:firstLine forKey:@"firstLine"];
        [firstAndSecondLine setObject:secondLine forKey:@"secondLine"];
    }
    
    return firstAndSecondLine;
}



@end