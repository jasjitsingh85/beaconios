//
//  AppDelegate.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "MapViewController.h"
#import "MenuViewController.h"

@implementation AppDelegate

- (CenterNavigationController *)centerNavigationController
{
    if (!_centerNavigationController) {
        _centerNavigationController = [[CenterNavigationController alloc] init];
    }
    return _centerNavigationController;
}

- (IIViewDeckController *)sideNavigationViewController
{
    if (!_sideNavigationViewController) {
        _sideNavigationViewController = [[IIViewDeckController alloc] init];
        _sideNavigationViewController.openSlideAnimationDuration = 0.2;
        _sideNavigationViewController.closeSlideAnimationDuration = 0.2;
        _sideNavigationViewController.panningMode = IIViewDeckFullViewPanning;
        _sideNavigationViewController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
        _sideNavigationViewController.leftSize = 150;
    }
    return _sideNavigationViewController;
}

- (MapViewController *)mapViewController
{
    if (!_mapViewController) {
        _mapViewController = [MapViewController new];
    }
    return _mapViewController;
}

- (MenuViewController *)menuViewController
{
    if (!_menuViewController) {
        _menuViewController = [MenuViewController new];
    }
    return _menuViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.centerNavigationController.selectedViewController = self.mapViewController;
    self.sideNavigationViewController.centerController = self.centerNavigationController;
    self.sideNavigationViewController.leftController = self.menuViewController;
    self.window.rootViewController = self.sideNavigationViewController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
