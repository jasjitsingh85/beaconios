//
//  PermissionsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 11/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "PermissionsViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "Theme.h"
#import "ContactManager.h"
#import "NotificationManager.h"
#import "AppDelegate.h"

typedef enum {
    ViewModeContact=0,
    ViewModePush,
} ViewMode;

@interface PermissionsViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *subtitles;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIImageView *hotbotImageView;
@property (assign, nonatomic) ViewMode viewMode;

@end

@implementation PermissionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"waveBackground"]];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNav"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 30;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    CGRect titleLabelFrame;
    titleLabelFrame.size = CGSizeMake(300, 23);
    titleLabelFrame.origin.x = 134;
    titleLabelFrame.origin.y = 82;
    self.titleLabel.frame = titleLabelFrame;
    self.titleLabel.font = [ThemeManager regularFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textColor = [UIColor unnormalizedColorWithRed:234 green:118 blue:90 alpha:255];
    [self.view addSubview:self.titleLabel];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor colorWithRed:162/255.0 green:211/255.0 blue:156/255.0 alpha:1.0];
    UIColor *confirmButtonColor = [UIColor colorWithRed:108/255.0 green:124/255.0 blue:146/255.0 alpha:1.0];
    [self.confirmButton setTitleColor:[confirmButtonColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.confirmButton setTitleColor:confirmButtonColor forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 4;
    CGRect confirmButtonFrame;
    confirmButtonFrame.size  = CGSizeMake(242, 35);
    confirmButtonFrame.origin.x = 0.5*(self.view.frame.size.width - confirmButtonFrame.size.width);
    confirmButtonFrame.origin.y = 360;
    self.confirmButton.frame = confirmButtonFrame;
    [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor colorWithRed:91/255.0 green:91/255.0 blue:91/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.skipButton.backgroundColor = [UIColor clearColor];
    self.skipButton.layer.cornerRadius = self.confirmButton.layer.cornerRadius;
    self.skipButton.layer.borderColor = [UIColor colorWithRed:91/255.0 green:91/255.0 blue:91/255.0 alpha:1.0].CGColor;
    self.skipButton.layer.borderWidth = 2;
    self.skipButton.layer.cornerRadius = 4;
    CGRect skipButtonFrame = self.confirmButton.frame;
    skipButtonFrame.origin.y = CGRectGetMaxY(self.confirmButton.frame) + 30;
    self.skipButton.frame = skipButtonFrame;
    [self.skipButton addTarget:self action:@selector(skipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipButton];
    
    self.hotbotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotbotSmile"]];
        self.hotbotImageView.transform = CGAffineTransformRotate(self.hotbotImageView.transform, M_PI/15.0);
    self.hotbotImageView.transform = CGAffineTransformScale(self.hotbotImageView.transform, 1.2, 1.2);
    self.hotbotImageView.transform = CGAffineTransformTranslate(self.hotbotImageView.transform, 0, 20);
    [self.view addSubview:self.hotbotImageView];
    
    [self enterContactsMode];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSArray *)subtitleLabelsForStrings:(NSArray *)strings
{
    NSMutableArray *subtitleLabels = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<strings.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = strings[i];
        CGRect labelFrame;
        labelFrame.size = CGSizeMake(150, 50);
        labelFrame.origin.x = self.titleLabel.frame.origin.x;
        labelFrame.origin.y = 120 + 50*i;
        label.frame = labelFrame;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        label.font = [ThemeManager lightFontOfSize:14];
        [subtitleLabels addObject:label];
    }
    return subtitleLabels;
}

- (void)enterContactsMode
{
    self.viewMode = ViewModeContact;
    self.titleLabel.text = @"Sync Contacts!";
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"So you can invite friends to events"]];
    [self.confirmButton setTitle:@"Sync Contacts" forState:UIControlStateNormal];
    [self animateInSubtitles:nil];
}

- (void)enterPushNotificationMode
{
    self.viewMode = ViewModePush;
    self.titleLabel.text = @"Push It.";
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"Get invitations to events and chat in real-time"]];
    [self.confirmButton setTitle:@"Enable Push" forState:UIControlStateNormal];
    [self animateInSubtitles:nil];
}

- (void)removeSubtitleLabels
{
    for (UILabel *label in self.subtitles) {
        [label removeFromSuperview];
    }
}

- (void)animateOutSubtitles:(void (^)())completion
{
    if (!self.subtitles || !self.subtitles.count) {
        completion();
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        for (UILabel *label in self.subtitles) {
            label.alpha = 0;
        }
    } completion:^(BOOL finished) {
        for (UILabel *label in self.subtitles) {
            [label removeFromSuperview];
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)animateInSubtitles:(void (^)())completion
{
    for (NSInteger i=0; i<self.subtitles.count; i++) {
        UILabel *label = self.subtitles[i];
        [self.view addSubview:label];
        label.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration delay:0.3*i usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)confirmButtonTouched:(id)sender
{
    if (self.viewMode == ViewModeContact) {
        [[ContactManager sharedManager] requestContactPermissions:^{
            jadispatch_main_qeue(^{
                [self enterPushNotificationMode];
            });
        } failure:^(NSError *error) {
            jadispatch_main_qeue(^{
                [self enterPushNotificationMode];
            });
        }];
    }
    else if (self.viewMode == ViewModePush) {
        [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
            [self finishPermissions];
        } failure:^(NSError *error) {
            [self finishPermissions];
        }];
    }
}

- (void)skipButtonTouched:(id)sender
{
    if (self.viewMode == ViewModeContact) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Are You Sure?" message:@"Without syncing contacts you can't set Hotspots and invite friends"];
        [alertView bk_addButtonWithTitle:@"Sync Contacts" handler:^{
            [[ContactManager sharedManager] requestContactPermissions:^{
                jadispatch_main_qeue(^{
                    [self enterPushNotificationMode];
                });
            } failure:^(NSError *error) {
                jadispatch_main_qeue(^{
                    [self enterPushNotificationMode];
                });
            }];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Skip" handler:^{
            [self enterPushNotificationMode];
        }];
        [alertView show];
    }
    else if (self.viewMode == ViewModePush) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Are You Sure?" message:@"Without push notifications you may miss invites to your friends' events"];
        [alertView bk_addButtonWithTitle:@"Enable Push" handler:^{
            [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
                [self finishPermissions];
            } failure:^(NSError *error) {
                [self finishPermissions];
            }];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Skip" handler:^{
            [self finishPermissions];
        }];
        [alertView show];
    }
}

- (void)finishPermissions
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasFinishedPermissions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AppDelegate sharedAppDelegate] didFinishPermissions];
}


@end
