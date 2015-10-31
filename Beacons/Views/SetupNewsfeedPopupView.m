//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "SetupNewsfeedPopupView.h"
#import "Theme.h"
#import "BeaconProfileViewController.h"
#import "APIClient.h"
#import "LoadingIndictor.h"
#import "Deal.h"
#import "Beacon.h"
#import "DealStatus.h"
#import "Venue.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ContactManager.h"

@interface SetupNewsfeedPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;
@property (strong, nonatomic) UIButton *syncContactsButton;
@property (strong, nonatomic) UIButton *linkFacebookButton;

@end

@implementation SetupNewsfeedPopupView
//@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self addSubview:self.backgroundView];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needHelpModalBackground"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    self.chatBubble = [[UIImageView alloc] init];
    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor whiteColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:5.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    UIImageView *drinkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setupNewsfeed"]];
    drinkIcon.size = CGSizeMake(30, 30);
    drinkIcon.centerX = self.width/2;
    drinkIcon.y = 130;
    [self.imageView addSubview:drinkIcon];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 30;
    headerTitle.width = self.width;
    headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 160;
    headerTitle.text = @"NEWSFEED SETUP";
    [self.imageView addSubview:headerTitle];
    
    UILabel *callHeader = [[UILabel alloc] init];
    callHeader.height = 70;
    callHeader.width = self.width - 150;
    callHeader.textAlignment = NSTextAlignmentCenter;
    callHeader.numberOfLines = 0;
    callHeader.centerX = self.width/2;
    callHeader.font = [ThemeManager lightFontOfSize:12];
    callHeader.y = 180;
    callHeader.text = @"To ensure you see every update from friends and venues, we highly recommend linking facebook and syncing contacts.";
    [self.imageView addSubview:callHeader];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 390;
    [self.doneButton setTitle:@"I'll do this later" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
    self.linkFacebookButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.linkFacebookButton.size = CGSizeMake(self.width - 50, 35);
    self.linkFacebookButton.y = 270;
    self.linkFacebookButton.width = 170;
    self.linkFacebookButton.height = 35;
    self.linkFacebookButton.centerX = self.imageView.width/2.0;
    self.linkFacebookButton.layer.cornerRadius = 4;
    self.linkFacebookButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.linkFacebookButton.layer.borderWidth = 1;
    self.linkFacebookButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.linkFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.linkFacebookButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.linkFacebookButton.titleLabel.font = [ThemeManager boldFontOfSize:14];
    
    self.syncContactsButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.syncContactsButton.backgroundColor=[[ThemeManager sharedTheme] lightBlueColor];
    self.syncContactsButton.layer.cornerRadius = 4;
    self.syncContactsButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.syncContactsButton.layer.borderWidth = 1;
    self.syncContactsButton.frame=CGRectMake(0,330,170,35);
    self.syncContactsButton.titleLabel.font = [ThemeManager boldFontOfSize:14];
    self.syncContactsButton.centerX = self.imageView.width/2;
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self changeFacebookButtonToCompletedState];
    } else {
        [self changeFacebookButtonToIncompletedState];
    }
    
    [self.linkFacebookButton
     addTarget:self
     action:@selector(facebookButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.syncContactsButton
     addTarget:self
     action:@selector(contactButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
        [self changeContactButtonToActiveState];
    }
    else if (contactAuthStatus == kABAuthorizationStatusDenied) {
        [self changeContactButtonToInactiveState];
    }
    else if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
        [self changeContactButtonToSelectedState];
    }

    [self.imageView addSubview:self.linkFacebookButton];
    [self.imageView addSubview:self.syncContactsButton];
    
    return self;
}

-(void) changeFacebookButtonToCompletedState
{
    [self.linkFacebookButton setTitle: @"Facebook Linked" forState: UIControlStateNormal];
    self.linkFacebookButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.linkFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) changeFacebookButtonToIncompletedState
{
    [self.linkFacebookButton setTitle: @"Link Facebook" forState: UIControlStateNormal];
    self.linkFacebookButton.backgroundColor = [UIColor clearColor];
    [self.linkFacebookButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
}

-(void) changeContactButtonToActiveState
{
    [self.syncContactsButton setTitle:@"Sync Contacts" forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [UIColor clearColor];
    [self.syncContactsButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    
}

-(void) changeContactButtonToSelectedState
{
    [self.syncContactsButton setTitle:@"Contacts Synced" forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.syncContactsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) changeContactButtonToInactiveState
{
    [self.syncContactsButton setTitle:@"Sync Contacts" forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [UIColor grayColor];
    self.syncContactsButton.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)show
{
    UIWindow *frontWindow = [[UIApplication sharedApplication] keyWindow];
    [frontWindow.rootViewController.view addSubview:self];
    self.backgroundView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
    }];
    self.imageView.transform = CGAffineTransformMakeTranslation(0, -self.height + 100);
    [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismissAndReportIssue:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundView.alpha = 0;
        CGFloat angle = -M_1_PI + (float) random()/RAND_MAX *2*M_1_PI;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
        transform = CGAffineTransformRotate(transform, angle);
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        //[self feedbackDeal];
//        [self.delegate launchInviteFriends];
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundView.alpha = 0;
        CGFloat angle = -M_1_PI + (float) random()/RAND_MAX *2*M_1_PI;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
        transform = CGAffineTransformRotate(transform, angle);
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)facebookButtonClicked
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[UIAlertView alloc] initWithTitle:@"Facebook Linked" message:@"You've already linked your facebook account to Hotspot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
         fromViewController:nil
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 [[APIClient sharedClient] postFacebookToken:result.token.tokenString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"access token: %@", result.token.tokenString);
                     [self checkPermissionsAndDismissModal];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Facebook token failure");
                 }];
             }
         }];
    }
}

-(void) contactButtonClicked
{
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self changeContactButtonToSelectedState];
                [self checkPermissionsAndDismissModal];
            }
        });
    }
    else if (contactAuthStatus == kABAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"Syncing Contact Permission" message:@"To sync contacts, go to Settings > Hotspot and turn on contact permissions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
        [[[UIAlertView alloc] initWithTitle:@"Contact Synced" message:@"You've already synced your contacts with Hotspot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void) checkPermissionsAndDismissModal
{
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if ([FBSDKAccessToken currentAccessToken] && contactAuthStatus != kABAuthorizationStatusNotDetermined)
    {
        [self dismiss];
    }
}

@end