//
//  SettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FriendsViewController.h"
#import "AppDelegate.h"
#import "Theme.h"
#import "UIButton+HSNavButton.h"
#import "NavigationBarTitleLabel.h"
#import "APIClient.h"
#import "LoadingIndictor.h"
#import "FriendsTableViewController.h"
#import "FindFriendsPopupView.h"
#import "ContactManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FriendsViewController ()

@property (strong, nonatomic) FriendsTableViewController *friendsTableViewController;
@property (strong, nonatomic) FindFriendsPopupView *modal;
@property (strong, nonatomic) UIView *syncContactsButtonContainer;
@property (strong, nonatomic) UIButton *syncContactsButton;

@end

@implementation FriendsViewController

- (id)initWithModal
{
    self = [super init];
    if (self) {
        UIButton *applyButton = [UIButton navButtonBoldWithTitle:@"Done"];
        [applyButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:applyButton];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Friends"];
    
    self.friendsTableViewController = [[FriendsTableViewController alloc] init];
    [self addChildViewController:self.friendsTableViewController];
    [self.view addSubview:self.friendsTableViewController.view];
    self.friendsTableViewController.view.frame = self.view.bounds;
    
    self.syncContactsButtonContainer = [[UIView alloc] init];
    self.syncContactsButtonContainer.backgroundColor = [UIColor whiteColor];
    self.syncContactsButtonContainer.width = self.view.width;
    self.syncContactsButtonContainer.height = 50;
    self.syncContactsButtonContainer.y = self.view.height - 50;
    self.syncContactsButtonContainer.userInteractionEnabled = YES;
    
    self.syncContactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.syncContactsButton.size = CGSizeMake(self.view.width - 50, 30);
    self.syncContactsButton.centerX = self.view.width/2.0;
    self.syncContactsButton.y = 10;
    self.syncContactsButton.layer.cornerRadius = 3;
    self.syncContactsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.syncContactsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.syncContactsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    //    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
    //    topBorder.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    UIImageView *topBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropShadowTopBorder"]];
    topBorder.y = -8;
    [self.syncContactsButtonContainer addSubview:topBorder];
    [self.syncContactsButton setImage:[UIImage imageNamed:@"friendsWhite"] forState:UIControlStateNormal];
    self.syncContactsButton.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [self.syncContactsButton addTarget:self action:@selector(showSetupModal) forControlEvents:UIControlEventTouchUpInside];
    [self.syncContactsButton setTitle:@"  FIND FRIENDS" forState:UIControlStateNormal];
    
    [self.syncContactsButtonContainer addSubview:self.syncContactsButton];
    
    [self.view addSubview:self.syncContactsButtonContainer];
    
    self.modal = [[FindFriendsPopupView alloc] init];
    
    [self updateSetupNewsfeedButtonContainer];
}

-(void) updateSetupNewsfeedButtonContainer
{
    if ([self hasAcceptedPermissions]) {
        self.syncContactsButtonContainer.hidden = YES;
    } else {
        self.syncContactsButtonContainer.hidden = NO;
    }
}

-(BOOL) hasAcceptedPermissions
{
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if ([FBSDKAccessToken currentAccessToken] && contactAuthStatus != kABAuthorizationStatusNotDetermined) {
        return YES;
    } else {
        return NO;
    }
    
}

-(void)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showSetupModal
{
    [self.modal show];
}

- (void) hideSetupModal
{
    [self.modal dismissSetupModal];
}

@end
