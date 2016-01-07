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

#import "RedemptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "NSDate+FormattedDate.h"
#import "UIButton+HSNavButton.h"
#import "UIImage+Resize.h"
#import "UIView+Shadow.h"
#import "DealRedemptionViewController.h"
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
#import "PaymentsViewController.h"
#import "DealStatus.h"
#import "NeedHelpExplanationPopupView.h"
#import "FaqViewController.h"

@interface RedemptionViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) DealRedemptionViewController *dealRedemptionViewController;
@property (strong, nonatomic) PaymentsViewController *paymentsViewController;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *imageViewGradient;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *descriptionLabelLineOne;
@property (strong, nonatomic) UILabel *descriptionLabelLineTwo;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIButton *inviteButton;
@property (strong, nonatomic) UIButton *feedbackButton;
@property (assign, nonatomic) BOOL fullDescriptionViewShown;
@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) BOOL promptShowing;
@property (assign, nonatomic) BOOL dealMode;
@property (assign, nonatomic) BOOL hasCheckedPayment;
@property (strong, nonatomic) FaqViewController *faqViewController;
@property (readonly) NSInteger photoContainer;
@property (readonly) NSInteger redemptionContainer;

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

@end

@implementation RedemptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showLoadingIndicator:) name:@"ShowLoadingInRedemptionView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideLoadingIndicator:) name:@"HideLoadingInRedemptionView" object:nil];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.feedbackButton = [[UIButton alloc] init];
    self.feedbackButton.size = CGSizeMake(25, 25);
    self.feedbackButton.layer.cornerRadius = 2;
    self.feedbackButton.layer.borderColor = [[UIColor unnormalizedColorWithRed:167 green:167 blue:167 alpha:255] CGColor];
    self.feedbackButton.layer.borderWidth = 1.0;
    [self.feedbackButton setTitle:@"NEED HELP?" forState:UIControlStateNormal];
    [self.feedbackButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.feedbackButton.titleLabel.font = [ThemeManager regularFontOfSize:10];
    [self.feedbackButton addTarget:self action:@selector(feedbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.feedbackButton];
    
    self.faqViewController = [[FaqViewController alloc] initForModal];
    self.hasCheckedPayment = NO;
    self.dealMode = NO;

}

- (void)refreshBeaconData
{
    if (!self.beacon) {
        return;
    }
    [[BeaconManager sharedManager] getBeaconWithID:self.beacon.beaconID success:^(Beacon *beacon) {
        self.beacon = beacon;
        if (self.beacon.deal) {
            [self.dealRedemptionViewController setBeacon:self.beacon];
        }
    } failure:nil];
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:self.beacon.deal.venue.name];
    self.deal = beacon.deal;
    self.dealStatus = beacon.userDealStatus;
    [self updateRedeemButtonAppearance];
    
    //self.beaconChatViewController.beacon = beacon;
    self.timeLabel.text = beacon.time.formattedTime;
    if (self.locationLabel.text) {
        //        self.directionsButton.hidden = NO;
        //        CGRect directionsButtonFrame = self.directionsButton.frame;
        CGFloat textWidth = [self.locationLabel.text sizeWithAttributes:@{NSFontAttributeName : self.locationLabel.font}].width;
        textWidth = MIN(textWidth, self.locationLabel.frame.size.width);
        //        directionsButtonFrame.origin.x = CGRectGetMinX(self.locationLabel.frame) + textWidth + 8;
        //        directionsButtonFrame.origin.y = CGRectGetMinY(self.locationLabel.frame) + 0.5*(self.locationLabel.frame.size.height - directionsButtonFrame.size.height);
        //        self.directionsButton.frame = directionsButtonFrame;
    }
    else {
        //        self.directionsButton.hidden = YES;
    }

    self.dealMode = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView sd_setImageWithURL:self.beacon.deal.venue.imageURL];
    NSLog(@"AUTH Boolean: %d", self.beacon.userDealStatus.paymentAuthorization);
    if (!self.beacon.userDealStatus.paymentAuthorization && !self.hasCheckedPayment) {
        [self initPaymentsViewControllerAndSetDeal];
        self.hasCheckedPayment = YES;
    }
    
    [self.tableView reloadData];
}


