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
#import "PaymentsViewController.h"

typedef enum {
    ViewModePush=0,
    ViewModeContact,
    ViewModePayment,
} ViewMode;

@interface PermissionsViewController () <RegistrationViewControllerDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *subtitles;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIImageView *hotbotImageView;
@property (strong, nonatomic) UIImageView *headerIcon;
@property (strong, nonatomic) UIView *permissionTextContainer;
@property (assign, nonatomic) ViewMode viewMode;
@property (strong, nonatomic) PaymentsViewController *paymentsViewController;

@end

@implementation PermissionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:231/255. green:231/255. blue:231/255. alpha:1];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNavBlack"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.size.width = 75;
    logoFrame.size.height = 25;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 40;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
//    UIView *permissionsBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.width, 400)];
//    permissionsBackground.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:permissionsBackground];
    
    [[APIClient sharedClient] getClientToken:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *clientToken = responseObject[@"client_token"];
        self.paymentsViewController = [[PaymentsViewController alloc] initWithClientToken:clientToken];
        self.paymentsViewController.onlyAddPayment = YES;
        //self.paymentsViewController.beaconProfileViewController = self;
        //self.paymentsViewController.beaconID = self.beacon.beaconID;
        [self addChildViewController:self.paymentsViewController];
        //[self.view addSubview:self.paymentsViewController.view];
        self.paymentsViewController.view.frame = self.view.bounds;
        self.paymentsViewController.delegate = self;
        self.paymentsViewController.inRegFlow = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
    
    self.permissionTextContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 75, self.view.size.width, 300)];
    self.permissionTextContainer.backgroundColor = [UIColor whiteColor];
    self.permissionTextContainer.clipsToBounds = YES;
    [self.view addSubview:self.permissionTextContainer];
    
    
    self.headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactPermissions"]];
//    self.headerIcon.size = CGSizeMake(30, 30);
    self.headerIcon.y = 110;
    self.headerIcon.centerX = self.view.width/2;
    [self.permissionTextContainer addSubview:self.headerIcon];
    
    self.titleLabel = [[UILabel alloc] init];
    CGRect titleLabelFrame;
    titleLabelFrame.size = CGSizeMake(self.view.width, 23);
    titleLabelFrame.origin.x = 0;
    titleLabelFrame.origin.y = 20;
    self.titleLabel.frame = titleLabelFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [ThemeManager regularFontOfSize:18];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textColor = [UIColor unnormalizedColorWithRed:54 green:54 blue:54 alpha:230];
    [self.permissionTextContainer addSubview:self.titleLabel];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor]
    ;
    UIColor *confirmButtonColor = [UIColor whiteColor];
    [self.confirmButton setTitleColor:[confirmButtonColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.confirmButton setTitleColor:confirmButtonColor forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 4;
    CGRect confirmButtonFrame;
    confirmButtonFrame.size  = CGSizeMake(240, 40);
    confirmButtonFrame.origin.x = 0.5*(self.view.frame.size.width - confirmButtonFrame.size.width);
    confirmButtonFrame.origin.y = 500;
    self.confirmButton.frame = confirmButtonFrame;
    [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor colorWithRed:91/255.0 green:91/255.0 blue:91/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.skipButton.backgroundColor = [UIColor clearColor];
//    self.skipButton.layer.cornerRadius = self.confirmButton.layer.cornerRadius;
//    self.skipButton.layer.borderColor = [UIColor colorWithRed:91/255.0 green:91/255.0 blue:91/255.0 alpha:1.0].CGColor;
//    self.skipButton.layer.borderWidth = 2;
    //self.skipButton.layer.cornerRadius = 4;
    CGRect skipButtonFrame = CGRectMake(self.confirmButton.frame.origin.x + self.confirmButton.frame.size.width/4, self.confirmButton.frame.origin.y, self.confirmButton.frame.size.width/2, self.confirmButton.frame.size.height - 10);
    skipButtonFrame.origin.y = CGRectGetMaxY(self.confirmButton.frame) + 15;
    self.skipButton.frame = skipButtonFrame;
    self.skipButton.titleLabel.font = [ThemeManager regularFontOfSize:14];
    [self.skipButton addTarget:self action:@selector(skipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipButton];
    
//    self.hotbotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotbotSmile"]];
//        self.hotbotImageView.transform = CGAffineTransformRotate(self.hotbotImageView.transform, M_PI/15.0);
//    self.hotbotImageView.transform = CGAffineTransformScale(self.hotbotImageView.transform, 1.2, 1.2);
//    self.hotbotImageView.transform = CGAffineTransformTranslate(self.hotbotImageView.transform, 0, 20);
//    [self.view addSubview:self.hotbotImageView];
    
    [self enterContactsMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPermissions:) name:kFinishPermissionsAfterPayment object:nil];
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
        if (self.viewMode == ViewModePush) {
            labelFrame.origin.y = 100 + 50*i;
            labelFrame.size = CGSizeMake(self.view.width - 100, 100);
            labelFrame.origin.x = 50;
        } else if (self.viewMode == ViewModePayment){
            labelFrame.origin.y = 100 + 50*i;
            labelFrame.size = CGSizeMake(self.view.width - 50, 100);
            labelFrame.origin.x = 25;
        } else {
            labelFrame.origin.y = 100 + 50*i;
            labelFrame.size = CGSizeMake(self.view.width - 100, 100);
            labelFrame.origin.x = 50;
        }
        label.frame = labelFrame;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor unnormalizedColorWithRed:54 green:54 blue:54 alpha:190];
        label.font = [ThemeManager lightFontOfSize:16];
        [subtitleLabels addObject:label];
    }
    return subtitleLabels;
}

