//
//  BeaconProfileViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/12/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+FormattedDate.h"
#import "BeaconChatViewController.h"
#import "InviteListViewController.h"
#import "Beacon.h"
#import "Theme.h"
#import "User.h"

@interface BeaconProfileViewController ()

@property (strong, nonatomic) BeaconChatViewController *beaconChatViewController;
@property (strong, nonatomic) InviteListViewController *inviteListViewController;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *chatTabButton;
@property (strong, nonatomic) UIButton *inviteTabButton;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *invitedLabel;
@property (strong, nonatomic) UIButton *joinButton;
@property (assign, nonatomic) BOOL chatTabSelected;
@end

@implementation BeaconProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.beaconChatViewController = [[BeaconChatViewController alloc] init];
        self.inviteListViewController = [[InviteListViewController alloc] init];
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
    
    [self addChildViewController:self.beaconChatViewController];
    [self.view addSubview:self.beaconChatViewController.view];
    self.beaconChatViewController.view.frame = self.view.bounds;
    self.beaconChatViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.chatTabSelected = YES;
    
    [self addChildViewController:self.inviteListViewController];
    [self.view addSubview:self.inviteListViewController.view];
    self.inviteListViewController.view.alpha = 0;
    self.inviteListViewController.view.frame = self.view.bounds;
    self.inviteListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 226)];
    self.descriptionView.backgroundColor = [UIColor whiteColor];
    self.descriptionView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.descriptionView.layer.shadowOpacity = 1;
    self.descriptionView.layer.shadowRadius = 3.0;
    self.descriptionView.layer.shadowOffset = CGSizeMake(0, 2);
    self.descriptionView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.descriptionView.bounds cornerRadius:self.descriptionView.layer.cornerRadius].CGPath;
    [self.view addSubview:self.descriptionView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.descriptionView.frame.size.width, 110)];
    [self.descriptionView addSubview:self.imageView];
    [self updateChatDesiredInsets];
    
    self.chatTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect chatTabButtonFrame;
    chatTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
    chatTabButtonFrame.origin = CGPointMake(0, self.descriptionView.frame.size.height - chatTabButtonFrame.size.height);
    self.chatTabButton.frame = chatTabButtonFrame;
    [self.chatTabButton setTitle:@"chat" forState:UIControlStateNormal];
    self.chatTabButton.backgroundColor = [UIColor greenColor];
    [self.chatTabButton addTarget:self action:@selector(chatButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.chatTabButton];
    
    self.inviteTabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect inviteTabButtonFrame;
    inviteTabButtonFrame.size = CGSizeMake(self.descriptionView.frame.size.width/2.0, 42);
    inviteTabButtonFrame.origin = CGPointMake(CGRectGetMaxX(self.chatTabButton.frame), self.descriptionView.frame.size.height - inviteTabButtonFrame.size.height);
    self.inviteTabButton.frame = inviteTabButtonFrame;
    [self.inviteTabButton setTitle:@"invited" forState:UIControlStateNormal];
    self.inviteTabButton.backgroundColor = [UIColor purpleColor];
    [self.inviteTabButton addTarget:self action:@selector(invitedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.inviteTabButton];
    
    UIImageView *backgroundGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundGradient"]];
    CGRect backgroundGradientFrame = backgroundGradient.frame;
    backgroundGradientFrame.origin.y = self.imageView.frame.size.height - backgroundGradientFrame.size.height;
    backgroundGradient.frame = backgroundGradientFrame;
    [self.imageView addSubview:backgroundGradient];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 58, 100, 21)];
    self.timeLabel.font = [ThemeManager regularFontOfSize:21];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.imageView addSubview:self.timeLabel];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 90, 200, 21)];
    self.descriptionLabel.font = [ThemeManager regularFontOfSize:21];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    [self.imageView addSubview:self.descriptionLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 124, 180, 11)];
    self.locationLabel.font = [ThemeManager regularFontOfSize:11];
    self.locationLabel.textColor = [UIColor blackColor];
    [self.descriptionView addSubview:self.locationLabel];
    
    self.invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 148, 180, 11)];
    self.invitedLabel.font = [ThemeManager regularFontOfSize:11];
    self.invitedLabel.textColor = [UIColor blackColor];
    [self.descriptionView addSubview:self.invitedLabel];
    
    self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.joinButton.frame = CGRectMake(226, 125, 73, 31);
    [self.joinButton setTitle:@"join" forState:UIControlStateNormal];
    [self.joinButton setTitleColor:[[ThemeManager sharedTheme] orangeColor] forState:UIControlStateNormal];
    self.joinButton.layer.cornerRadius = 2;
    self.joinButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.joinButton.layer.borderWidth = 0.5;
    [self.joinButton addTarget:self action:@selector(joinButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.descriptionView addSubview:self.joinButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:titleImage]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateInviteListInsets];
    [self updateChatDesiredInsets];
}

- (void)setBeacon:(Beacon *)beacon
{
    [self view];
    _beacon = beacon;
    self.beaconChatViewController.beacon = beacon;
    self.imageView.image = [UIImage imageNamed:@"beaconImageTest"];
    
    self.timeLabel.text = [beacon.time formattedDate];
    self.descriptionLabel.text = beacon.beaconDescription;
    self.locationLabel.text = beacon.address;
    [self updateInvitedLabel];
    
    self.inviteListViewController.beaconStatuses = beacon.invited;
}

- (void)updateInvitedLabel
{
    NSString *creatorText = [self.beacon.creator fullName];
    NSString *otherText;
    if (self.beacon.invited && self.beacon.invited.count) {
        NSString *other = self.beacon.invited.count == 1 ? @"other" : @"others";
        otherText = [NSString stringWithFormat:@"and %d %@", self.beacon.invited.count, other];
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
    CGFloat topInset = CGRectGetMaxY(self.descriptionView.frame) + self.navigationController.navigationBar.frame.size.height;
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
    self.inviteListViewController.view.backgroundColor = [UIColor brownColor];
}

- (void)showPartialDescriptionViewAnimated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.descriptionView.frame;
        frame.origin.y = -CGRectGetMinY(self.chatTabButton.frame);
        self.descriptionView.frame = frame;
        [self updateChatDesiredInsets];
    }];
}

- (void)showFullDescriptionViewAnimated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.descriptionView.frame;
        frame.origin.y = 0;
        self.descriptionView.frame = frame;
        [self updateChatDesiredInsets];
    }];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self showPartialDescriptionViewAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

#pragma mark - Buttons 
- (void)chatButtonTouched:(id)sender
{
    self.chatTabSelected = YES;
    [self showFullDescriptionViewAnimated:YES];
    self.inviteListViewController.view.alpha = 0.0;
    [self.beaconChatViewController dismissKeyboard];
}

- (void)invitedButtonTouched:(id)sender
{
    self.chatTabSelected = NO;
    [self showFullDescriptionViewAnimated:YES];
    self.inviteListViewController.view.alpha = 1.0;
    [self.beaconChatViewController dismissKeyboard];
}

- (void)joinButtonTouched:(id)sender
{
    
}


@end
