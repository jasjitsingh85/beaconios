//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "EnablePushPopupView.h"
#import "Theme.h"
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

@interface EnablePushPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;
@property (strong, nonatomic) UIButton *enablePushButton;

@end

@implementation EnablePushPopupView

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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallModalBackground"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    self.chatBubble = [[UIImageView alloc] init];
    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor whiteColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:5.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    UIImageView *drinkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textFriendsIcon"]];
    drinkIcon.size = CGSizeMake(30, 30);
    drinkIcon.centerX = self.width/2;
    drinkIcon.y = 160;
    [self.imageView addSubview:drinkIcon];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 30;
    headerTitle.width = self.width;
    headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 190;
    headerTitle.text = @"ENABLE PUSH NOTIFICATIONS";
    [self.imageView addSubview:headerTitle];
    
    UILabel *callHeader = [[UILabel alloc] init];
    callHeader.height = 70;
    callHeader.width = self.width - 130;
    callHeader.textAlignment = NSTextAlignmentCenter;
    callHeader.numberOfLines = 0;
    callHeader.centerX = self.width/2;
    callHeader.font = [ThemeManager lightFontOfSize:11];
    callHeader.y = 210;
    callHeader.text = @"To ensure you receive event news and information, we highly recommend enabling push permissions.";
    [self.imageView addSubview:callHeader];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 355;
    [self.doneButton setTitle:@"I'll do this later" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismissSetupModal) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
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
    
    [self.enablePushButton
     addTarget:self
     action:@selector(pushButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageView addSubview:self.enablePushButton];
    
    return self;
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

-(void) pushButtonTouched
{
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
//            [[NotificationManager sharedManager] didRegisterForRemoteNotificationsWithDeviceToken:devToken];
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

-(void) checkPermissionsAndDismissModal
{
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
    {
        [self dismissSetupModal];
    }
}

@end