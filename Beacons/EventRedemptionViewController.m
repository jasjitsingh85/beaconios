//
//  DealRedemptionTableViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 1/5/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

//
//  BeaconProfileViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/12/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "EventRedemptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "NSDate+FormattedDate.h"
#import "UIButton+HSNavButton.h"
#import "UIImage+Resize.h"
#import "UIView+Shadow.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "HSNavigationController.h"
#import "Beacon.h"
#import "Deal.h"
#import "Venue.h"
#import "Theme.h"
#import "User.h"
#import "BeaconManager.h"
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
#import "PaymentsViewController.h"
#import "DealStatus.h"
#import "NeedHelpExplanationPopupView.h"
#import "FaqViewController.h"
#import "TabTableView.h"
#import "TabItem.h"
#import "Tab.h"
#import "SponsoredEvent.h"
#import "TabViewController.h"
#import "EventChatViewController.h"
#import "VoucherViewController.h"
#import "SwipeViewController.h"
#import "DatingProfile.h"
#import "EnablePushPopupView.h"

@interface EventRedemptionViewController () <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) PaymentsViewController *paymentsViewController;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *imageViewGradient;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *descriptionLabelLineOne;
@property (strong, nonatomic) UILabel *descriptionLabelLineTwo;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIButton *feedbackButton;
@property (assign, nonatomic) BOOL fullDescriptionViewShown;
@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) BOOL promptShowing;
@property (assign, nonatomic) BOOL dealMode;
@property (assign, nonatomic) BOOL hasCheckedPayment;
@property (strong, nonatomic) FaqViewController *faqViewController;
@property (readonly) NSInteger photoContainer;
@property (readonly) NSInteger redemptionContainer;

@property (strong, nonatomic) UIImageView *photoView;
@property (assign, nonatomic) BOOL hasImage;
@property (assign, nonatomic) CGFloat imageHeight;
@property (strong, nonatomic) TabTableView *tabTableView;

@property (strong, nonatomic) Tab *tab;
@property (strong, nonatomic) NSArray *tabItems;

@property (strong, nonatomic) UIView *claimedTabView;
@property (strong, nonatomic) UIView *unclaimedTabView;

@property (strong, nonatomic) EventChatViewController *eventChatViewController;
@property (strong, nonatomic) VoucherViewController *voucherViewController;
@property (strong, nonatomic) SwipeViewController *swipeViewController;

@property (strong, nonatomic) UIButton *ticketButton;
@property (strong, nonatomic) UIButton *chatRoomButton;
@property (strong, nonatomic) UIButton *matchGameButton;

@property (strong, nonatomic) UIImageView *nub;

@property (strong, nonatomic) UIScrollView *activityScroll;

@property (assign, nonatomic) BOOL hasShownPushModal;
@property (strong, nonatomic) EnablePushPopupView *modal;

@property (assign, nonatomic) int page;

@end

