//
//  CenterNavigationControllerViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CenterNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "Theme.h"
#import "BeaconManager.h"
#import "AppDelegate.h"

@interface CenterNavigationController ()

@property (readonly) MSDynamicsDrawerDirection openDirection;

@end

@implementation CenterNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.size = CGSizeMake(30, 30);
    [self menuButtonDefaultMode];
    [self.menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchDown];
    
    [[BeaconManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(beacons)) options:0 context:NULL];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[BeaconManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(beacons))];
}

- (MSDynamicsDrawerDirection)openDirection
{
    MSDynamicsDrawerDirection openDirection = MSDynamicsDrawerDirectionNone;
    if ([AppDelegate sharedAppDelegate].sideNavigationViewController.paneView.x > 0) {
        openDirection = MSDynamicsDrawerDirectionLeft;
    }
    else {
        openDirection = MSDynamicsDrawerDirectionRight;
    }
    return openDirection;
}

- (void)menuButtonTouched:(id)sender
{
    [self toggleSideNav:MSDynamicsDrawerDirectionLeft];
}

- (void)toggleSideNav:(MSDynamicsDrawerDirection)direction
{
    MSDynamicsDrawerPaneState paneState = [AppDelegate sharedAppDelegate].sideNavigationViewController.paneState == MSDynamicsDrawerPaneStateClosed ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateClosed;
    [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneState:paneState inDirection:direction animated:YES allowUserInterruption:YES completion:nil];
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
        }
        jadispatch_main_qeue(^{
            [self updateMenuButton:beaconCount];
        });
    }
}

- (void)updateMenuButton:(NSInteger)beaconCount
{
    BOOL wasSelected = self.menuButton.selected;
    BOOL isSelected = beaconCount > 0;
    BOOL modeChange = wasSelected != isSelected;
    BOOL numberChange = wasSelected && [self.menuButton titleForState:UIControlStateNormal].integerValue != beaconCount;
    if (modeChange) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuButton.alpha = 0;
        } completion:^(BOOL finished) {
            if (isSelected) {
                [self menuButtonCountMode:beaconCount];
            }
            else {
                [self menuButtonDefaultMode];
            }
            [UIView animateWithDuration:0.2 animations:^{
                self.menuButton.alpha = 1;
            }];
        }];
    }
    else if (numberChange) {
        [self menuButtonCountMode:beaconCount];
    }
}

- (void)menuButtonDefaultMode
{
    [self.menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    [self.menuButton setTitle:nil forState:UIControlStateNormal];
    self.menuButton.backgroundColor = [UIColor clearColor];
    self.menuButton.layer.cornerRadius = 0;
    self.menuButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.menuButton.titleLabel.font = [ThemeManager regularFontOfSize:20];
    self.menuButton.selected = NO;
}

- (void)menuButtonCountMode:(NSInteger)beaconCount
{
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton setTitle:@(beaconCount).stringValue forState:UIControlStateSelected];
    [self.menuButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateSelected];
    self.menuButton.backgroundColor = [UIColor whiteColor];
    self.menuButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.menuButton.layer.cornerRadius = 9;
    self.menuButton.selected = YES;
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
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    jadispatch_after_delay(0.1, dispatch_get_main_queue(), ^{
        MSDynamicsDrawerDirection direction = MSDynamicsDrawerDirectionLeft;
        [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneState:MSDynamicsDrawerPaneStateClosed inDirection:direction animated:YES allowUserInterruption:NO completion:nil];
    });
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
        [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionLeft];
    }
    else {
        viewController.navigationItem.hidesBackButton = YES;
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        [[AppDelegate sharedAppDelegate].sideNavigationViewController setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionLeft];
    }
}


@end
