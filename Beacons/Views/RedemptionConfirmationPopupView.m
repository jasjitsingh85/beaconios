//
//  RewardExplanationPopupView.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "RedemptionConfirmationPopupView.h"
#import "Theme.h"
#import "SponsoredEvent.h"

@interface RedemptionConfirmationPopupView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *textBody;
@property (strong, nonatomic) UISegmentedControl *tipControl;
@property (strong, nonatomic) NSNumber *tipAmount;
@property (strong, nonatomic) NSNumber *totalAmount;

@end

@implementation RedemptionConfirmationPopupView

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
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"confirmationBackground"]];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 30;
    headerTitle.x = 0;
    headerTitle.width = self.width;
    headerTitle.textAlignment = NSTextAlignmentCenter;
    //self.headerTitle.centerX = self.tableView.width/2;
    headerTitle.font = [ThemeManager boldFontOfSize:12];
    headerTitle.y = 185;
    headerTitle.numberOfLines = 1;
    headerTitle.text = @"CONFIRMATION";
    [self.imageView addSubview:headerTitle];
    
    self.textBody = [[UILabel alloc] init];
    self.textBody.height = 60;
    self.textBody.x = 50;
    self.textBody.width = 200;
    self.textBody.textAlignment = NSTextAlignmentCenter;
    self.textBody.font = [ThemeManager lightFontOfSize:12];
    self.textBody.y = 205;
    self.textBody.numberOfLines = 0;
    [self.imageView addSubview:self.textBody];
    
    UIButton *launchInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    launchInviteButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    launchInviteButton.size = CGSizeMake(200, 30);
    launchInviteButton.centerX = (self.width/2.0);
    launchInviteButton.y = 332;
    launchInviteButton.layer.cornerRadius = 3;
    [launchInviteButton setTitle:@"CONFIRM" forState:UIControlStateNormal];
    [launchInviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [launchInviteButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    launchInviteButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
    [launchInviteButton addTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:launchInviteButton];
    
    self.tipControl = [[UISegmentedControl alloc] initWithItems:@[@"NO TIP", @"$1", @"$2", @"$3"]];
    [self.tipControl setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor unnormalizedColorWithRed:112 green:112 blue:112 alpha:255], NSFontAttributeName : [ThemeManager boldFontOfSize:10]} forState:UIControlStateNormal];
    [self.tipControl setSelectedSegmentIndex:0];
    self.tipControl.width = 200;
    self.tipControl.height = 30;
    self.tipControl.centerX = self.width/2;
    self.tipControl.tintColor = [[ThemeManager sharedTheme] redColor];
    self.tipControl.y = 278;
    [self.tipControl addTarget:self
                         action:@selector(segmentedControlSelectedIndexChanged:)
               forControlEvents:UIControlEventValueChanged];
    [self.imageView addSubview:self.tipControl];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //self.doneButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.size = CGSizeMake(230, 25);
    self.doneButton.centerX = self.width/2.0;
    self.doneButton.y = 365;
    [self.doneButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [ThemeManager regularFontOfSize:13];
    [self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.doneButton];
    
    
    return self;
}

-(void)computeTotalAndUpdateText
{
    self.tipAmount = [NSNumber numberWithInteger:self.tipControl.selectedSegmentIndex];
    self.totalAmount = [NSNumber numberWithFloat:([self.tipAmount floatValue] + [self.sponsoredEvent.itemPrice floatValue])];
    [self updateBodyText];
}

- (void)segmentedControlSelectedIndexChanged:(id)sender {
    [self computeTotalAndUpdateText];
}

-(void)updateBodyText {
    self.textBody.text = [NSString stringWithFormat:@"Add a tip for bar-staff so you don't have to bring cash. You'll be charged $%@ when you tap 'CONFIRM'", self.totalAmount];
}

-(void)setSponsoredEvent:(SponsoredEvent *)sponsoredEvent
{
    _sponsoredEvent = sponsoredEvent;
    
    [self computeTotalAndUpdateText];
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

- (void)confirmPurchase:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundView.alpha = 0;
        CGFloat angle = -M_1_PI + (float) random()/RAND_MAX *2*M_1_PI;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
        transform = CGAffineTransformRotate(transform, angle);
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.tipAmount forKey:@"tipAmount"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kConfirmPurchase object:self userInfo:userInfo];
        [self removeFromSuperview];
    }];
}


@end