@implementation EventRedemptionViewController
@synthesize activityScroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *textFriendsButton = [[UIButton alloc] init];
    [textFriendsButton setImageEdgeInsets:UIEdgeInsetsMake(2, 0, -2, 0)];
    textFriendsButton.size = CGSizeMake(28, 28);
    [textFriendsButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [textFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@""];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:textFriendsButton];
    
    self.faqViewController = [[FaqViewController alloc] initForModal];
    self.modal = [[EnablePushPopupView alloc] init];
    self.hasCheckedPayment = NO;
    self.dealMode = NO;
    self.hasShownPushModal = NO;
    
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 140)];
    buttonContainer.backgroundColor = [UIColor whiteColor];
    
    self.ticketButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.ticketButton.size = CGSizeMake(50, 50);
    self.ticketButton.centerX = self.view.width/6.0;
    self.ticketButton.y = 70;
    [self.ticketButton setImage:[UIImage imageNamed:@"ticketButtonUnselected"] forState:UIControlStateNormal];
    [self.ticketButton setImage:[UIImage imageNamed:@"ticketButtonSelected"] forState:UIControlStateSelected];
    [self.ticketButton addTarget:self action:@selector(ticketButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.ticketButton];
    
    UILabel *ticketLabel = [[UILabel alloc] init];
    ticketLabel.font = [ThemeManager mediumFontOfSize:8];
    ticketLabel.textColor = [UIColor blackColor];
    ticketLabel.text = @"TICKET";
    ticketLabel.width = self.view.width/3.0;
    ticketLabel.height = 20;
    ticketLabel.y = 117.5;
    ticketLabel.centerX = self.view.width/6.0;
    ticketLabel.textAlignment = NSTextAlignmentCenter;
    [buttonContainer addSubview:ticketLabel];
    
    self.chatRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chatRoomButton.size = CGSizeMake(50, 50);
    self.chatRoomButton.centerX = self.view.width/2.0;
    self.chatRoomButton.y = 70;
    [self.chatRoomButton setImage:[UIImage imageNamed:@"chatRoomUnselected"] forState:UIControlStateNormal];
    [self.chatRoomButton setImage:[UIImage imageNamed:@"chatRoomSelected"] forState:UIControlStateSelected];
    [self.chatRoomButton addTarget:self action:@selector(chatRoomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.chatRoomButton];
    
    UILabel *chatRoomLabel = [[UILabel alloc] init];
    chatRoomLabel.font = [ThemeManager mediumFontOfSize:8];
    chatRoomLabel.textColor = [UIColor blackColor];
    chatRoomLabel.text = @"CHATROOM";
    chatRoomLabel.width = self.view.width/3.0;
    chatRoomLabel.height = 20;
    chatRoomLabel.y = 117.5;
    chatRoomLabel.centerX = self.view.width/2.0;
    chatRoomLabel.textAlignment = NSTextAlignmentCenter;
    [buttonContainer addSubview:chatRoomLabel];
    
    self.matchGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.matchGameButton.size = CGSizeMake(50, 50);
    self.matchGameButton.centerX = self.view.width - self.view.width/6.0;
    self.matchGameButton.y = 70;
    [self.matchGameButton setImage:[UIImage imageNamed:@"matchUnselected"] forState:UIControlStateNormal];
    [self.matchGameButton setImage:[UIImage imageNamed:@"matchSelected"] forState:UIControlStateSelected];
    [self.matchGameButton addTarget:self action:@selector(matchGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.matchGameButton];
    
    UILabel *matchLabel = [[UILabel alloc] init];
    matchLabel.font = [ThemeManager mediumFontOfSize:8];
    matchLabel.textColor = [UIColor blackColor];
    matchLabel.text = @"SWIPE & MATCH";
    matchLabel.width = self.view.width/3.0;
    matchLabel.height = 20;
    matchLabel.y = 117.5;
    matchLabel.centerX = self.view.width - self.view.width/6.0;
    matchLabel.textAlignment = NSTextAlignmentCenter;
    [buttonContainer addSubview:matchLabel];
    
    self.activityScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 140, self.view.width, self.view.height - 140)];
    self.activityScroll.backgroundColor = [UIColor whiteColor];
    self.activityScroll.pagingEnabled = YES;
    self.activityScroll.showsHorizontalScrollIndicator = NO;
    self.activityScroll.contentSize = CGSizeMake(self.view.width * 3, self.view.height - 140);
    self.activityScroll.delegate = self;
    
    
//    [self.activityScroll setUserInteractionEnabled:YES];
//    [self.view addGestureRecognizer:self.activityScroll.panGestureRecognizer];
    
    self.voucherViewController = [[VoucherViewController alloc] init];
    [self addChildViewController:self.voucherViewController];
//    self.voucherViewController.view.bounds = CGRectMake(0, 0, self.view.width, self.view.height);
    [self.activityScroll addSubview:self.voucherViewController.view];
    [self.voucherViewController didMoveToParentViewController:self];
    
    self.eventChatViewController = [[EventChatViewController alloc] init];
    [self addChildViewController:self.eventChatViewController];
    self.eventChatViewController.view.bounds = CGRectMake(0, 0, self.view.width, self.view.height);
    self.eventChatViewController.view.x = self.view.width;
    [self.activityScroll addSubview:self.eventChatViewController.view];
    [self.eventChatViewController didMoveToParentViewController:self];
    
    self.swipeViewController = [[SwipeViewController alloc] init];
    [self addChildViewController:self.swipeViewController];
    self.swipeViewController.view.bounds = CGRectMake(0, 0, self.view.width, self.view.height);
    self.swipeViewController.view.x = self.view.width * 2;
    [self.activityScroll addSubview:self.swipeViewController.view];
    [self.swipeViewController didMoveToParentViewController:self];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 139, self.view.width, 1)];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:205 green:205 blue:205 alpha:255];
    [buttonContainer addSubview:topBorder];
    
    self.nub = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nubForBorder"]];
    self.nub.centerX = self.view.width/6.0;
    self.nub.y = 135;
    [buttonContainer addSubview:self.nub];
    [self.view addSubview:buttonContainer];
    
    [self loadInitialView];

}


