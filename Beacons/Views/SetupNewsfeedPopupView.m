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
#import "NotificationManager.h"

@interface SetupNewsfeedPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;
@property (strong, nonatomic) UIButton *syncContactsButton;
@property (strong, nonatomic) UIButton *linkFacebookButton;
@property (strong, nonatomic) UIButton *enablePushButton;

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
    headerTitle.y = 155;
    headerTitle.text = @"NEWSFEED SETUP";
    [self.imageView addSubview:headerTitle];
    
    UILabel *callHeader = [[UILabel alloc] init];
    callHeader.height = 70;
    callHeader.width = self.width - 130;
    callHeader.textAlignment = NSTextAlignmentCenter;
    callHeader.numberOfLines = 0;
    callHeader.centerX = self.width/2;
    callHeader.font = [ThemeManager lightFontOfSize:11];
    callHeader.y = 175;
    callHeader.text = @"To ensure you see every update from friends and venues, we highly recommend linking facebook, enabling push, and syncing contacts.";
    [self.imageView addSubview:callHeader];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 385;
    [self.doneButton setTitle:@"I'll do this later" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismissSetupModal) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
    self.linkFacebookButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.linkFacebookButton.size = CGSizeMake(self.width - 50, 35);
    self.linkFacebookButton.y = 255;
    self.linkFacebookButton.width = 180;
    self.linkFacebookButton.height = 25;
    self.linkFacebookButton.centerX = self.imageView.width/2.0;
    self.linkFacebookButton.layer.cornerRadius = 3;
    self.linkFacebookButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.linkFacebookButton.layer.borderWidth = 1;
    self.linkFacebookButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.linkFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.linkFacebookButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.linkFacebookButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
    
    self.enablePushButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.enablePushButton.size = CGSizeMake(self.width - 50, 35);
    self.enablePushButton.y = 300;
    self.enablePushButton.width = 180;
    self.enablePushButton.height = 25;
    self.enablePushButton.centerX = self.imageView.width/2.0;
    self.enablePushButton.layer.cornerRadius = 3;
    self.enablePushButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.enablePushButton.layer.borderWidth = 1;
    self.enablePushButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.enablePushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.enablePushButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    self.enablePushButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
    
    self.syncContactsButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.syncContactsButton.backgroundColor=[[ThemeManager sharedTheme] lightBlueColor];
    self.syncContactsButton.layer.cornerRadius = 3;
    self.syncContactsButton.layer.borderColor = [[ThemeManager sharedTheme] lightBlueColor].CGColor;
    self.syncContactsButton.layer.borderWidth = 1;
    [self.syncContactsButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.syncContactsButton.frame=CGRectMake(0,345,180,25);
    self.syncContactsButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
    self.syncContactsButton.centerX = self.imageView.width/2;
    
    [self.linkFacebookButton
     addTarget:self
     action:@selector(facebookButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.enablePushButton
     addTarget:self
     action:@selector(pushButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.syncContactsButton
     addTarget:self
     action:@selector(contactButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    [self.imageView addSubview:self.linkFacebookButton];
    [self.imageView addSubview:self.enablePushButton];
    [self.imageView addSubview:self.syncContactsButton];
    
    return self;
}

-(void) changeFacebookButtonToCompletedState
{
    [self.linkFacebookButton setTitle: @"  FACEBOOK LINKED" forState: UIControlStateNormal];
    [self.linkFacebookButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.linkFacebookButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.linkFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) changeFacebookButtonToIncompletedState
{
    [self.linkFacebookButton setTitle: @"LINK FACEBOOK" forState: UIControlStateNormal];
    [self.linkFacebookButton setImage:nil forState:UIControlStateNormal];
    self.linkFacebookButton.backgroundColor = [UIColor clearColor];
    [self.linkFacebookButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
}

-(void) changeContactButtonToActiveState
{
    [self.syncContactsButton setTitle:@"SYNC CONTACTS" forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [UIColor clearColor];
    [self.syncContactsButton setImage:nil forState:UIControlStateNormal];
    [self.syncContactsButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    
}

-(void) changeContactButtonToSelectedState
{
    [self.syncContactsButton setTitle:@"  CONTACTS SYNCED" forState:UIControlStateNormal];
    [self.syncContactsButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.syncContactsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) changeContactButtonToInactiveState
{
    [self.syncContactsButton setTitle:@"SYNC CONTACTS" forState:UIControlStateNormal];
    [self.syncContactsButton setImage:nil forState:UIControlStateNormal];
    self.syncContactsButton.backgroundColor = [UIColor grayColor];
    self.syncContactsButton.layer.borderColor = [UIColor grayColor].CGColor;
}

-(void) changePushButtonToActiveState
{
    [self.enablePushButton setTitle:@"ENABLE PUSH" forState:UIControlStateNormal];
    self.enablePushButton.backgroundColor = [UIColor clearColor];
    [self.enablePushButton setImage:nil forState:UIControlStateNormal];
    [self.enablePushButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    
}

-(void) changePushButtonToSelectedState
{
    [self.enablePushButton setTitle:@"  PUSH ENABLED" forState:UIControlStateNormal];
    [self.enablePushButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    self.enablePushButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.enablePushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

//-(void) changePushButtonToInactiveState
//{
//    [self.enablePushButton setTitle:@"Enable Push" forState:UIControlStateNormal];
//    [self.enablePushButton setImage:nil forState:UIControlStateNormal];
//    self.enablePushButton.backgroundColor = [UIColor grayColor];
//    self.enablePushButton.layer.borderColor = [UIColor grayColor].CGColor;
//}

- (void)show
{
    NSLog(@"FACEOOK PERMISSIONS: %@", [FBSDKAccessToken currentAccessToken]);
 
    if ([FBSDKAccessToken currentAccessToken]) {
        [self changeFacebookButtonToCompletedState];
    } else {
        [self changeFacebookButtonToIncompletedState];
    }
    
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
    
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
    {
        [self changePushButtonToSelectedState];
    } else {
        [self changePushButtonToActiveState];
    }
    
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

- (void)dismissSetupModal
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

-(void)facebookButtonTouched
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[UIAlertView alloc] initWithTitle:@"Facebook Linked" message:@"You've already linked your facebook account to Hotspot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
         fromViewController:nil
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [self show];
             if (error) {
                 [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error linking Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 NSLog(@"error: %@", error);
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 [[APIClient sharedClient] postFacebookToken:result.token.tokenString success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"access token: %@", result.token.tokenString);
                     [self changeFacebookButtonToCompletedState];
                     [self checkPermissionsAndDismissModal];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [self changeFacebookButtonToIncompletedState];
                     NSLog(@"Facebook token failure");
                 }];
             }
         }];
    }
}

-(void) pushButtonTouched
{
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
            [self changePushButtonToSelectedState];
            [self checkPermissionsAndDismissModal];
        } failure:^(NSError *error) {
            NSLog(@"ERROR: %@", error);
            [self changePushButtonToActiveState];
            [self checkPermissionsAndDismissModal];
        }];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Enabling Push Permissions" message:@"To enable push, go to Settings > Hotspot and turn on push permissions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void) contactButtonTouched
{
    
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        [LoadingIndictor showLoadingIndicatorInView:self animated:YES];
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"Granted Contact Permissions");
                [self changeContactButtonToSelectedState];
                [self checkPermissionsAndDismissModal];
            } else {
                [self changeContactButtonToInactiveState];
                [self checkPermissionsAndDismissModal];
            }
        });
        [LoadingIndictor hideLoadingIndicatorForView:self animated:YES];
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
    if ([FBSDKAccessToken currentAccessToken] && contactAuthStatus != kABAuthorizationStatusNotDetermined && [[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishNewsfeedPermissions object:self];
        [self dismissSetupModal];
    }
}

@end