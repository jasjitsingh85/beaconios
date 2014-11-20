//
//  BeaconProfileViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/12/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "NSDate+FormattedDate.h"
#import "UIButton+HSNavButton.h"
#import "UIImage+Resize.h"
#import "UIView+Shadow.h"
#import "BeaconChatViewController.h"
#import "InviteListViewController.h"
#import "DealRedemptionViewController.h"
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
#import "BeaconMapSnapshotImageView.h"

@interface BeaconProfileViewController () <FindFriendsViewControllerDelegate, ChatViewControllerDelegate, InviteListViewControllerDelegate, SetBeaconViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) BeaconChatViewController *beaconChatViewController;
@property (strong, nonatomic) InviteListViewController *inviteListViewController;
@property (strong, nonatomic) DealRedemptionViewController *dealRedemptionViewController;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) BeaconMapSnapshotImageView *imageView;
@property (strong, nonatomic) UIView *imageViewGradient;
@property (strong, nonatomic) BounceButton *chatTabButton;
@property (strong, nonatomic) BounceButton *inviteTabButton;
@property (strong, nonatomic) BounceButton *dealButton;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *invitedLabel;
@property (strong, nonatomic) UIButton *joinButton;
@property (strong, nonatomic) UIButton *inviteButton;
@property (strong, nonatomic) UIButton *directionsButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIView *addPictureView;
@property (assign, nonatomic) BOOL fullDescriptionViewShown;
@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) BOOL promptShowing;
@property (assign, nonatomic) BOOL dealMode;

@end

