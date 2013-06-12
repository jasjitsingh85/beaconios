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
CreateBeaconViewController,
BeaconDetailViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CenterNavigationController *centerNavigationController;
@property (strong, nonatomic) IIViewDeckController *sideNavigationViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) CreateBeaconViewController *createBeaconViewController;
@property (strong, nonatomic) BeaconDetailViewController *myBeaconViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;

- (void)loggedInToServerWithUserData:(NSDictionary *)userData;
- (void)logoutOfServer;

@end