- (void)promptForCheckIn
{
    self.promptShowing = YES;
    self.openToInviteView = YES;
    //[self showInviteAnimated:YES];
    [[BeaconManager sharedManager] promptUserToCheckInToBeacon:self.beacon success:^(BOOL checkedIn) {
        self.promptShowing = NO;
        [self refreshBeaconData];
    } failure:^(NSError *error) {
        self.promptShowing = NO;
    }];
}

- (void)promptToInviteFriends
{
    self.promptShowing = YES;
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Cool" message:@"Want to invite more friends?"];
    [alertView bk_addButtonWithTitle:@"No thanks" handler:^{
        self.promptShowing = NO;
    }];
    [alertView bk_setCancelButtonWithTitle:@"Yeah!" handler:^{
        self.promptShowing = NO;
        [self inviteMoreFriends];
    }];
    [alertView show];
    [[AnalyticsManager sharedManager] setBeaconStatus:@"going" forSelf:YES];
}

- (void)redeemRewardItem
{
    NSLog(@"User Deal Status: %@", self.beacon.userDealStatus.dealStatusID);
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
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
    findFriendsViewController.delegate = self;
    NSMutableArray *inactives = [[NSMutableArray alloc] init];
    for (BeaconStatus *status in self.beacon.guestStatuses.allValues) {
        if (status.user) {
            [inactives addObject:status.user];
        }
        else if (status.contact) {
            [inactives addObject:status.contact];
        }
    }
    findFriendsViewController.inactiveContacts = inactives;
    findFriendsViewController.deal = self.beacon.deal;
    findFriendsViewController.textMoreFriends = YES;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

//#pragma mark - UIGestureRecognzierDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

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

- (void)join:(void (^)())didJoin
{
    [[BeaconManager sharedManager] confirmBeacon:self.beacon success:^{
        [self refreshBeaconData];
    } failure:nil];
    //self.joinButton.hidden = YES;
    self.inviteButton.hidden = NO;
    if (didJoin) {
        didJoin();
    }
}

- (void)inviteButtonTouched:(id)sender
{
    //[self enableVenmoButtonTouched];
    [self inviteMoreFriends];
}

- (void)imageViewTapped:(id)sender
{
    [self getDirectionsToBeacon];
}


#pragma mark - FindFriendsViewControllerDelegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts andMessage:(NSString *)message andDate:(NSDate *)date
{
    [self.navigationController popToViewController:self animated:YES];
    if (!contacts || !contacts.count) {
        return;
    }
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] inviteMoreContacts:contacts toBeacon:self.beacon withMessage:message success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self refreshBeaconData];
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again later" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    [[AnalyticsManager sharedManager] inviteToBeacon:contacts.count];
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
    modal.beacon = self.beacon;
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
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
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
        height = 190;
    } else {
        height = 300;
    };
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.photoContainer) {
        return [self getPhotoCell];
    } else {
        return [self getRedemptionCell];
    }
}

-(UITableViewCell *) getPhotoCell
{
    static NSString *CellIdentifier = @"photoCell";
    UITableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!photoCell) {
        photoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView *headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraIcon"]];
        headerIcon.height = 18;
        headerIcon.width = 18;
        headerIcon.x = 20;
        headerIcon.y = 15;
        [photoCell addSubview:headerIcon];
        
        UILabel *headerTitle = [[UILabel alloc] init];
        headerTitle.height = 20;
        headerTitle.width = 100;
        headerTitle.text = @"ADD PHOTO";
        headerTitle.textAlignment = NSTextAlignmentLeft;
        headerTitle.font = [ThemeManager boldFontOfSize:10];
        headerTitle.x = 42;
        headerTitle.y = 14;
        [photoCell addSubview:headerTitle];
        
        UIImageView *photoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addPhotoBox"]];
        photoView.centerX = self.view.width/2;
        photoView.userInteractionEnabled = YES;
        photoView.y = 40;
        
        UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
        photoTap.numberOfTapsRequired = 1;
        [photoView addGestureRecognizer:photoTap];
        
        [photoCell addSubview:photoView];
    }
    return photoCell;
}