@implementation BeaconProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.beaconChatViewController = [[BeaconChatViewController alloc] init];
        self.beaconChatViewController.chatViewControllerDelegate = self;
        self.inviteListViewController = [[InviteListViewController alloc] init];
        self.inviteListViewController.delegate = self;
        self.dealRedemptionViewController = [[DealRedemptionViewController alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    }
    return self;
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
    
    [self addChildViewController:self.dealRedemptionViewController];
    [self.view addSubview:self.dealRedemptionViewController.view];
    self.dealRedemptionViewController.view.frame = self.view.bounds;
    self.dealRedemptionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.beaconChatViewController];
    [self.view addSubview:self.beaconChatViewController.view];
    self.beaconChatViewController.view.frame = self.view.bounds;
    self.beaconChatViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.beaconChatViewController.cameraButton addTarget:self action:@selector(chatCameraButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.beaconChatViewController.tableView.backgroundColor = [UIColor   whiteColor];
    self.beaconChatViewController.textViewContainer.backgroundColor = [UIColor clearColor];
    self.beaconChatViewController.textViewContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.beaconChatViewController.textViewContainer setShadowWithColor:[UIColor whiteColor] opacity:1 radius:5.0 offset:CGSizeMake(0, 2) shouldDrawPath:YES];
    
    [self addChildViewController:self.inviteListViewController];
    [self.view addSubview:self.inviteListViewController.view];
    self.inviteListViewController.view.frame = self.view.bounds;
    self.inviteListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.inviteListViewController.view.backgroundColor = [UIColor whiteColor];
    
    self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
    self.descriptionView.backgroundColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    [self.descriptionView setShadowWithColor:[UIColor whiteColor] opacity:0.7 radius:5.0 offset:CGSizeMake(0, 10) shouldDrawPath:YES];
    [self.view addSubview:self.descriptionView];
    self.fullDescriptionViewShown = YES;
    
    self.imageView = [[BeaconMapSnapshotImageView alloc] initWithFrame:CGRectMake(0, 0, self.descriptionView.frame.size.width, 124)];
    self.imageView.placeholder = [UIImage imageNamed:@"mapPlaceholder"];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    imageTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:imageTap];
    self.imageView.userInteractionEnabled = YES;
    [self.descriptionView addSubview:self.imageView];
    [self updateChatDesiredInsets];
    
    self.chatTabButton = [BounceButton buttonWithType:UIButtonTypeCustom];
    [self.chatTabButton setImage:[UIImage imageNamed:@"chatButtonNormal"] forState:UIControlStateNormal];
    [self.chatTabButton setImage:[UIImage imageNamed:@"chatButtonSelected"] forState:UIControlStateSelected];
    [self.chatTabButton addTarget:self action:@selector(tabButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.chatTabButton];
    self.chatTabButton.selected = YES;
    
    self.inviteTabButton = [BounceButton buttonWithType:UIButtonTypeCustom];
    [self.inviteTabButton setImage:[UIImage imageNamed:@"invitedButtonNormal"] forState:UIControlStateNormal];
    [self.inviteTabButton setImage:[UIImage imageNamed:@"invitedButtonSelected"] forState:UIControlStateSelected];
    [self.inviteTabButton addTarget:self action:@selector(tabButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.inviteTabButton];
    
    self.dealButton = [BounceButton buttonWithType:UIButtonTypeCustom];
    [self.dealButton setImage:[UIImage imageNamed:@"dealButtonNormal"] forState:UIControlStateNormal];
    [self.dealButton setImage:[UIImage imageNamed:@"dealButtonSelected"] forState:UIControlStateSelected];
    [self.dealButton addTarget:self action:@selector(tabButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.dealMode = NO;
    
    
    //    UIView *verticalDivider = [[UIView alloc] init];
    //    CGRect verticalDividerFrame;
    //    verticalDividerFrame.size = CGSizeMake(1, 45);
    //    verticalDividerFrame.origin.x = 0.5*self.descriptionView.frame.size.width - 0.5*verticalDividerFrame.size.width;
    //    verticalDividerFrame.origin.y = self.descriptionView.frame.size.height - verticalDividerFrame.size.height;
    //    verticalDivider.frame = verticalDividerFrame;
    //    verticalDivider.backgroundColor = [UIColor whiteColor];
    //    [self.descriptionView addSubview:verticalDivider];
    
    
    self.imageViewGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundGradient"]];
    CGRect backgroundGradientFrame = self.imageViewGradient.frame;
    backgroundGradientFrame.origin.y = self.imageView.frame.size.height - backgroundGradientFrame.size.height;
    self.imageViewGradient.frame = backgroundGradientFrame;
    [self.imageView addSubview:self.imageViewGradient];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 72, 214, 23)];
    self.timeLabel.font = [ThemeManager lightFontOfSize:1.3*17];
    [self.timeLabel setShadowWithColor:[UIColor blackColor] opacity:0.9 radius:1.0 offset:CGSizeMake(0, 1.0) shouldDrawPath:NO];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.imageView addSubview:self.timeLabel];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 94, 264, 25)];
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.font = [ThemeManager lightFontOfSize:1.3*17];
    [self.descriptionLabel setShadowWithColor:[UIColor blackColor] opacity:0.7 radius:1.0 offset:CGSizeMake(0, 1.0) shouldDrawPath:NO];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    [self.imageView addSubview:self.descriptionLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 132, 160, 14)];
    self.locationLabel.font = [ThemeManager regularFontOfSize:13];
    self.locationLabel.textColor = [UIColor whiteColor];
    [self.descriptionView addSubview:self.locationLabel];
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon)];
    locationTap.numberOfTapsRequired = 1;
    [self.locationLabel addGestureRecognizer:locationTap];
    self.locationLabel.userInteractionEnabled = YES;
    
    self.invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 158, 194, 14)];
    self.invitedLabel.font = [ThemeManager regularFontOfSize:13];
    self.invitedLabel.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *invitedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteLabelTouched:)];
    invitedTap.numberOfTapsRequired = YES;
    [self.invitedLabel addGestureRecognizer:invitedTap];
    self.invitedLabel.userInteractionEnabled = YES;
    [self.descriptionView addSubview:self.invitedLabel];
    
    self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.joinButton.frame = CGRectMake(226, 139, 73, 31);
    [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
    [self.joinButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.joinButton.backgroundColor = [UIColor whiteColor];
    self.joinButton.layer.cornerRadius = 4;
    [self.joinButton addTarget:self action:@selector(joinButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.joinButton];
    
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inviteButton.frame = self.joinButton.frame;
    [self.inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    [self.inviteButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.inviteButton.backgroundColor = [UIColor whiteColor];
    self.inviteButton.layer.cornerRadius = 4;
    [self.inviteButton addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.inviteButton];
    
    self.directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *directionsImage = [UIImage imageNamed:@"directionsArrow"];
    CGRect directionsButtonFrame = CGRectZero;
    directionsButtonFrame.size = directionsImage.size;
    self.directionsButton.frame = directionsButtonFrame;
    [self.directionsButton setImage:directionsImage forState:UIControlStateNormal];
    [self.directionsButton addTarget:self action:@selector(getDirectionsToBeacon) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.directionsButton];
    
    self.editButton = [UIButton navButtonWithTitle:@"Edit"];
    [self.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UISwipeGestureRecognizer* swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionViewSwipedDown:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDownGestureRecognizer.numberOfTouchesRequired = 1;
    [self.descriptionView addGestureRecognizer:swipeDownGestureRecognizer];
    swipeDownGestureRecognizer.delegate = self;
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionViewSwipedUp:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.descriptionView addGestureRecognizer:swipeUpGestureRecognizer];
    swipeUpGestureRecognizer.delegate = self;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:titleImage]];
    
    if (self.beacon) {
        self.editButton.hidden = !self.beacon.isUserBeacon;
    }
    
    if (self.openToInviteView) {
        self.dealButton.selected = NO;
        self.chatTabButton.selected = NO;
        self.inviteTabButton.selected = YES;
        [self showInviteAnimated:NO];
    }
    else if (self.openToDealView) {
        self.dealButton.selected = YES;
        self.chatTabButton.selected = NO;
        self.inviteButton.selected = YES;
        [self showDealAnimated:YES];
    }
    else {
        self.dealButton.selected = NO;
        self.chatTabButton.selected = YES;
        self.inviteTabButton.selected = NO;
        [self showChatAnimated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateInviteListInsets];
    [self updateChatDesiredInsets];
    [self updateDealRedemptionInsets];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

- (void)setDealMode:(BOOL)dealMode
{
    [self view];
    _dealMode = dealMode;
    if (dealMode) {
        CGSize buttonSize = CGSizeMake(self.descriptionView.width/3.0, 42);
        self.dealButton.size = buttonSize;
        self.dealButton.bottom = self.descriptionView.height;
        [self.descriptionView addSubview:self.dealButton];
        
        self.chatTabButton.size = buttonSize;
        self.chatTabButton.x = self.dealButton.right;
        self.chatTabButton.bottom = self.descriptionView.height;
        [self.descriptionView addSubview:self.dealButton];
        
        self.inviteTabButton.size = buttonSize;
        self.inviteTabButton.x = self.chatTabButton.right;
        self.inviteTabButton.bottom = self.descriptionView.height;
        [self.descriptionView addSubview:self.inviteTabButton];
    }
    else {
        CGRect chatTabButtonFrame;
        chatTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
        chatTabButtonFrame.origin = CGPointMake(0, self.descriptionView.frame.size.height - chatTabButtonFrame.size.height);
        self.chatTabButton.frame = chatTabButtonFrame;
        [self.descriptionView addSubview:self.chatTabButton];
        
        CGRect inviteTabButtonFrame;
        inviteTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
        inviteTabButtonFrame.origin = CGPointMake(CGRectGetMaxX(self.chatTabButton.frame), self.descriptionView.frame.size.height - inviteTabButtonFrame.size.height);
        self.inviteTabButton.frame = inviteTabButtonFrame;
        [self.descriptionView addSubview:self.inviteTabButton];
        [self.dealButton removeFromSuperview];
    }
}

- (void)refreshBeaconData
{
    if (!self.beacon) {
        return;
    }
    [[BeaconManager sharedManager] getBeaconWithID:self.beacon.beaconID success:^(Beacon *beacon) {
        self.beacon = beacon;
        if (self.beacon.deal) {
            [self showDealAnimated:NO];
        }
    } failure:nil];
    [self.beaconChatViewController reloadMessagesFromServerCompletion:nil];
}

- (void)setBeacon:(Beacon *)beacon
{
    [self view];
    _beacon = beacon;
    self.beaconChatViewController.beacon = beacon;
    self.timeLabel.text = beacon.time.shortFormattedDate;
    self.descriptionLabel.text = beacon.beaconDescription;
    if (beacon.address) {
        self.locationLabel.attributedText = [[NSAttributedString alloc] initWithString:beacon.address
                                                                            attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
    }
    if (self.locationLabel.text) {
        self.directionsButton.hidden = NO;
        CGRect directionsButtonFrame = self.directionsButton.frame;
        CGFloat textWidth = [self.locationLabel.text sizeWithAttributes:@{NSFontAttributeName : self.locationLabel.font}].width;
        textWidth = MIN(textWidth, self.locationLabel.frame.size.width);
        directionsButtonFrame.origin.x = CGRectGetMinX(self.locationLabel.frame) + textWidth + 8;
        directionsButtonFrame.origin.y = CGRectGetMinY(self.locationLabel.frame) + 0.5*(self.locationLabel.frame.size.height - directionsButtonFrame.size.height);
        self.directionsButton.frame = directionsButtonFrame;
    }
    else {
        self.directionsButton.hidden = YES;
    }
    [self updateInvitedLabel];
    
    self.inviteListViewController.beaconStatuses = beacon.guestStatuses.allValues;
    
    self.joinButton.hidden = beacon.userAttending;
    self.inviteButton.hidden = !beacon.userAttending;
    self.editButton.hidden = !beacon.isUserBeacon;
    
    if (beacon.deal) {
        self.dealMode = YES;
        [self.dealRedemptionViewController setDeal:beacon.deal andDealStatus:beacon.userDealStatus];
        self.imageView.mapDisabled = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView setImageWithURL:beacon.deal.venue.imageURL];
    }
    else {
        self.imageView.region = MKCoordinateRegionMakeWithDistance(beacon.coordinate, 800, 1500);
        self.imageView.beacon = beacon;
        self.imageViewGradient.hidden = NO;
    }
    //let server know that user has seen this hotspot
    BOOL hasData = beacon.beaconDescription != nil;
    if (hasData) {
        [[APIClient sharedClient] markBeaconAsSeen:beacon success:^(AFHTTPRequestOperation *operation, id responseObject) {
            BOOL showPrompt = [responseObject[@"show_prompt"] boolValue];
            if (showPrompt && !beacon.isUserBeacon && !self.promptShowing) {
                jadispatch_main_qeue(^{
                    [self promptForGoing];
                });
            }
        } failure:nil];
    }
}


- (void)promptForGoing
{
    self.promptShowing = YES;
    NSString *inviteText = [NSString stringWithFormat:@"%@: %@ \n%@ @ %@ \n\nAre you coming?", self.beacon.creator.firstName, self.beacon.beaconDescription, self.beacon.time.fullFormattedDate, self.beacon.address];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"RSVP" message:inviteText];
    [alertView bk_addButtonWithTitle:@"More info" handler:^{
        self.promptShowing = NO;
    }];
    [alertView bk_setCancelButtonWithTitle:@"Yes" handler:^{
        self.promptShowing = NO;
        [self join:nil];
    }];
    [alertView show];
}

- (void)promptForCheckIn
{
    self.promptShowing = YES;
    self.openToInviteView = YES;
    [self showInviteAnimated:YES];
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

- (void)updateInvitedLabel
{
    NSString *creatorText = [self.beacon.creator firstName];
    NSString *otherText;
    if (self.beacon.guestStatuses && self.beacon.guestStatuses.count > 1) {
        NSInteger otherCount = self.beacon.guestStatuses.count - 1;
        NSString *other = otherCount == 1 ? @"other..." : @"others...";
        otherText = [NSString stringWithFormat:@"and %d %@", otherCount, other];
    }
    if (otherText) {
        self.invitedLabel.text = [NSString stringWithFormat:@"%@ %@", creatorText, otherText];
    }
    else {
        self.invitedLabel.text = creatorText;
    }
}

- (void)updateChatDesiredInsets
{
    CGFloat topInset = CGRectGetMaxY(self.descriptionView.frame) + self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height + 5;
    self.beaconChatViewController.desiredEdgeInsets = UIEdgeInsetsMake(topInset, 0, 0, 0);
    UIEdgeInsets insets = self.beaconChatViewController.tableView.contentInset;
    insets.top = self.beaconChatViewController.desiredEdgeInsets.top;
    self.beaconChatViewController.tableView.contentInset = insets;
}

- (void)updateInviteListInsets
{
    CGFloat topInset = CGRectGetMaxY(self.descriptionView.frame);
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = topInset;
    self.inviteListViewController.tableView.contentInset = insets;
}

- (void)updateDealRedemptionInsets
{
    CGFloat topInset = CGRectGetMaxY(self.descriptionView.frame);
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = topInset;
    self.dealRedemptionViewController.tableView.contentInset = insets;
}

- (void)showPartialDescriptionViewAnimated:(BOOL)animated
{
    self.fullDescriptionViewShown = NO;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.descriptionView.frame;
        frame.origin.y = -CGRectGetMinY(self.chatTabButton.frame);
        self.descriptionView.frame = frame;
        [self updateChatDesiredInsets];
        [self updateInviteListInsets];
        [self updateDealRedemptionInsets];
    }];
}

- (void)showFullDescriptionViewAnimated:(BOOL)animated
{
    self.fullDescriptionViewShown = YES;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.descriptionView.frame;
        frame.origin.y = 0;
        self.descriptionView.frame = frame;
        [self updateChatDesiredInsets];
        [self updateInviteListInsets];
        [self updateDealRedemptionInsets];
    }];
}

