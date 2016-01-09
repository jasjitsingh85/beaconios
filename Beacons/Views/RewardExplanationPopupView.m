//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "RewardExplanationPopupView.h"
#import "Theme.h"

@interface RewardExplanationPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;

@end

@implementation RewardExplanationPopupView

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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paymentExplanation"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    self.chatBubble = [[UIImageView alloc] init];
    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor whiteColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:5.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 55);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 436;
    [self.doneButton setTitle:@"Got it. Let's go!" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.layer.cornerRadius = 8;
    self.doneButton.titleLabel.font = [ThemeManager lightFontOfSize:1.3*18];
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