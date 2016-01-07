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
    drinkIcon.y = 257;
    [self.imageView addSubview:drinkIcon];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 30;
    headerTitle.width = self.width;
    headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 280;
    headerTitle.text = @"EARN FREE DRINKS";
    [self.imageView addSubview:headerTitle];
    
    UILabel *headerSubtitle = [[UILabel alloc] init];
    headerSubtitle.height = 30;
    headerSubtitle.width = self.width;
    headerSubtitle.textColor = [UIColor whiteColor];
    headerSubtitle.textAlignment = NSTextAlignmentCenter;
    headerSubtitle.font = [ThemeManager boldFontOfSize:13];
    headerSubtitle.y = 165;
    headerSubtitle.text = @"REDEEM BY SELECTING A VENUE";
    [self.imageView addSubview:headerSubtitle];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 295, self.width - 110, 80)];
    textLabel.centerX = self.width/2;
    textLabel.font = [ThemeManager lightFontOfSize:12];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 4;
    textLabel.text = @"Invite friends to Hotspot, and you'll both receive a free drink (up to $5) when they use theirs.";
    [self.imageView addSubview:textLabel];
    
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
    launchInviteButton.size = CGSizeMake(240.25, 35);
    launchInviteButton.centerX = (self.width/2.0) - .75;
    launchInviteButton.y = 396;
    [launchInviteButton setTitle:@"INVITE FRIENDS" forState:UIControlStateNormal];
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

- (void) setNumberOfRewardItems:(NSString *)numberOfRewardItems
{
    UILabel *numberOfFreeDrinksHeading = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, self.width - 100, 80)];
    numberOfFreeDrinksHeading.centerX = self.width/2;
    numberOfFreeDrinksHeading.font = [ThemeManager boldFontOfSize:15];
    numberOfFreeDrinksHeading.textColor = [UIColor whiteColor];
    numberOfFreeDrinksHeading.textAlignment = NSTextAlignmentCenter;
    numberOfFreeDrinksHeading.numberOfLines = 1;
    [self.imageView addSubview:numberOfFreeDrinksHeading];
    
    if ([numberOfRewardItems intValue] == 1) {
        numberOfFreeDrinksHeading.text = @"YOU HAVE        FREE DRINK";
    } else {
        numberOfFreeDrinksHeading.text = @"YOU HAVE        FREE DRINKS";
    }
    
    UILabel *numberOfFreeDrinks = [[UILabel alloc] initWithFrame:CGRectMake(127, 117, 40, 80)];
//    numberOfFreeDrinks.centerX = self.width/2;
    numberOfFreeDrinks.font = [ThemeManager boldFontOfSize:24];
    numberOfFreeDrinks.textColor = [UIColor whiteColor];
    numberOfFreeDrinks.textAlignment = NSTextAlignmentCenter;
    numberOfFreeDrinks.numberOfLines = 1;
    numberOfFreeDrinks.text = [NSString stringWithFormat:@"%@", numberOfRewardItems];
    [self.imageView addSubview:numberOfFreeDrinks];
    
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