- (void)showInviteAnimated:(BOOL)animated
{
    self.inviteTabButton.selected = YES;
    self.chatTabButton.selected = NO;
    self.dealButton.selected = NO;
    self.inviteListViewController.view.alpha = 1;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.inviteListViewController.view.transform = CGAffineTransformIdentity;
        self.beaconChatViewController.view.transform = CGAffineTransformMakeTranslation(-self.beaconChatViewController.view.frame.size.width, 0);
        self.beaconChatViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.beaconChatViewController.view.alpha = 0;
    }];
}

- (void)showChatAnimated:(BOOL)animated
{
    self.inviteTabButton.selected = NO;
    self.chatTabButton.selected = YES;
    self.dealButton.selected = NO;
    self.beaconChatViewController.view.alpha = 1;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.inviteListViewController.view.transform = CGAffineTransformMakeTranslation(self.inviteListViewController.view.frame.size.width, 0);
        self.beaconChatViewController.view.transform = CGAffineTransformIdentity;
        self.inviteListViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.inviteListViewController.view.alpha = 0;
    }];
}

- (void)showDealAnimated:(BOOL)animated
{
    self.dealButton.selected = YES;
    self.inviteTabButton.selected = NO;
    self.chatTabButton.selected = NO;
    self.dealRedemptionViewController.view.alpha = 1;
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.beaconChatViewController.view.transform = CGAffineTransformMakeTranslation(self.beaconChatViewController.view.frame.size.width, 0);
        self.inviteListViewController.view.transform = self.beaconChatViewController.view.transform;
        self.dealRedemptionViewController.view.transform = CGAffineTransformIdentity;
        self.beaconChatViewController.view.alpha = 0.0;
        self.inviteListViewController.view.alpha = self.beaconChatViewController.view.alpha;
    } completion:^(BOOL finished) {
        self.beaconChatViewController.view.alpha = 0;
    }];
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
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