-(void)photoTapped:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Want to add a photo?"];
    [actionSheet bk_addButtonWithTitle:@"Take a Photo" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet bk_addButtonWithTitle:@"Add From Library" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Not Now" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)source
{
    [[PhotoManager sharedManager] presentImagePickerForSourceType:source fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        if (image) {
            UIImage *scaledImage;
            CGFloat maxDimension = 720;
            if (image.size.width >= image.size.height) {
                scaledImage = [image scaledToSize:CGSizeMake(maxDimension, maxDimension*image.size.height/image.size.width)];
            }
            else {
                scaledImage = [image scaledToSize:CGSizeMake(maxDimension*image.size.width/image.size.height, maxDimension)];
            }
//            [self.beaconChatViewController createChatMessageWithImage:scaledImage];
            [[APIClient sharedClient] postImage:scaledImage forBeaconWithID:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            }];
        }
    }];
}

-(UITableViewCell *)getRedemptionCell
{
    static NSString *CellIdentifier = @"redemptionCell";
    UITableViewCell *redemptionCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!redemptionCell) {
        redemptionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.width - 40, 0.5)];
        topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
        [redemptionCell addSubview:topBorder];
        
        self.headerIcon = [[UIImageView alloc] init];
        self.headerIcon.height = 30;
        self.headerIcon.width = 30;
        self.headerIcon.centerX = self.view.width/2;
        self.headerIcon.y = 0;
        [redemptionCell addSubview:self.headerIcon];
        
        self.headerTitle = [[UILabel alloc] init];
        self.headerTitle.height = 20;
        self.headerTitle.width = self.tableView.width;
        self.headerTitle.textAlignment = NSTextAlignmentCenter;
        //self.headerTitle.centerX = self.tableView.width/2;
        self.headerTitle.font = [ThemeManager boldFontOfSize:11];
        self.headerTitle.y = 30;
        [redemptionCell addSubview:self.headerTitle];
        
        self.headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.width - 45, 50)];
        self.headerExplanationText.centerX = self.view.width/2;
        self.headerExplanationText.font = [ThemeManager lightFontOfSize:12];
        self.headerExplanationText.textAlignment = NSTextAlignmentCenter;
        self.headerExplanationText.numberOfLines = 2;
        [redemptionCell addSubview:self.headerExplanationText];
        
        self.inviteFriendsExplanation = [[UILabel alloc] initWithFrame:CGRectMake(0, 255, self.view.width - 50, 50)];
        self.inviteFriendsExplanation.centerX = self.view.width/2;
        self.inviteFriendsExplanation.font = [ThemeManager lightFontOfSize:12];
        self.inviteFriendsExplanation.textAlignment = NSTextAlignmentCenter;
        self.inviteFriendsExplanation.text = @"Tap below to text more friends to meet you here.";
        self.inviteFriendsExplanation.numberOfLines = 1;
        [redemptionCell addSubview:self.inviteFriendsExplanation];
        
        self.redeemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.redeemButton.y = 100;
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
        self.inviteFriendsButton.size = CGSizeMake(self.view.width - 50, 35);
        self.inviteFriendsButton.centerX = self.view.width/2;
        self.inviteFriendsButton.titleLabel.font = [ThemeManager boldFontOfSize:15];
        self.inviteFriendsButton.layer.cornerRadius = 4;
        self.inviteFriendsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
        self.inviteFriendsButton.titleLabel.textColor = [UIColor whiteColor];
        self.inviteFriendsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        footerView.backgroundColor = [UIColor whiteColor];
        [self.inviteFriendsButton setTitle:@"TEXT MORE FRIENDS" forState:UIControlStateNormal];
        self.inviteFriendsButton.y = 295;
        
        [redemptionCell addSubview:self.inviteFriendsButton];
        [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [redemptionCell addSubview:self.redeemButton];
        
        ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
        if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
            self.inviteFriendsButton.hidden = NO;
            self.inviteFriendsExplanation.hidden = NO;
        } else {
            self.inviteFriendsButton.hidden = YES;
            self.inviteFriendsExplanation.hidden = YES;
        }
    
    }
    return redemptionCell;
}

