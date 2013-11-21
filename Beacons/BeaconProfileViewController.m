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
#import "UIImage+Resize.h"
#import "BeaconChatViewController.h"
#import "InviteListViewController.h"
#import "Beacon.h"
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
#import "KenBurnsView.h"
#import "Utilities.h"
#import "BeaconStatus.h"
#import "TextMessageManager.h"
#import "AppDelegate.h"
#import "BounceButton.h"
#import "NavigationBarTitleLabel.h"
#import "AnalyticsManager.h"

@interface BeaconProfileViewController () <FindFriendsViewControllerDelegate, ChatViewControllerDelegate, InviteListViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) BeaconChatViewController *beaconChatViewController;
@property (strong, nonatomic) InviteListViewController *inviteListViewController;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *imageViewGradient;
@property (strong, nonatomic) KenBurnsView *kenBurnsView;
@property (strong, nonatomic) BounceButton *chatTabButton;
@property (strong, nonatomic) BounceButton *inviteTabButton;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *invitedLabel;
@property (strong, nonatomic) UIButton *joinButton;
@property (strong, nonatomic) UIButton *inviteButton;
@property (strong, nonatomic) UIButton *directionsButton;
@property (strong, nonatomic) UIView *addPictureView;
@property (assign, nonatomic) BOOL fullDescriptionViewShown;
@property (assign, nonatomic) BOOL keyboardShown;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *boneWhiteColor = [UIColor colorWithRed:248/255.0 green:243/255.0 blue:236/255.0 alpha:1.0];
    self.view.backgroundColor = boneWhiteColor;
    
    [self addChildViewController:self.beaconChatViewController];
    [self.view addSubview:self.beaconChatViewController.view];
    self.beaconChatViewController.view.frame = self.view.bounds;
    self.beaconChatViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.beaconChatViewController.cameraButton addTarget:self action:@selector(chatCameraButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.beaconChatViewController.tableView.backgroundColor = boneWhiteColor;
    self.beaconChatViewController.textViewContainer.backgroundColor = [UIColor clearColor];
    self.beaconChatViewController.textViewContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.beaconChatViewController.textViewContainer.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.beaconChatViewController.textViewContainer.layer.shadowOpacity = 1;
    self.beaconChatViewController.textViewContainer.layer.shadowRadius = 5.0;
    self.beaconChatViewController.textViewContainer.layer.shadowOffset = CGSizeMake(0, 2);
    
    [self addChildViewController:self.inviteListViewController];
    [self.view addSubview:self.inviteListViewController.view];
    self.inviteListViewController.view.frame = self.view.bounds;
    self.inviteListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.inviteListViewController.view.backgroundColor = boneWhiteColor;
    
    self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 226)];
    self.descriptionView.backgroundColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    self.descriptionView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.descriptionView.layer.shadowOpacity = 0.7;
    self.descriptionView.layer.shadowRadius = 5.0;
    self.descriptionView.layer.shadowOffset = CGSizeMake(0, 10);
    self.descriptionView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.descriptionView.bounds cornerRadius:self.descriptionView.layer.cornerRadius].CGPath;
    [self.view addSubview:self.descriptionView];
    self.fullDescriptionViewShown = YES;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.descriptionView.frame.size.width, 110)];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    imageTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:imageTap];
    self.imageView.userInteractionEnabled = YES;
    [self.descriptionView addSubview:self.imageView];
    [self updateChatDesiredInsets];
    
    self.kenBurnsView = [[KenBurnsView alloc] initWithFrame:self.imageView.bounds];
    self.kenBurnsView.clipsToBounds = YES;
    [self.imageView addSubview:self.kenBurnsView];
    self.kenBurnsView.hidden = YES;
    
    self.chatTabButton = [BounceButton buttonWithType:UIButtonTypeCustom];
    CGRect chatTabButtonFrame;
    chatTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
    chatTabButtonFrame.origin = CGPointMake(0, self.descriptionView.frame.size.height - chatTabButtonFrame.size.height);
    self.chatTabButton.frame = chatTabButtonFrame;
    [self.chatTabButton setImage:[UIImage imageNamed:@"chatButtonNormal"] forState:UIControlStateNormal];
    [self.chatTabButton setImage:[UIImage imageNamed:@"chatButtonSelected"] forState:UIControlStateSelected];
    [self.chatTabButton addTarget:self action:@selector(chatTabTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.chatTabButton];
    self.chatTabButton.selected = YES;
    
    self.inviteTabButton = [BounceButton buttonWithType:UIButtonTypeCustom];
    CGRect inviteTabButtonFrame;
    inviteTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
    inviteTabButtonFrame.origin = CGPointMake(CGRectGetMaxX(self.chatTabButton.frame), self.descriptionView.frame.size.height - inviteTabButtonFrame.size.height);
    self.inviteTabButton.frame = inviteTabButtonFrame;
    [self.inviteTabButton setImage:[UIImage imageNamed:@"invitedButtonNormal"] forState:UIControlStateNormal];
    [self.inviteTabButton setImage:[UIImage imageNamed:@"invitedButtonSelected"] forState:UIControlStateSelected];
    [self.inviteTabButton addTarget:self action:@selector(inviteTabTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.inviteTabButton];
    
    UIView *verticalDivider = [[UIView alloc] init];
    CGRect verticalDividerFrame;
    verticalDividerFrame.size = CGSizeMake(1, 45);
    verticalDividerFrame.origin.x = 0.5*self.descriptionView.frame.size.width - 0.5*verticalDividerFrame.size.width;
    verticalDividerFrame.origin.y = self.descriptionView.frame.size.height - verticalDividerFrame.size.height;
    verticalDivider.frame = verticalDividerFrame;
    verticalDivider.backgroundColor = [UIColor whiteColor];
    [self.descriptionView addSubview:verticalDivider];
    
    
    self.imageViewGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundGradient"]];
    CGRect backgroundGradientFrame = self.imageViewGradient.frame;
    backgroundGradientFrame.origin.y = self.imageView.frame.size.height - backgroundGradientFrame.size.height;
    self.imageViewGradient.frame = backgroundGradientFrame;
    [self.imageView addSubview:self.imageViewGradient];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 46, 200, 35)];
    self.timeLabel.font = [ThemeManager lightFontOfSize:28];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.imageView addSubview:self.timeLabel];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 81, 250, 22)];
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.font = [ThemeManager regularFontOfSize:20];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    [self.imageView addSubview:self.descriptionLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 118, 160, 14)];
    self.locationLabel.font = [ThemeManager regularFontOfSize:13];
    self.locationLabel.textColor = [UIColor whiteColor];
    [self.descriptionView addSubview:self.locationLabel];
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon)];
    locationTap.numberOfTapsRequired = 1;
    [self.locationLabel addGestureRecognizer:locationTap];
    self.locationLabel.userInteractionEnabled = YES;
    
    self.invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 144, 180, 14)];
    self.invitedLabel.font = [ThemeManager regularFontOfSize:13];
    self.invitedLabel.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *invitedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteTabTouched:)];
    invitedTap.numberOfTapsRequired = YES;
    [self.invitedLabel addGestureRecognizer:invitedTap];
    self.invitedLabel.userInteractionEnabled = YES;
    [self.descriptionView addSubview:self.invitedLabel];
    
    self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.joinButton.frame = CGRectMake(226, 125, 73, 31);
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
    
    if (self.openToInviteView) {
        self.chatTabButton.selected = NO;
        self.inviteTabButton.selected = YES;
        [self showInviteAnimated:NO];
    }
    else {
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
}

