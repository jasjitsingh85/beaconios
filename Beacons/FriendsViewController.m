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

@interface FriendsViewController ()

@property (strong, nonatomic) FriendsTableViewController *friendsTableViewController;

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
    
}

-(void)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