#pragma mark - UIGestureRecognzierDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardShown = YES;
    [self showPartialDescriptionViewAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardShown = NO;
}

#pragma mark - Buttons

- (void)inviteLabelTouched:(id)sender
{
    [self showInviteAnimated:YES];
}

- (void)tabButtonTouched:(UIButton *)sender
{
    if (self.fullDescriptionViewShown && sender.selected) {
        [self showPartialDescriptionViewAnimated:YES];
    }
    else if (!self.fullDescriptionViewShown && sender.selected) {
        [self showFullDescriptionViewAnimated:YES];
    }
    if (sender == self.chatTabButton) {
        [self showChatAnimated:YES];
    }
    else if (sender == self.inviteTabButton) {
        [self showInviteAnimated:YES];
    }
    else if (sender == self.dealButton) {
        [self showDealAnimated:YES];
    }
    [self.beaconChatViewController dismissKeyboard];
}

- (void)chatCameraButtonTouched:(id)sender
{
    [self showCameraActionSheet];
}

- (void)joinButtonTouched:(id)sender
{
    [self join:^{
        [self promptToInviteFriends];
    }];
}

- (void)join:(void (^)())didJoin
{
    [[BeaconManager sharedManager] confirmBeacon:self.beacon success:^{
        [self refreshBeaconData];
    } failure:nil];
    self.joinButton.hidden = YES;
    self.inviteButton.hidden = NO;
    if (didJoin) {
        didJoin();
    }
}