- (void)redeemButtonTouched:(id)sender
{
    if (self.dealStatus.paymentAuthorization) {
        if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This voucher has already been redeemed and can't be reused" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        } else {
            NSString *message;
            if (self.dealStatus.isRewardAuthorization) {
                message = [NSString stringWithFormat:@"Tap ‘CONFIRM’ and Hotspot will be charged $%@ for a %@. Don’t charge the customer for this drink.", self.deal.itemPrice, self.deal.itemName];
            } else {
                message = [NSString stringWithFormat:@"Tap ‘CONFIRM’ and the customer will be charged $%@ for a %@. They are paying through the Hotspot app, so don’t charge them for this drink.", self.deal.itemPrice, self.deal.itemName];
            }
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
                [self initPaymentsViewControllerAndSetDeal];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        }];
    }
}

- (void)redeemDeal
{
    //    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoadingInRedemptionView" object:self userInfo:nil];
    [[APIClient sharedClient] redeemDeal:self.deal success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [self refreshBeaconDataInDeal];
        NSString *dealStatus = responseObject[@"deal_status"];
        //NSLog(@"DealStatus: %@", dealStatus);
        self.dealStatus.dealStatus = dealStatus;
        [self updateRedeemButtonAppearance];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingInRedemptionView" object:self userInfo:nil];
        //        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingInRedemptionView" object:self userInfo:nil];
    }];
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
        itemNameText = [NSString stringWithFormat:@"%@", [self.deal.itemName uppercaseString]];
        venueNameText = [NSString stringWithFormat:@"@ %@", [self.deal.venue.name uppercaseString]];
        serverMessageText = @"SERVER ONLY: TAP TO REDEEM";
        accentColor = color;
        [self.headerIcon setImage:[UIImage imageNamed:@"redeemedIcon"]];
        self.headerTitle.text = @"SHOW VOUCHER TO SERVER";
        if (self.dealStatus.isRewardAuthorization) {
            self.headerExplanationText.text = [NSString stringWithFormat:@"When you order, have your server tap below to redeem. Hotspot will cover this round!"];
        } else {
            self.headerExplanationText.text = [NSString stringWithFormat:@"When you order, have your server tap below to redeem. You'll pay $%@ for your drink through the app.", self.deal.itemPrice];
        }
        
        [self.redeemButton setImage:[UIImage imageNamed:@"activeVoucher"] forState:UIControlStateNormal];
        [self.voucherIcon setImage:[UIImage imageNamed:@"fingerprintIcon"]];
    } else if ([self.dealStatus.dealStatus isEqualToString:kDealStatusRedeemed] && self.dealStatus.paymentAuthorization) {
        color = inactiveColor;
        backgroundColor = [UIColor colorWithRed:243/255. green:243/255. blue:243/255. alpha:1];
        voucherTitleText = @"VOUCHER REDEEMED";
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

- (void)promptToUseRewardItems
{
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Redeem Free Drink?" message:@"Do you want to pay for your drink or use one of your free drinks?"];
    [alertView bk_addButtonWithTitle:@"Use Free Drink" handler:^{
        [self redeemRewardItem];
    }];
    [alertView bk_addButtonWithTitle:@"Pay for Drink" handler:^{
        [self checkPaymentsOnFile];
    }];
    [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [alertView show];
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