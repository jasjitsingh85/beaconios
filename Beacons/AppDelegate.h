//
//  AppDelegate.h
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>

@class CenterNavigationController,
LoginViewController,
MapViewController,
MenuViewController,
SetBeaconViewController,
User,
Beacon;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CenterNavigationController *centerNavigationController;
@property (strong, nonatomic) MSDynamicsDrawerViewController *sideNavigationViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) SetBeaconViewController *setBeaconViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;

+ (AppDelegate *)sharedAppDelegate;
- (void)registeredWithResponse:(NSDictionary *)response;
- (void)loggedIntoServerWithResponse:(NSDictionary *)response;
- (void)logoutOfServer;
- (void)didActivateAccount;
- (void)didFinishPermissions;
- (void)contactAuthorizationStatusDenied;
- (void)setSelectedViewControllerToBeaconProfileWithBeacon:(Beacon *)beacon;
- (void)setSelectedViewControllerToBeaconProfileWithID:(NSNumber *)beaconID promptForCheckIn:(BOOL)promptForCheckIn;

@end