- (void)inviteButtonTouched:(id)sender
{
    [self inviteMoreFriends];
}

- (void)editButtonTouched:(id)sender
{
    SetBeaconViewController *setBeaconViewController = [[SetBeaconViewController alloc] init];
    setBeaconViewController.delegate = self;
    setBeaconViewController.editMode = YES;
    setBeaconViewController.beacon = self.beacon;
    [self.navigationController pushViewController:setBeaconViewController animated:YES];
}

- (void)imageViewTapped:(id)sender
{
    [self getDirectionsToBeacon];
}

- (void)chatViewTapped:(id)sender
{
    BOOL textViewEmpty = !(self.beaconChatViewController.textView.text && self.beaconChatViewController.textView.text.length);
    if (self.keyboardShown && textViewEmpty) {
        [self.beaconChatViewController.textView resignFirstResponder];
    }
}

- (void)showCameraActionSheet
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

- (void)descriptionViewSwipedDown:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    [self showFullDescriptionViewAnimated:YES];
}

- (void)descriptionViewSwipedUp:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    [self showPartialDescriptionViewAnimated:YES];
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
            [self.beaconChatViewController createChatMessageWithImage:scaledImage];
            [[APIClient sharedClient] postImage:scaledImage forBeaconWithID:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    }];
}

