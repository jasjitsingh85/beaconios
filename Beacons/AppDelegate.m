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
#import "LoginViewController.h"
#import "BeaconDetailViewController.h"
#import "CreateBeaconViewController.h"
#import "APIClient.h"
#import "Theme.h"
#import "User.h"

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
        _sideNavigationViewController.leftSize = 235;
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

- (CreateBeaconViewController *)createBeaconViewController
{
    if (!_createBeaconViewController) {
        _createBeaconViewController = [CreateBeaconViewController new];
    }
    return _createBeaconViewController;
}

- (BeaconDetailViewController *)myBeaconViewController
{
    if (!_myBeaconViewController) {
        _myBeaconViewController = [BeaconDetailViewController new];
    }
    return _myBeaconViewController;
}

- (MenuViewController *)menuViewController
{
    if (!_menuViewController) {
        _menuViewController = [MenuViewController new];
    }
    return _menuViewController;
}

- (User *)loggedInUser
{
    if (!_loggedInUser && [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyIsLoggedIn]) {
        _loggedInUser = [User new];
        _loggedInUser.phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyPhone];
        _loggedInUser.firstName = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyFirstName];
        _loggedInUser.lastName = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyLastName];
        _loggedInUser.userID = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyUserID];
    }
    return _loggedInUser;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ThemeManager customizeAppAppearance];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.centerNavigationController.selectedViewController = self.mapViewController;
    self.sideNavigationViewController.centerController = self.centerNavigationController;
    self.sideNavigationViewController.leftController = self.menuViewController;
    self.window.rootViewController = self.sideNavigationViewController;

    [self.window makeKeyAndVisible];
    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyIsLoggedIn];
    if (!isLoggedIn) {
        self.loginViewController = [LoginViewController new];
        UINavigationController *loginNavigationContoller = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
        [self.window.rootViewController presentViewController:loginNavigationContoller animated:NO completion:nil];
    }
    return YES;
}

- (void)loggedIntoServerWithUser:(User *)user
{
    self.loggedInUser = user;
    NSString *firstName = user.firstName;
    if (firstName) {
        [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:kDefaultsKeyFirstName];
    }
    NSString *lastName = user.lastName;
    if (lastName) {
        [[NSUserDefaults standardUserDefaults] setObject:lastName forKey:kDefaultsKeyLastName];
    }
    NSString *email = user.email;
    if (email) {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:kDefaultsKeyEmail];
    }
    NSString *phone = user.phoneNumber;
    if (phone) {
        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:kDefaultsKeyPhone];
    }
    NSNumber *userID = user.userID;
    if (userID) {
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kDefaultsKeyUserID];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.window.rootViewController.presentedViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logoutOfServer
{
    self.loginViewController = [LoginViewController new];
    UINavigationController *loginNavigationContoller = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
    [self.window.rootViewController presentViewController:loginNavigationContoller animated:NO completion:^{
        //nil out any view controllers that have user data associated with them
        self.mapViewController = nil;
    }];
    NSArray *objectsToRemove = @[kDefaultsKeyFirstName,
                                 kDefaultsKeyEmail,
                                 kDefaultsKeyFacebookID,
                                 kDefaultsKeyLastAuthorizationToken,
                                 kDefaultsKeyPhone,
                                 kDefaultsKeyLastName];
    for (NSString *key in objectsToRemove) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDefaultsKeyIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.loggedInUser = nil;
    [[APIClient sharedClient] clearAuthorizationHeader];
    
}

@end