- (void)enterPaymentsMode
{
    self.viewMode = ViewModePayment;
    self.titleLabel.text = @"LINK PAYMENT";
    [self.headerIcon setImage: [UIImage imageNamed:@"paymentPermissions"]];
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"Hotspot buys drinks wholesale from bars, saving you time and money when you buy through the app."]];
    [self.confirmButton setTitle:@"Link Payment" forState:UIControlStateNormal];
    [self.skipButton setTitle:@"I'll do it later" forState:UIControlStateNormal];
    self.confirmButton.y = 395;
    self.skipButton.y = CGRectGetMaxY(self.confirmButton.frame) + 10;
    [self animateInSubtitles:nil];
}

- (void)enterPushNotificationMode
{
    self.viewMode = ViewModePush;
    self.titleLabel.text = @"ENABLE NOTIFICATIONS";
    [self.headerIcon setImage: [UIImage imageNamed:@"pushPermissions"]];
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"To receive messages and invitations in real-time. We don't spam you or your friends."]];
    [self.confirmButton setTitle:@"Enable Push" forState:UIControlStateNormal];
    [self animateInSubtitles:nil];
}

- (void)enterContactsMode
{
    self.viewMode = ViewModeContact;
    self.titleLabel.text = @"SEE FRIENDS";
    [self.headerIcon setImage: [UIImage imageNamed:@"contactPermissions"]];
    [self removeSubtitleLabels];
    self.subtitles = [self subtitleLabelsForStrings:@[@"Sync contacts to see where friends are hanging out and get invitations to meet up."]];
    [self.confirmButton setTitle:@"Sync Contacts" forState:UIControlStateNormal];
    [self.skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
    self.confirmButton.y = 395;
    self.skipButton.y = CGRectGetMaxY(self.confirmButton.frame) + 10;
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
    if (self.viewMode == ViewModePayment) {
        [self.paymentsViewController openPaymentModalToAddPayment];
    }
    else if (self.viewMode == ViewModePush) {
        [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
            [self enterPaymentsMode];
        } failure:^(NSError *error) {
            [self enterPaymentsMode];
        }];
    } else if (self.viewMode == ViewModeContact)
    {
        [self requestContactPermissions];
    }
}

- (void)skipButtonTouched:(id)sender
{
    if (self.viewMode == ViewModePayment) {
        [self finishPermissions];
    }
    else if (self.viewMode == ViewModePush) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Are You Sure?" message:@"Without push notifications you may miss invites to your friends' events"];
        [alertView bk_addButtonWithTitle:@"Enable Push" handler:^{
            [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:^(NSData *devToken) {
                [self enterPaymentsMode];
            } failure:^(NSError *error) {
                [self enterPaymentsMode];;
            }];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Skip" handler:^{
            [self enterPaymentsMode];
        }];
        [alertView show];
    } else if (self.viewMode == ViewModeContact)
    {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Are You Sure?" message:@"Without syncing contacts you won't see invitations, check-ins, and messages from friends"];
        [alertView bk_addButtonWithTitle:@"Sync Contacts" handler:^{
            [self requestContactPermissions];
        }];
        [alertView bk_setCancelButtonWithTitle:@"Skip" handler:^{
            [self enterPushNotificationMode];
        }];
        [alertView show];
    }
}

-(void)requestContactPermissions
{
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

- (void)finishPermissions
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasFinishedPermissions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AppDelegate sharedAppDelegate] didFinishPermissions];
}


@end