#pragma mark - ChatViewControllerDelegate
- (void)chatViewController:(ChatViewController *)chatViewController willEndDraggingWithVelocity:(CGPoint)velocity
{
    if (velocity.y > 1) {
        [self showPartialDescriptionViewAnimated:YES];
    }
    if (chatViewController.tableView.contentOffset.y < (-chatViewController.tableView.contentInset.top - 20) && !self.fullDescriptionViewShown && !self.keyboardShown) {
        [self showFullDescriptionViewAnimated:YES];
    }
}

- (void)chatViewController:(ChatViewController *)chatViewController didSelectChatMessage:(ChatMessage *)chatMessage
{
    if (self.keyboardShown && (!chatViewController.textView.text || !chatViewController.textView.text.length)) {
        [chatViewController.textView resignFirstResponder];
        return;
    }
    
    if (chatMessage.isImageMessage) {
        ImageViewController *imageViewController = [[ImageViewController alloc] init];
        [self.navigationController pushViewController:imageViewController animated:YES];
        NSString *title = [NSString stringWithFormat:@"%@'s Pic", chatMessage.sender.firstName];
        imageViewController.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:title];
        if (chatMessage.cachedImage) {
            imageViewController.image = chatMessage.cachedImage;
        }
        else if (chatMessage.imageURL) {
            [[SDWebImageManager sharedManager] downloadWithURL:chatMessage.imageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    imageViewController.image = image;
                }
            }];
        }
    }
}

#pragma mark - SetBeaconViewControllerDelegate
- (void)setBeaconViewController:(SetBeaconViewController *)setBeaconViewController didUpdateBeacon:(Beacon *)beacon
{
    self.beacon = beacon;
    [self.navigationController popToViewController:self animated:YES];
}