- (void)refreshBeaconData
{
    if (!self.beacon) {
        return;
    }
    [[BeaconManager sharedManager] getBeaconWithID:self.beacon.beaconID success:^(Beacon *beacon) {
        self.beacon = beacon;
    } failure:nil];
    [self.beaconChatViewController reloadMessagesFromServerCompletion:nil];
}

- (void)setBeacon:(Beacon *)beacon
{
    [self view];
    _beacon = beacon;
    self.beaconChatViewController.beacon = beacon;
    if (!beacon.images || !beacon.images.count) {
        self.imageView.image = [UIImage imageNamed:@"cameraLarge"];
        self.imageViewGradient.hidden = YES;
    }
    else {
        self.imageViewGradient.hidden = NO;
        [self loadImageViewForBeacon:beacon];
    }
    
    self.timeLabel.text = [beacon.time formattedDate].lowercaseString;
    self.descriptionLabel.text = beacon.beaconDescription;
    self.locationLabel.text = beacon.address;
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
    
    //let server know that user has seen this hotspot
    [[APIClient sharedClient] markBeaconAsSeen:beacon success:nil failure:nil];
}

- (void)promptForCheckIn
{
    self.openToInviteView = YES;
    [self inviteTabTouched:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You're Here!" message:@"Want to check in?"];
    [alertView addButtonWithTitle:@"Nah" handler:nil];
    [alertView setCancelButtonWithTitle:@"Yes, Ma'am" handler:^{
        [[APIClient sharedClient] checkInFriendWithID:[User loggedInUser].userID isUser:YES atbeacon:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self refreshBeaconData];
        } failure:nil];
    }];
    [alertView show];
}

