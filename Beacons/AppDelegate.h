//
//  AppDelegate.h
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ViewDeck/IIViewDeckController.h>

@class CenterNavigationController,
LoginViewController,
MapViewController,
MenuViewController,
SetBeaconViewController,
BeaconDetailViewController,
User,
Beacon;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CenterNavigationController *centerNavigationController;
@property (strong, nonatomic) IIViewDeckController *sideNavigationViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) SetBeaconViewController *setBeaconViewController;
@property (strong, nonatomic) BeaconDetailViewController *myBeaconViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;

+ (AppDelegate *)sharedAppDelegate;
- (void)registeredWithResponse:(NSDictionary *)response;
- (void)loggedIntoServerWithResponse:(NSDictionary *)response;
- (void)logoutOfServer;
- (void)didActivateAccount;
- (void)setSelectedViewControllerToBeaconProfileWithBeacon:(Beacon *)beacon;
- (void)setSelectedViewControllerToBeaconProfileWithID:(NSNumber *)beaconID;

@end