- (void)setBeaconViewController:(SetBeaconViewController *)setBeaconViewController didCancelBeacon:(Beacon *)beacon
{
    [setBeaconViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"You cancelled this Hotspot" message:@""];
    [alertView bk_setCancelButtonWithTitle:@"OK" handler:^{
        [[AppDelegate sharedAppDelegate] setSelectedViewControllerToHome];
    }];
    [alertView show];
}

#pragma mark - FindFriendsViewControllerDelegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
{
    [self.navigationController popToViewController:self animated:YES];
    if (!contacts || !contacts.count) {
        return;
    }
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] inviteMoreContacts:contacts toBeacon:self.beacon success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self refreshBeaconData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again later" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    [[AnalyticsManager sharedManager] inviteToBeacon:contacts.count];
}

#pragma mark - InviteListViewControllerDelegate
- (void)inviteListViewController:(InviteListViewController *)inviteListViewController didSelectBeaconStatus:(BeaconStatus *)beaconStatus
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
    NSString *name = @"";
    NSString *number = @"";
    NSNumber *friendID;
    BOOL isUser = NO;
    if (beaconStatus.user) {
        name = beaconStatus.user.firstName;
        number = beaconStatus.user.normalizedPhoneNumber;
        isUser = YES;
        friendID = beaconStatus.user.userID;
    }
    else if (beaconStatus.contact) {
        name = beaconStatus.contact.firstName;
        number = beaconStatus.contact.normalizedPhoneNumber;
        friendID = beaconStatus.contact.contactID;
    }
    
    if (!(beaconStatus.user && [beaconStatus.user.userID isEqual:[User loggedInUser].userID])) {
        [[ContactManager sharedManager] fetchAddressBookContacts:^(NSArray *contacts) {
            [actionSheet bk_addButtonWithTitle:[NSString stringWithFormat:@"Text %@", name] handler:^{
                [[ContactManager sharedManager] fetchAddressBookContacts:^(NSArray *contacts) {
                    NSArray *numbersInContactBook = [contacts valueForKey:@"normalizedPhoneNumber"];
                    if ([numbersInContactBook containsObject:number]) {
                        [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self
                                                                                                messageRecipients:@[number]];
                    }
                    else {
                        NSString *message = [NSString stringWithFormat:@"You ain't gots %@'s number", name];
                        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                } failure:nil];
            }];
        } failure:nil];
    }
    if (beaconStatus.beaconStatusOption != BeaconStatusOptionHere) {
        [actionSheet bk_addButtonWithTitle:[NSString stringWithFormat:@"Check In %@", name] handler:^{
            BeaconStatusOption oldStatus = beaconStatus.beaconStatusOption;
            beaconStatus.beaconStatusOption = BeaconStatusOptionHere;
            [inviteListViewController.tableView reloadData];
            [[APIClient sharedClient] checkInFriendWithID:friendID isUser:isUser atbeacon:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.beaconChatViewController reloadMessagesFromServerCompletion:nil];
                BOOL checkingInSelf = [friendID isEqualToNumber:[User loggedInUser].userID];
                [[AnalyticsManager sharedManager] setBeaconStatus:@"here" forSelf:checkingInSelf];
            }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                beaconStatus.beaconStatusOption = oldStatus;
                [inviteListViewController.tableView reloadData];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't check in your friend" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }];
    }
    else {
        NSString *title = [NSString stringWithFormat:@"Check Out %@", name];
        [actionSheet bk_addButtonWithTitle:title handler:^{
            BeaconStatusOption oldStatus = beaconStatus.beaconStatusOption;
            beaconStatus.beaconStatusOption = BeaconStatusOptionInvited;
            [inviteListViewController.tableView reloadData];
            [[APIClient sharedClient] checkoutFriendWithID:friendID isUser:isUser atBeacon:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.beaconChatViewController reloadMessagesFromServerCompletion:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                beaconStatus.beaconStatusOption = oldStatus;
                [inviteListViewController.tableView reloadData];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }];
    }
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}



@end