//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "FreeDrinksExplanationPopupView.h"
#import "Theme.h"
#import "BeaconProfileViewController.h"

@interface FreeDrinksExplanationPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;

@end

@implementation FreeDrinksExplanationPopupView
@synthesize delegate;

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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inviteFriendsModalBackground"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    self.chatBubble = [[UIImageView alloc] init];
    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor whiteColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:5.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    UIImageView *drinkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drinkIcon"]];
    drinkIcon.size = CGSizeMake(30, 30);
    drinkIcon.centerX = self.width/2;
    drinkIcon.y = 237;
    [self.imageView addSubview:drinkIcon];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 30;
    headerTitle.width = self.width;
    headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 260;
    headerTitle.text = @"WANT A FREE DRINK?";
    [self.imageView addSubview:headerTitle];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 270, self.width - 110, 80)];
    textLabel.centerX = self.width/2;
    textLabel.font = [ThemeManager lightFontOfSize:12];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 4;
    textLabel.text = @"Get free drinks for you and your friends when they join Hotspot. Support the app by sharing the love!";
    [self.imageView addSubview:textLabel];
    
    UILabel *textLabelLineTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 325, self.width - 110, 80)];
    textLabelLineTwo.centerX = self.width/2;
    textLabelLineTwo.font = [ThemeManager lightFontOfSize:12];
    textLabelLineTwo.textAlignment = NSTextAlignmentCenter;
    textLabelLineTwo.numberOfLines = 1;
    textLabelLineTwo.text = @"Redeem drinks once you set a Hotspot";
    [self.imageView addSubview:textLabelLineTwo];
    
    NSRange range = NSMakeRange(0, 6);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:textLabelLineTwo.text];
    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
    textLabelLineTwo.attributedText = attributedText;
    
    UIButton *launchInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    launchInviteButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    launchInviteButton.size = CGSizeMake(240.25, 35);
    launchInviteButton.centerX = (self.width/2.0) - .75;
    launchInviteButton.y = 396;
    [launchInviteButton setTitle:@"SURE! INVITE FRIENDS" forState:UIControlStateNormal];
    [launchInviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    launchInviteButton.titleLabel.font = [ThemeManager boldFontOfSize:14];
    [launchInviteButton addTarget:self action:@selector(dismissAndOpenInviteView) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:launchInviteButton];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 438;
    [self.doneButton setTitle:@"Not right now" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
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

- (void)dismissAndOpenInviteView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundView.alpha = 0;
        CGFloat angle = -M_1_PI + (float) random()/RAND_MAX *2*M_1_PI;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
        transform = CGAffineTransformRotate(transform, angle);
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        [self.delegate launchInviteFriends];
        [self removeFromSuperview];
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


@end