//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "HelpPopupView.h"
#import "Theme.h"
#import "APIClient.h"
#import "LoadingIndictor.h"
#import "Deal.h"
#import "Beacon.h"
#import "DealStatus.h"
#import "Venue.h"

@interface HelpPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;

@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *textLabel;

@end

@implementation HelpPopupView
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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shortModalBackground"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    self.chatBubble = [[UIImageView alloc] init];
    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor whiteColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:5.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    self.headerTitle = [[UILabel alloc] init];
    self.headerTitle.height = 30;
    self.headerTitle.width = self.width;
    self.headerTitle.textAlignment = NSTextAlignmentCenter;
    self.headerTitle.font = [ThemeManager boldFontOfSize:11];
    self.headerTitle.y = 185;
    [self.imageView addSubview:self.headerTitle];
    
    UIButton *faqButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faqButton.frame = CGRectMake(25, 290, self.width - 50, 25);
    [faqButton setTitle:@"Read FAQ" forState:UIControlStateNormal];
    faqButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
    faqButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [faqButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:1.] forState:UIControlStateNormal];
    [faqButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    //        self.openYelpButton.layer.cornerRadius = 3;
    //        self.openYelpButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
    //        self.openYelpButton.layer.borderWidth = 1.5;
    [faqButton addTarget:self action:@selector(faqButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:faqButton];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.width - 110, 100)];
    self.textLabel.centerX = self.width/2;
    self.textLabel.font = [ThemeManager lightFontOfSize:12];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 5;
    [self.imageView addSubview:self.textLabel];
    
    
    UIButton *launchInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    launchInviteButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    launchInviteButton.size = CGSizeMake(200, 30);
    launchInviteButton.layer.cornerRadius = 3;
    launchInviteButton.centerX = (self.width/2.0) - .75;
    launchInviteButton.y = 330;
    [launchInviteButton setTitle:@"GOT IT" forState:UIControlStateNormal];
    [launchInviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    launchInviteButton.titleLabel.font = [ThemeManager boldFontOfSize:14];
    [launchInviteButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:launchInviteButton];
    
    return self;
}

-(void)showHotspotExplanationModal
{
    self.headerTitle.text = @"WHAT IS A HOTSPOT?";
    self.textLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from bars, giving you access to exclusive drink specials. Get craft beers, cocktails, or shots for as little as $1, and never wait for the check when paying with Hotspot."];
    
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

-(void)showFeeExplanationModal
{
    self.headerTitle.text = @"HOW DO RESERVATIONS WORK?";
    self.textLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from to save you time and money. Present this green voucher to your server - they'll tap it as payment for your drink."];
    
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

- (void)showFeaturedEventExplanationModal
{
    self.headerTitle.text = @"WHAT IS A FEATURED EVENT?";
    self.textLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from to save you time and money. Present this green voucher to your server - they'll tap it as payment for your drink."];
    
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

-(void) faqButtonTouched:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundView.alpha = 0;
        CGFloat angle = -M_1_PI + (float) random()/RAND_MAX *2*M_1_PI;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
        transform = CGAffineTransformRotate(transform, angle);
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFaq" object:self];
    }];
}

@end