- (void)getDirectionsToBeacon
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Directions" message:@"Want to see the turn by turn?"];
    [alertView addButtonWithTitle:@"No, thank you" handler:nil];
    [alertView setCancelButtonWithTitle:@"Yes, please" handler:^{
        [Utilities launchMapDirectionsToCoordinate:self.beacon.coordinate addressDictionary:nil destinationName:self.beacon.beaconDescription];
        [[AnalyticsManager sharedManager] getDirections];
    }];
    [alertView show];
}

- (void)updateImageViewWithImage:(UIImage *)image
{
    self.kenBurnsView.hidden = NO;
    self.imageViewGradient.hidden = NO;
    if (!self.kenBurnsView.isAnimating) {
        [self.kenBurnsView animateWithImages:@[image] transitionDuration:6 loop:YES isLandscape:NO];
    }
    else {
        [self.kenBurnsView addImage:image];
    }
}

- (void)loadImageViewForBeacon:(Beacon *)beacon
{
    if (!beacon.images || !beacon.images.count) {
        return;
    }
    
    self.kenBurnsView.hidden = NO;
    for (BeaconImage *beaconImage in beacon.images) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:beaconImage.imageURL options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            jadispatch_main_qeue(^{
                if (!self.kenBurnsView.isAnimating) {
                    [self.kenBurnsView animateWithImages:@[image] transitionDuration:6 loop:YES isLandscape:NO];
                }
                else {
                    [self.kenBurnsView addImage:image];
                }
            });
        }];
    }
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
    }];
}

- (void)showInviteAnimated:(BOOL)animated
{
    self.inviteTabButton.selected = YES;
    self.chatTabButton.selected = NO;
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
- (void)chatTabTouched:(id)sender
{
    if (self.fullDescriptionViewShown && !self.inviteTabButton.selected) {
        [self showPartialDescriptionViewAnimated:YES];
    }
    else {
        [self showFullDescriptionViewAnimated:YES];
    }
//    self.inviteListViewController.view.alpha = 0.0;
    [self showChatAnimated:YES];
    [self.beaconChatViewController dismissKeyboard];
}

- (void)chatCameraButtonTouched:(id)sender
{
    [self showCameraActionSheet];
}

- (void)inviteTabTouched:(id)sender
{
    if (self.fullDescriptionViewShown && self.inviteTabButton.selected) {
        [self showPartialDescriptionViewAnimated:YES];
    }
    else {
        [self showFullDescriptionViewAnimated:YES];
    }
    [self showInviteAnimated:YES];
    [self.beaconChatViewController dismissKeyboard];
}

- (void)joinButtonTouched:(id)sender
{
    [[BeaconManager sharedManager] confirmBeacon:self.beacon success:^{
        [self refreshBeaconData];
    } failure:nil];
    self.joinButton.hidden = YES;
    self.inviteButton.hidden = NO;
    UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Cool" message:@"Want to invite more friends?"];
    [alertView addButtonWithTitle:@"No thanks" handler:nil];
    [alertView setCancelButtonWithTitle:@"Yeah!" handler:^{
        [self inviteMoreFriends];
    }];
    [alertView show];
    [[AnalyticsManager sharedManager] setBeaconStatus:@"going" forSelf:YES];
}

- (void)inviteButtonTouched:(id)sender
{
    [self inviteMoreFriends];
}


- (void)imageViewTapped:(id)sender
{
    [self showCameraActionSheet];
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
    UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:@"Want to add a photo?"];
    [actionSheet addButtonWithTitle:@"Take a Photo" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet addButtonWithTitle:@"Add From Library" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet setCancelButtonWithTitle:@"Not Now" handler:nil];
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
            [self updateImageViewWithImage:scaledImage];
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
    UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:@""];
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
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Text %@", name] handler:^{
            [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self
                                                                                    messageRecipients:@[number]];
        }];
    }
    if (beaconStatus.beaconStatusOption != BeaconStatusOptionHere) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Check In %@", name] handler:^{
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
        [actionSheet addButtonWithTitle:title handler:^{
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
    [actionSheet setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}



@end
