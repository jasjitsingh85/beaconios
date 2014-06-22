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
MenuViewController,
DealsTableViewController,
SetBeaconViewController,
User,
Beacon,
Deal;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CenterNavigationController *centerNavigationController;
@property (strong, nonatomic) MSDynamicsDrawerViewController *sideNavigationViewController;
@property (strong, nonatomic) SetBeaconViewController *setBeaconViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) DealsTableViewController *dealsViewController;

+ (AppDelegate *)sharedAppDelegate;
- (void)registeredWithResponse:(NSDictionary *)response;
- (void)loggedIntoServerWithResponse:(NSDictionary *)response;
- (void)logoutOfServer;
- (void)didActivateAccount;
- (void)didFinishPermissions;
- (void)contactAuthorizationStatusDenied;
- (void)setSelectedViewControllerToHome;
- (void)setSelectedViewControllerToDetailForDeal:(Deal *)deal;
- (void)setSelectedViewControllerToBeaconProfileWithBeacon:(Beacon *)beacon;
- (void)setSelectedViewControllerToBeaconProfileWithID:(NSNumber *)beaconID promptForCheckIn:(BOOL)promptForCheckIn;
- (void)setSelectedViewControllerToSetBeaconWithRecommendationID:(NSNumber *)recommendationID;
- (void)setSelectedViewControllerToDealDetailWithDeal:(Deal *)deal;
- (void)setSelectedViewControllerToDealDetailWithDealID:(NSNumber *)dealID;

@end
