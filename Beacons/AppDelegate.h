//
//  AppDelegate.h
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import "TrackAndAd.h"

@class CenterNavigationController,
LoginViewController,
MenuViewController,
DealsTableViewController,
SetBeaconViewController,
User,
Beacon,
Voucher,
Deal;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    KochavaTracker *kochavaTracker;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CenterNavigationController *centerNavigationController;
@property (strong, nonatomic) MSDynamicsDrawerViewController *sideNavigationViewController;
@property (strong, nonatomic) SetBeaconViewController *setBeaconViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) DealsTableViewController *dealsViewController;
@property(readonly) KochavaTracker *kochavaTracker;

+ (AppDelegate *)sharedAppDelegate;
- (void)registeredWithResponse:(NSDictionary *)response;
- (void)loggedIntoServerWithResponse:(NSDictionary *)response;
- (void)logoutOfServer;
- (void)didActivateAccount;
- (void)startRegistration;
- (void)showIntroView;
-(void)startRegistrationWithFacebook:(NSDictionary *)paramaters;
- (void)startLogin;
- (void)didFinishPermissions;
- (void)contactAuthorizationStatusDenied;
- (void)setSelectedViewControllerToHome;
- (void)setSelectedViewControllerToBeaconProfileWithBeacon:(Beacon *)beacon;
//- (void)setSelectedViewControllerToVoucherViewWithVoucher:(Voucher *)voucher;
- (void)setSelectedViewControllerToBeaconProfileWithID:(NSNumber *)beaconID promptForCheckIn:(BOOL)promptForCheckIn;
- (void)setSelectedViewControllerToSetBeaconWithRecommendationID:(NSNumber *)recommendationID;
//- (void)setSelectedViewControllerToDealDetailWithDeal:(Deal *)deal animated:(BOOL)animated;
//- (void)setSelectedViewControllerToDealDetailWithDealID:(NSNumber *)dealID;

@end
