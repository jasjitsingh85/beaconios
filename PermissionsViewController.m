//
//  PermissionsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 11/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "PermissionsViewController.h"
#import "Theme.h"
#import "ContactManager.h"
#import "PushNotificationManager.h"
#import "AppDelegate.h"

typedef enum {
    ViewModeContact=0,
    ViewModePush,
} ViewMode;

@interface PermissionsViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *subtitles;
@property (strong, nonatomic) UIButton *confirmButton;
@property (assign, nonatomic) ViewMode viewMode;

@end

@implementation PermissionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"orangeBackground"]];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNav"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 30;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    CGRect titleLabelFrame;
    titleLabelFrame.size = CGSizeMake(300, 30);
    titleLabelFrame.origin.x = 0.5*(self.view.frame.size.width - titleLabelFrame.size.width);
    titleLabelFrame.origin.y = 100;
    self.titleLabel.frame = titleLabelFrame;
    self.titleLabel.font = [ThemeManager regularFontOfSize:27];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor colorWithRed:162/255.0 green:211/255.0 blue:156/255.0 alpha:1.0];
    UIColor *confirmButtonColor = [UIColor colorWithRed:108/255.0 green:124/255.0 blue:146/255.0 alpha:1.0];
    [self.confirmButton setTitleColor:[confirmButtonColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.confirmButton setTitleColor:confirmButtonColor forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 4;
    CGRect confirmButtonFrame;
    confirmButtonFrame.size  = CGSizeMake(200, 35);
    confirmButtonFrame.origin.x = 0.5*(self.view.frame.size.width - confirmButtonFrame.size.width);
    confirmButtonFrame.origin.y = 400;
    self.confirmButton.frame = confirmButtonFrame;
    [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
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
        labelFrame.size = CGSizeMake(300, 30);
        labelFrame.origin.x = 0.5*(self.view.frame.size.width - labelFrame.size.width);
        labelFrame.origin.y = 160 + 40*i;
        label.frame = labelFrame;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [ThemeManager lightFontOfSize:16];
        [subtitleLabels addObject:label];
    }
    return subtitleLabels;
}

- (void)enterContactsMode
{
    self.viewMode = ViewModeContact;
    self.titleLabel.text = @"Add Friends From Your Contacts";
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"Instantly builds your friend list",
                                                      @"Find friends already on the app",
                                                      @"Invite friends to your events",
                                                      @"Required to use the app"]];
    [self animateInSubtitles:nil];
}

- (void)enterPushNotificationMode
{
    self.viewMode = ViewModePush;
    self.titleLabel.text = @"Push It Good";
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"Instantly get invites to friends events",
                                                      @"Chat with friends in real-time"]];
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
                [[AppDelegate sharedAppDelegate] contactAuthorizationStatusDenied];
            });
        }];
    }
    else if (self.viewMode == ViewModePush) {
        [[PushNotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
            [self finishPermissions];
        } failure:^(NSError *error) {
            [self finishPermissions];
        }];
    }
}

- (void)finishPermissions
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasFinishedPermissions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AppDelegate sharedAppDelegate] didFinishPermissions];
}


@end
