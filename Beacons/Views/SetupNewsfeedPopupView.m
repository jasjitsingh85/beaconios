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

@interface SetupNewsfeedPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;

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
    
    UIImageView *drinkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpSign"]];
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
    headerTitle.y = 150;
    headerTitle.text = @"SETUP NEWSFEED";
    [self.imageView addSubview:headerTitle];
    
    UILabel *callHeader = [[UILabel alloc] init];
    callHeader.height = 30;
    callHeader.width = self.width;
    callHeader.textAlignment = NSTextAlignmentCenter;
    callHeader.centerX = self.width/2;
    callHeader.font = [ThemeManager lightFontOfSize:12];
    callHeader.y = 280;
    callHeader.text = @"";
    [self.imageView addSubview:callHeader];
    
    UIButton *callButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    callButton.backgroundColor = [UIColor whiteColor];
    callButton.size = CGSizeMake(230, 25);
    callButton.centerX = self.width/2.0;
    callButton.y = 305;
    [callButton setTitle:@"" forState:UIControlStateNormal];
    [callButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    callButton.titleLabel.font = [ThemeManager lightFontOfSize:14];
    [callButton addTarget:self action:@selector(callSupport) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:callButton];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:12125551212"]]
    
//    UILabel *textLabelLineTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 325, self.width - 110, 80)];
//    textLabelLineTwo.centerX = self.width/2;
//    textLabelLineTwo.font = [ThemeManager lightFontOfSize:12];
//    textLabelLineTwo.textAlignment = NSTextAlignmentCenter;
//    textLabelLineTwo.numberOfLines = 2;
//    textLabelLineTwo.text = @"Redeem free drinks when you set a Hotspot. Free drinks are eligible for any drink that costs $5 or less.";
//    [self.imageView addSubview:textLabelLineTwo];
    
//    NSRange range = NSMakeRange(0, 6);
//    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:textLabelLineTwo.text];
//    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
//    textLabelLineTwo.attributedText = attributedText;
    
//    UIButton *launchInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    launchInviteButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
//    launchInviteButton.size = CGSizeMake(240.25, 35);
//    launchInviteButton.centerX = (self.width/2.0) - .75;
//    launchInviteButton.y = 356;
//    [launchInviteButton setTitle:@"GOT IT" forState:UIControlStateNormal];
//    [launchInviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    launchInviteButton.titleLabel.font = [ThemeManager boldFontOfSize:14];
//    [launchInviteButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//    [self.imageView addSubview:launchInviteButton];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 395;
    [self.doneButton setTitle:@"I'll do this later" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
    
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.backgroundColor=[UIColor darkGrayColor];
    myLoginButton.frame=CGRectMake(0,200,180,40);
    myLoginButton.centerX = self.imageView.width/2;
    [myLoginButton setTitle: @"My Login Button" forState: UIControlStateNormal];
    
    // Handle clicks on the button
    [myLoginButton
     addTarget:self
     action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // Add the button to the view
    [self.imageView addSubview:myLoginButton];
    
    return self;
}

-(void) callSupport
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:12039367101"]];
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

-(void)loginButtonClicked
{
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
            NSLog(@"access token: %@", result.token.tokenString);
         }
     }];
}

@end