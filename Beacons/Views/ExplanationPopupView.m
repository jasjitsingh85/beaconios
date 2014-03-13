//
//  ExplanationPopupView.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/12/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "ExplanationPopupView.h"
#import "Theme.h"

@interface ExplanationPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *inviteTextView;
@property (strong, nonatomic) UIImageView *chatBubble;

@end

@implementation ExplanationPopupView

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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotExplanation"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    self.chatBubble = [[UIImageView alloc] init];
    [self.imageView addSubview:self.chatBubble];
    
    self.inviteTextView = [[UITextView alloc] init];
    self.inviteTextView.textColor = [UIColor blackColor];
    self.inviteTextView.font = [ThemeManager lightFontOfSize:6.5*1.3];
    [self.chatBubble addSubview:self.inviteTextView];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(232, 39);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 376;
    [self.doneButton setTitle:@"Got it. Let's go!" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.layer.cornerRadius = 8;
    self.doneButton.titleLabel.font = [ThemeManager lightFontOfSize:1.3*15];
    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
    return self;
}

- (void)setAttributedInviteText:(NSAttributedString *)attributedInviteText
{
    _attributedInviteText = attributedInviteText;
    UIImage *chatBubbleImage = [[UIImage imageNamed:@"iMessageChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 45, 20, 45)];
    CGRect textFrame = [attributedInviteText boundingRectWithSize:CGSizeMake(120, 200) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.inviteTextView.frame = textFrame;
    textFrame.size.width  += 24;
    textFrame.size.height += 20;
    textFrame.origin.x = 75;
    textFrame.origin.y = 176;
    self.chatBubble.frame = textFrame;
    self.inviteTextView.frame = self.chatBubble.bounds;
    self.inviteTextView.backgroundColor = [UIColor clearColor];
    self.inviteTextView.center = CGPointMake(self.chatBubble.width/2.0, self.chatBubble.height/2.0);
    self.inviteTextView.textContainerInset = UIEdgeInsetsMake(8.5, 7, 0, 5);
    self.chatBubble.image = chatBubbleImage;
    self.inviteTextView.attributedText = attributedInviteText;
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