-(void)viewWillAppear:(BOOL)animated
{
    [self refreshSponsoredEventData:self.sponsoredEvent.eventID];
}

-(void)ticketButtonTapped:(id)sender
{
    [self updatePage:0];
    [self scrollToPage:0];
}

-(void)chatRoomButtonTapped:(id)sender
{
    [self updatePage:1];
    [self scrollToPage:1];
}

-(void)matchGameButtonTapped:(id)sender
{
    [self updatePage:2];
    [self scrollToPage:2];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showLoadingIndicator:) name:kStartLoadingForEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideLoadingIndicator:) name:kEndLoadingForEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showFaq:) name:@"ShowFaq" object:nil];
    }
    return self;
}

- (void) initPaymentsViewControllerAndSetDeal
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getClientToken:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *clientToken = responseObject[@"client_token"];
        self.paymentsViewController = [[PaymentsViewController alloc] initWithClientToken:clientToken];
        self.paymentsViewController.redemptionViewController = self;
        self.paymentsViewController.onlyAddPayment = NO;
        self.paymentsViewController.beaconID = self.beacon.beaconID;
        [self addChildViewController:self.paymentsViewController];
        //[self.view addSubview:self.paymentsViewController.view];
        self.paymentsViewController.view.frame = self.view.bounds;
        
        [[APIClient sharedClient] getRewardsItems:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *rewardItemsString = responseObject[@"number_of_reward_items"];
            if ([rewardItemsString intValue] > 0 && self.beacon.deal.rewardEligibility) {
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                [self redeemRewardItem];
                //                    [self promptToUseRewardItems];
            } else {
                [self checkPaymentsOnFile];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.activityScroll.frame.size.width;
    int page = floor((self.activityScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (sender.isDecelerating) {
        [self updatePage:page];
    }
}

-(void)updatePage:(int)page
{
    [self updateButtons:page];
    [self animateNubToPage:page];
}


-(void)scrollToPage:(int)page
{
    [self.activityScroll setContentOffset:CGPointMake(self.activityScroll.frame.size.width*page, 0.0f) animated:YES];
}

-(void)animateNubToPage:(int)page
{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             if (page == 0) {
                 self.nub.centerX = self.view.width/6.0;
             } else if (page == 1) {
                 self.nub.centerX = self.view.width/2.0;
             } else if (page == 2) {
                 self.nub.centerX = self.view.width - self.view.width/6.0;
             }
         }
                         completion:^(BOOL finished)
         {

         }];
}


-(void)updateButtons:(int)page
{
    if (page == 0) {
        self.page = 0;
        [self makeTicketActive];
        [self makeChatroomUnselected];
        [self makeMatchUnselected];
    } else if (page == 1) {
        self.page = 1;
        [self makeTicketUnselected];
        [self makeChatroomActive];
        [self makeMatchUnselected];
        [self checkPushPermissions];
    } else if (page == 2) {
        self.page = 2;
        [self makeTicketUnselected];
        [self makeChatroomUnselected];
        [self makeMatchActive];
        [self checkPushPermissions];
    }
}

-(void)checkPushPermissions
{
    if (!self.hasShownPushModal && ![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [self.modal show];
        self.hasShownPushModal = YES;
    }
}

-(void)makeTicketActive
{
    if (![self.ticketButton isSelected]) {
        [self.ticketButton setSelected:YES];
    }
}

-(void)makeTicketUnselected
{
    if ([self.ticketButton isSelected]) {
        [self.ticketButton setSelected:NO];
    }
}

-(void)makeChatroomActive
{
    if (![self.chatRoomButton isSelected]) {
        [self.chatRoomButton setSelected:YES];
    }
}

-(void)makeChatroomUnselected
{
    if ([self.chatRoomButton isSelected]) {
        [self.chatRoomButton setSelected:NO];
    }
}

-(void)makeMatchActive
{
    if (![self.matchGameButton isSelected]) {
        [self.matchGameButton setSelected:YES];
    }
}

-(void)makeMatchUnselected
{
    if ([self.matchGameButton isSelected]) {
        [self.matchGameButton setSelected:NO];
    }
}

- (void) refreshDeal
{
    [self refreshBeaconData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkPaymentsOnFile
{
    [[APIClient sharedClient] checkIfPaymentOnFile:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *dismiss_payment_modal_string = responseObject[@"dismiss_payment_modal"];
        BOOL dismiss_payment_modal = [dismiss_payment_modal_string boolValue];
        if (!dismiss_payment_modal && self.beacon.deal.inAppPayment) {
            [self.paymentsViewController openPaymentModalWithDeal:self.beacon.deal];
        }
        [self refreshDeal];
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

-(void)setSponsoredEvent:(SponsoredEvent *)sponsoredEvent
{
    _sponsoredEvent = sponsoredEvent;
    
//    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:self.sponsoredEvent.venue.name];
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:[NSString stringWithFormat:@"%@ at %@", self.sponsoredEvent.itemName, self.sponsoredEvent.venue.name]];
    
    self.voucherViewController.sponsoredEvent = self.sponsoredEvent;
    self.eventChatViewController.sponsoredEvent = self.sponsoredEvent;
    self.swipeViewController.sponsoredEvent = self.sponsoredEvent;
    
//    [self loadSwipeView];
    
    [self.view addSubview:self.activityScroll];
}

//-(void) loadSwipeView
//{
//    [[APIClient sharedClient] getDatingData:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject[@"dating_profile"] isEmpty]) {
//            self.swipeViewController.datingProfile = nil;
//        } else {
//            NSDictionary *datingProfile = responseObject[@"dating_profile"][0];
//            self.swipeViewController.datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfile];
//            NSMutableArray *datingQueueArray = [[NSMutableArray alloc] init];
//            for (NSDictionary *datingProfileJSON in responseObject[@"dating_queue"]) {
//                DatingProfile *datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfileJSON];
//                [datingQueueArray addObject:datingProfile];
//            }
//            self.swipeViewController.datingQueue = datingQueueArray;
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"FAILED");
//    }];
//}

-(void)loadInitialView
{
    if (self.openToChatRoom || [self.sponsoredEvent.eventStatus.status isEqualToString:@"R"]) {
        [self updateButtons:1];
        [self.activityScroll setContentOffset:CGPointMake(self.activityScroll.frame.size.width*1, 0.0f) animated:NO];
        self.nub.centerX = self.view.width/2.0;
    } else {
        [self updateButtons:0];
        [self.activityScroll setContentOffset:CGPointMake(self.activityScroll.frame.size.width*0, 0.0f) animated:NO];
        self.nub.centerX = self.view.width/6.0;
    }
}

-(void)refreshSponsoredEventData:(NSNumber *)eventID
{
    if (!self.sponsoredEvent) {
        return;
    }
    
    [[APIClient sharedClient] getSponsoredEvent:eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SponsoredEvent *sponsoredEvent = [[SponsoredEvent alloc] initWithDictionary:responseObject[@"sponsored_event"]];
        [self setSponsoredEvent:sponsoredEvent];
        self.voucherViewController.sponsoredEvent = sponsoredEvent;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed");
    }];
}

- (void)refreshBeaconData
{
    if (!self.beacon) {
        return;
    }
    
    [[BeaconManager sharedManager] getBeaconWithID:self.beacon.beaconID success:^(Beacon *beacon) {
        self.beacon = beacon;
//        if (self.beacon.deal) {
//            [self setBeacon:self.beacon];
//        }
    } failure:nil];
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    
//    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:self.beacon.deal.venue.name];
    self.deal = beacon.deal;
    self.dealStatus = beacon.userDealStatus;
    
//    [self showVoucherView];
    
//    if (beacon.deal.venue.hasPosIntegration) {
//        [self showPosIntegrationView];
//           [self refreshTab];
//    } else {
//        [self showVoucherView];
//    }
    
//    if (self.beacon.imageURL) {
//        [self downloadImageAndUpdate];
//    }

//    self.eventChatViewController.beacon = self.beacon;
    
    self.dealMode = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView sd_setImageWithURL:self.beacon.deal.venue.imageURL];
    if (!self.beacon.userDealStatus.paymentAuthorization && !self.hasCheckedPayment) {
        [self initPaymentsViewControllerAndSetDeal];
        self.hasCheckedPayment = YES;
    }
    
    [self.tableView reloadData];
}

//-(void)showPosIntegrationView
//{
//    [self updatePosInfo];
//}

//-(void)showVoucherView
//{
//    [self updateVoucherInfo];
//}

//-(void)updatePosInfo
//{
//    self.headerTitle.text = @"TAB SUMMARY";
//    self.headerExplanationText.text = @"Order normally from the waiter. Click 'REVIEW AND PAY TAB' to review your tab and close out.";
//}
//
//-(void)downloadImageAndUpdate
//{
//    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    if (self.sponsoredEvent) {
//        [manager downloadImageWithURL:self.sponsoredEvent.venue.imageURL
//                              options:0
//                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                 // progression tracking code
//                             }
//                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                if (image) {
//                                    [self updateImage:image];
//                                }
//                                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//                            }];
//    } else {
//        [manager downloadImageWithURL:self.beacon.imageURL
//                              options:0
//                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                 // progression tracking code
//                             }
//                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                if (image) {
//                                    [self updateImage:image];
//                                }
//                                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//                            }];
//    }
//}


//- (void)promptForCheckIn
//{
//    self.promptShowing = YES;
//    self.openToInviteView = YES;
//    //[self showInviteAnimated:YES];
//    [[BeaconManager sharedManager] promptUserToCheckInToBeacon:self.beacon success:^(BOOL checkedIn) {
//        self.promptShowing = NO;
//        [self refreshBeaconData];
//    } failure:^(NSError *error) {
//        self.promptShowing = NO;
//    }];
//}

//- (void)promptToInviteFriends
//{
//    self.promptShowing = YES;
//    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Cool" message:@"Want to invite more friends?"];
//    [alertView bk_addButtonWithTitle:@"No thanks" handler:^{
//        self.promptShowing = NO;
//    }];
//    [alertView bk_setCancelButtonWithTitle:@"Yeah!" handler:^{
//        self.promptShowing = NO;
//        [self inviteMoreFriends];
//    }];
//    [alertView show];
//    [[AnalyticsManager sharedManager] setBeaconStatus:@"going" forSelf:YES];
//}

- (void)redeemRewardItem
{
    [[APIClient sharedClient] redeemRewardItem:self.beacon.userDealStatus.dealStatusID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self refreshDeal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Redeem Reward Failed");
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

- (void)getDirectionsToBeacon
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Get Directions"];
    [actionSheet bk_addButtonWithTitle:@"Google Maps" handler:^{
        [Utilities launchGoogleMapsDirectionsToCoordinate:self.beacon.coordinate addressDictionary:nil destinationName:self.beacon.beaconDescription];
    }];
    [actionSheet bk_addButtonWithTitle:@"Apple Maps" handler:^{
        [Utilities launchAppleMapsDirectionsToCoordinate:self.beacon.coordinate addressDictionary:nil destinationName:self.beacon.beaconDescription];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Nevermind" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)inviteMoreFriends
{
    MFMessageComposeViewController *smsModal = [[MFMessageComposeViewController alloc] init];
    smsModal.messageComposeDelegate = self;
    if (self.hasImage) {
        NSData *imgData = UIImagePNGRepresentation(self.photoView.image);
        [smsModal addAttachmentData:imgData typeIdentifier:@"public.data" filename:@"image.png"];
    }
    NSString *smsMessage;
    if (self.sponsoredEvent) {
        smsMessage = [NSString stringWithFormat:@"I’m at the %@ event at %@ - you should come! Here's the link: %@", self.sponsoredEvent.itemName, self.sponsoredEvent.venue.name, self.sponsoredEvent.websiteURL];
    } else {
        smsMessage = [NSString stringWithFormat:@"I’m at %@ getting a $%@ %@ with Hotspot -- you should come!", self.deal.venue.name, self.deal.itemPrice, self.deal.itemName];
    }

    smsModal.body = smsMessage;
    [self presentViewController:smsModal animated:YES completion:nil];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardShown = YES;
    //[self showPartialDescriptionViewAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardShown = NO;
}

//- (void)join:(void (^)())didJoin
//{
//    [[BeaconManager sharedManager] confirmBeacon:self.beacon success:^{
//        [self refreshBeaconData];
//    } failure:nil];
//
//    if (didJoin) {
//        didJoin();
//    }
//}

- (void)inviteButtonTouched:(id)sender
{
    [self inviteMoreFriends];
}

- (void)imageViewTapped:(id)sender
{
    [self getDirectionsToBeacon];
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

- (void) feedbackButtonTouched:(id)sender
{
    NeedHelpExplanationPopupView *modal = [[NeedHelpExplanationPopupView alloc] init];
    if (self.sponsoredEvent) {
        modal.sponsoredEvent = self.sponsoredEvent;
    } else {
         modal.beacon = self.beacon;
    }
    [modal show];
    
    //    [self feedbackDeal];
}

- (void)feedbackDeal
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] feedbackDeal:self.beacon.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *feedbackStatus = responseObject[@"feedback_status"];
        self.beacon.userDealStatus.feedback = [feedbackStatus boolValue];
        [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Someone from Hotspot will be in touch very soon to resolve the issue." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self updateFeedbackButtonAppearance];
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:nil];
}

- (void)updateFeedbackButtonAppearance
{
    self.feedbackButton.size = CGSizeMake(100, 25);
    [self.feedbackButton setTitle:@"ISSUE REPORTED" forState:UIControlStateNormal];
    
}

-(void)showLoadingIndicator:(id)sender
{
    if (self.page != 0) {
         [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    }
}

-(void)hideLoadingIndicator:(id)sender
{
    [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
}

-(void)showFaq:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.faqViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

-(NSInteger)photoContainer
{
    return 0;
}

-(NSInteger) redemptionContainer {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.row == self.photoContainer) {
        height = self.imageHeight + 75;
    } else {
        height = 300;
    };
    
    return height;
}

-(void)refreshBeaconDataInDeal
{
    [[BeaconManager sharedManager] getBeaconWithID:self.beacon.beaconID success:^(Beacon *beacon) {
        [self setBeacon:beacon];
    } failure:nil];
}

- (void) inviteFriendsButtonTouched:(id)sender
{
    [self inviteMoreFriends];
}


@end