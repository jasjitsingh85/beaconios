//
//  CenterNavigationControllerViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CenterNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "Theme.h"
#import "BeaconManager.h"
#import "AppDelegate.h"

@interface CenterNavigationController ()

@property (strong, nonatomic) UIButton *menuButton;

@end

@implementation CenterNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.size = CGSizeMake(25, 25);
    [self updateMenuButton:0];
    [self.menuButton addTarget:self action:@selector(toggleSideNav) forControlEvents:UIControlEventTouchDown];
    
    [[BeaconManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(beacons)) options:0 context:NULL];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[BeaconManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(beacons))];
}

- (void)toggleSideNav
{
    MSDynamicsDrawerPaneState paneState = [AppDelegate sharedAppDelegate].sideNavigationViewController.paneState == MSDynamicsDrawerPaneStateClosed ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed;
    [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneState:paneState inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == [BeaconManager sharedManager]) {
        NSInteger beaconCount = 0;
        if ([BeaconManager sharedManager].beacons) {
            beaconCount = [BeaconManager sharedManager].beacons.count;
            jadispatch_main_qeue(^{
                [self updateMenuButton:beaconCount];
            });

        }
    }
}

- (void)updateMenuButton:(NSInteger)beaconCount
{
    if (!beaconCount) {
        [self.menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
        [self.menuButton setTitle:nil forState:UIControlStateNormal];
        self.menuButton.backgroundColor = [UIColor clearColor];
        self.menuButton.layer.cornerRadius = 0;
    }
    else {
        [self.menuButton setImage:nil forState:UIControlStateNormal];
        [self.menuButton setTitle:@(beaconCount).stringValue forState:UIControlStateNormal];
        [self.menuButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
        self.menuButton.backgroundColor = [UIColor whiteColor];
        self.menuButton.layer.cornerRadius = 4;
    }
}

#pragma mark - setters
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
    if (!animated) {
        [self setSelectedViewController:selectedViewController];
        return;
    }
    UIGraphicsBeginImageContextWithOptions(self.topViewController.view.bounds.size, YES, 0.0f);
    [self.topViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [selectedViewController.view addSubview:imageView];
    _selectedViewController = selectedViewController;
    self.viewControllers = @[selectedViewController];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneState:MSDynamicsDrawerPaneStateClosed inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:NO completion:nil];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    _selectedViewController = self.selectedViewController;
    self.viewControllers = @[selectedViewController];
}

#pragma mark - UINavigationBarDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL showMenuButton = self.viewControllers.count == 1;
    if (showMenuButton) {
        viewController.navigationItem.hidesBackButton = NO;
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionLeft];
    }
    else {
        viewController.navigationItem.hidesBackButton = YES;
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionLeft];
    }
}


@end
