//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "SocialNotificationPopupView.h"
#import "Theme.h"

@interface SocialNotificationPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;

@end

@implementation SocialNotificationPopupView

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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"socialTutorialBackground"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
//    self.chatBubble = [[UIImageView alloc] init];
//    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor whiteColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:5.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 30;
    headerTitle.x = 55;
    headerTitle.width = self.width - 120;
    headerTitle.textAlignment = NSTextAlignmentLeft;
    //self.headerTitle.centerX = self.tableView.width/2;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 140;
    headerTitle.numberOfLines = 1;
    headerTitle.text = @"DRINKING IS BETTER WITH FRIENDS";
    [self.imageView addSubview:headerTitle];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 140, self.width - 120, 80)];
    textLabel.width = self.width - 100;
    textLabel.font = [ThemeManager lightFontOfSize:11];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.numberOfLines = 2;
    textLabel.text = @"If a check-in is open, friends can see where you're going and join you.";
    [self.imageView addSubview:textLabel];
    
    UIImageView *screenshot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friendScreenshotForTutorial"]];
    screenshot.y = 215;
    screenshot.x = 35;
    [self.imageView addSubview:screenshot];
    
    UILabel *toggleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 217, 150, 40)];
    toggleLabel.font = [ThemeManager boldFontOfSize:10];
    toggleLabel.textAlignment = NSTextAlignmentRight;
    toggleLabel.numberOfLines = 2;
    toggleLabel.text = @"Tap here to make a check-in either open or closed to friends";
    [self.imageView addSubview:toggleLabel];
    
    UILabel *friendManageLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 305, 135, 40)];
    friendManageLabel.font = [ThemeManager boldFontOfSize:10];
    friendManageLabel.textAlignment = NSTextAlignmentRight;
    friendManageLabel.numberOfLines = 2;
    friendManageLabel.text = @"Tap here to see and manage your friends on Hotspot";
    [self.imageView addSubview:friendManageLabel];
    
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
    
    UIButton *launchInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    launchInviteButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    launchInviteButton.size = CGSizeMake(200, 30);
    launchInviteButton.centerX = (self.width/2.0);
    launchInviteButton.y = 362;
    launchInviteButton.layer.cornerRadius = 3;
    [launchInviteButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
    [launchInviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [launchInviteButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    launchInviteButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
    [launchInviteButton addTarget:self action:@selector(continueToRedemptionView:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:launchInviteButton];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 400;
    [self.doneButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
//    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
//    self.doneButton.backgroundColor = [UIColor whiteColor];
//    self.doneButton.size = CGSizeMake(230, 25);
//    self.doneButton.centerX = self.width/2.0;
//    self.doneButton.y = 438;
//    [self.doneButton setTitle:@"Not right now" forState:UIControlStateNormal];
//    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
//    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
//    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//    [self.imageView addSubview:self.doneButton];
    
    return self;
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

- (void)continueToRedemptionView:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundView.alpha = 0;
        CGFloat angle = -M_1_PI + (float) random()/RAND_MAX *2*M_1_PI;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
        transform = CGAffineTransformRotate(transform, angle);
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLaunchRedemptionView object:self userInfo:nil];
        [self removeFromSuperview];
    }];
}


@end