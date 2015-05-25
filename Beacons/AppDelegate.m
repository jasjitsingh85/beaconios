//
//  AppDelegate.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/DDFileLogger.h>
//#import <FacebookSDK/FacebookSDK.h>
//#import <FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NSURL+InterApp.h"
#import "CenterNavigationController.h"
#import "MenuViewController.h"
#import "DealsTableViewController.h"
#import "SetDealViewController.h"
#import "APIClient.h"
#import "Theme.h"
#import "User.h"
#import "ContactManager.h"
#import "AnalyticsManager.h"
#import "LocationTracker.h"
#import "NotificationManager.h"
#import "CrashManager.h"
#import "RegistrationFlowViewController.h"
#import "SetBeaconViewController.h"
#import "BeaconProfileViewController.h"
#import "PermissionsViewController.h"
#import "Beacon.h"
#import "BeaconManager.h"
#import "RewardManager.h"
#import "LockedViewController.h"
#import "RandomObjectManager.h"
#import "Deal.h"
#import <Braintree/Braintree.h>
#import "VoucherViewController.h"
#import <MaveSDK.h>

@interface AppDelegate()

@property (strong, nonatomic) RegistrationFlowViewController *registerViewController;
@property (strong, nonatomic) NSDictionary *tentativeAccountData;

@end

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (CenterNavigationController *)centerNavigationController
{
    if (!_centerNavigationController) {
        _centerNavigationController = [[CenterNavigationController alloc] init];
    }
    return _centerNavigationController;
}

- (MSDynamicsDrawerViewController *)sideNavigationViewController
{
    if (!_sideNavigationViewController) {
        _sideNavigationViewController = [[MSDynamicsDrawerViewController alloc] init];
        _sideNavigationViewController.gravityMagnitude = 8;
        [_sideNavigationViewController addStylersFromArray:@[[MSDynamicsDrawerFadeStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
        [_sideNavigationViewController setDrawerViewController:self.menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
        [_sideNavigationViewController setRevealWidth:278 forDirection:MSDynamicsDrawerDirectionLeft];
        
        [self.menuViewController view];
        
        [_sideNavigationViewController setPaneViewController:self.centerNavigationController];
    }
    return _sideNavigationViewController;
}

- (SetBeaconViewController *)setBeaconViewController
{
    if (!_setBeaconViewController) {
        _setBeaconViewController = [[SetBeaconViewController alloc] init];
    }
    return _setBeaconViewController;
}

- (MenuViewController *)menuViewController
{
    if (!_menuViewController) {
        _menuViewController = [MenuViewController new];
    }
    return _menuViewController;
}

- (DealsTableViewController *)dealsViewController
{
    if (!_dealsViewController) {
        _dealsViewController = [[DealsTableViewController alloc] init];
    }
    return _dealsViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //start logger
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [DDLog addLogger:fileLogger];
    [CrashManager enableCrittercism];
    
    
    //update content from server
    [[RandomObjectManager sharedManager] updateStringsFromServer];
    
    [ThemeManager customizeAppAppearance];
    self.centerNavigationController.selectedViewController = self.dealsViewController;

    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyIsLoggedIn];
    if (!isLoggedIn) {
        self.registerViewController = [[RegistrationFlowViewController alloc] init];
        self.window.rootViewController = self.registerViewController;
    }
    else {
        self.window.rootViewController = self.sideNavigationViewController;
        [[NotificationManager sharedManager] registerForRemoteNotificationsSuccess:nil failure:nil];
        [[ContactManager sharedManager] syncContacts];
        [CrashManager setupForUser];
    }
    //see if launched from local notification
    if (launchOptions) {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        if (notification) {
            [[NotificationManager sharedManager] didReceiveLocalNotification:notification];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDidEnterRegionNotification:) name:kDidEnterRegionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDidExitRegionNotification:) name:kDidExitRegionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDidRangeBeaconNotification:) name:kDidRangeBeaconNotification object:nil];
    
    //initialize location tracker
    [LocationTracker sharedTracker];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [[LocationTracker sharedTracker] startMonitoringBeaconRegions];
    }
    
    [self.window makeKeyAndVisible];
    UIView *backgroundWindowView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundWindowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_background"]];
    [self.window addSubview:backgroundWindowView];
    [self.window sendSubviewToBack:backgroundWindowView];
    
    [Braintree setReturnURLScheme:@"com.hotspot.hotspot.payments"];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [MaveSDK setupSharedInstanceWithApplicationID:kMaveApplicationID];
    [self initializeMave];
    
    [self incrementAndSaveLaunchCount];
    
    return YES;
}

- (void) incrementAndSaveLaunchCount
{
    NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    launchCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:launchCount  forKey:@"launchCount"];
}

- (void) initializeMave
{
    [self initMaveUser];
    [self customizeMaveInvitePage];
}

- (void) initMaveUser
{
    MaveSDK *mave = [MaveSDK sharedInstance];
    User *user = [User loggedInUser];
    NSString *userID = [NSString stringWithFormat:@"%@", user.userID];
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:userID
                                                        firstName:user.firstName
                                                        lastName:user.lastName];
    [mave identifyUser:userData];
}

- (void)customizeMaveInvitePage {
    // Set some variables for our app's common fonts and colors
    UIColor *green = [[UIColor alloc] initWithRed:43.0/255 green:202.0/255
                                             blue:125.0/255 alpha:1.0];
    UIColor *clear = [UIColor clearColor];
    UIColor *white = [UIColor whiteColor];
    UIColor *black = [[UIColor alloc] initWithWhite:0.15 alpha: 1.0];
    UIColor *gray = [[UIColor alloc] initWithWhite:0.50 alpha: 1.0];
    UIColor *lightGray = [[UIColor alloc] initWithWhite:0.96 alpha: 1.0];
    UIFont *font1 = [ThemeManager lightFontOfSize:17];
    UIFont *font1Bold = [ThemeManager mediumFontOfSize:17];
    UIFont *font1Smaller = [ThemeManager regularFontOfSize:14];
    UIFont *font1SmallerBold = [ThemeManager boldFontOfSize:14];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Cancel";
    backButton.tintColor = white;
    
    // Customize the Mave invite page
    MaveSDK *mave = [MaveSDK sharedInstance];
    
    // Navigation bar options
    mave.displayOptions.statusBarStyle = UIStatusBarStyleDefault;
    mave.displayOptions.navigationBarTitleCopy = @"FREE DRINKS";
    mave.displayOptions.navigationBarTitleFont = font1Bold;
    mave.displayOptions.navigationBarTitleTextColor = white;
    mave.displayOptions.navigationBarBackgroundColor = [UIColor unnormalizedColorWithRed:219 green:55 blue:38 alpha:255];
    
    // Set the cancel button if displaying the page modally, or the
    // back and forward buttons if pushing onto a navigation stack.
    // (note the button target & actions are ignored, we call your
    // dismiss/back/forward blocks instead)
    mave.displayOptions.navigationBarCancelButton = backButton;
    // mave.displayOptions.navigationBarBackButton = ...
    // mave.displayOptions.navigationBarForwardButton = ...
    
    // Above table content - invite page v1 specific
    //  - "invite explanation" text, an optional explanation of how
    //     your app's referral program works
    //  - optional share icons on the invite page
    mave.displayOptions.inviteExplanationFont = font1;
    mave.displayOptions.inviteExplanationTextColor = black;
    mave.displayOptions.inviteExplanationCellBackgroundColor = white;
    mave.displayOptions.inviteExplanationShareButtonsColor = gray;
    mave.displayOptions.inviteExplanationShareButtonsFont = [UIFont systemFontOfSize:10];
    mave.displayOptions.inviteExplanationShareButtonsBackgroundColor = lightGray;
    
    // Above table content - invite page v2 specific
    //  - invite message (user-customizable text that will be sent
    //    in the invite)
    mave.displayOptions.topViewMessageFont = font1Smaller;
    mave.displayOptions.topViewMessageTextColor = black;
    mave.displayOptions.topViewMessageLabelFont = font1Smaller;
    mave.displayOptions.topViewMessageLabelTextColor = gray;
    mave.displayOptions.topViewBackgroundColor = lightGray;
    
    // Search bar options
    mave.displayOptions.searchBarFont = font1;
    mave.displayOptions.searchBarPlaceholderTextColor = gray;
    mave.displayOptions.searchBarSearchTextColor = black;
    mave.displayOptions.searchBarBackgroundColor = white;
    mave.displayOptions.searchBarTopBorderColor = clear;
    
    // Contacts table options
    mave.displayOptions.contactNameFont = font1;
    mave.displayOptions.contactNameTextColor = black;
    mave.displayOptions.contactDetailsFont = font1Smaller;
    mave.displayOptions.contactDetailsTextColor = gray;
    mave.displayOptions.contactSeparatorColor = lightGray;
    mave.displayOptions.contactCellBackgroundColor = white;
    // checkmarks for selecting multiple is for invite page v1
    mave.displayOptions.contactCheckmarkColor = green;
    // inline send button on invite page v2
    mave.displayOptions.contactInlineSendButtonFont = [UIFont systemFontOfSize:16];
    mave.displayOptions.contactInlineSendButtonTextColor = green;
    mave.displayOptions.contactInlineSendButtonDisabledTextColor = gray;
    
    // Contacts table section header & index options
    mave.displayOptions.contactSectionHeaderFont = font1Smaller;
    mave.displayOptions.contactSectionHeaderTextColor = black;
    mave.displayOptions.contactSectionHeaderBackgroundColor = lightGray;
    mave.displayOptions.contactSectionIndexColor = black;
    mave.displayOptions.contactSectionIndexBackgroundColor = clear;
    
    // Message and Send section options for invite page v1
    mave.displayOptions.messageFieldFont = [UIFont systemFontOfSize:16];
    mave.displayOptions.messageFieldTextColor = black;
    mave.displayOptions.messageFieldBackgroundColor = white;
    mave.displayOptions.sendButtonCopy = @"Send";
    mave.displayOptions.sendButtonFont = font1Bold;
    mave.displayOptions.sendButtonTextColor = green;
    mave.displayOptions.bottomViewBorderColor = gray;
    mave.displayOptions.bottomViewBackgroundColor = lightGray;
    
    // The client-side share page (the fallback if the normal
    // invite page can't be displayed)
    mave.displayOptions.sharePageBackgroundColor = lightGray;
    mave.displayOptions.sharePageIconColor = green;
    mave.displayOptions.sharePageIconFont = [UIFont systemFontOfSize:12];
    mave.displayOptions.sharePageIconTextColor = gray;
    mave.displayOptions.sharePageExplanationFont = [UIFont systemFontOfSize:16];
    mave.displayOptions.sharePageExplanationTextColor = black;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[AnalyticsManager sharedManager] appForeground];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    BOOL hasActivated = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyAccountActivated];
    BOOL hasFinishedPermissions = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasFinishedPermissions];
    if (hasActivated) {
        ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
        if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
            self.window.rootViewController = [[PermissionsViewController alloc] init];
        }
        else if (contactAuthStatus == kABAuthorizationStatusDenied) {
            [self contactAuthorizationStatusDenied];
        }
        else if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
            if (![self.window.rootViewController isKindOfClass:[PermissionsViewController class]]) {
                self.window.rootViewController = hasFinishedPermissions ? self.sideNavigationViewController : [[PermissionsViewController alloc] init];
            }
        }
    }
    if (hasFinishedPermissions && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        [[LocationTracker sharedTracker] requestLocationPermission];
    }
    [[BeaconManager sharedManager] updateBeacons:nil failure:nil];
    [[RewardManager sharedManager] updateActiveVouchers:nil failure:nil];
    //[FBSettings setDefaultAppID:kAppID];
    [FBSDKAppEvents activateApp];
    
    // Hotspot: Deals With Friends (iOS) installs
    // Google iOS Download tracking snippet
    // To track downloads of your app, add this snippet to your
    // application delegate's application:didFinishLaunchingWithOptions: method.
    
//    [ACTConversionReporter reportWithConversionID:@"1059446729" label:@"LFWiCJLz2lwQyb-X-QM" value:@"0.00" isRepeatable:NO];
}

- (void)contactAuthorizationStatusDenied
{
//    self.window.rootViewController = [[LockedViewController alloc] init];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[BeaconManager sharedManager] archiveBeacons];
}

- (void)registeredWithResponse:(NSDictionary *)response
{
    NSString *authorizationToken = response[@"token"];
    [[APIClient sharedClient] setAuthorizationHeaderWithToken:authorizationToken];
    self.tentativeAccountData = response;
}

- (void)loggedIntoServerWithResponse:(NSDictionary *)response
{
    NSString *authorizationToken = response[@"token"];
    [[APIClient sharedClient] setAuthorizationHeaderWithToken:authorizationToken];
    self.tentativeAccountData = response;
}

- (void)didActivateAccount
{
    User *user = [[User alloc] initWithData:self.tentativeAccountData];
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
    NSURL *avatarURL = user.avatarURL;
    if (avatarURL) {
        [[NSUserDefaults standardUserDefaults] setObject:avatarURL.absoluteString forKey:kDefaultsAvatarURLKey];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyAccountActivated];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.window.rootViewController = [[PermissionsViewController alloc] init];
    [[AnalyticsManager sharedManager] setupForUser];
    [CrashManager setupForUser];
    [[BeaconManager sharedManager] updateBeacons:nil failure:nil];
    
    [[MaveSDK sharedInstance] getReferringData:^(MAVEReferringData *referringData) {
        MAVEUserData *referringUser = referringData.referringUser;
        NSString *referringUserPhone = referringData.currentUser.phone;
        if (referringUser) {
            [[APIClient sharedClient] earnFriendInvitationReward:referringUserPhone success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successful referral");
            } failure:^(AFHTTPRequestOperation *operation, NSError *responseObject) {
                NSLog(@"Failure for referral");
            }];
         }
    }];
}

- (void)didFinishPermissions
{
    self.window.rootViewController = self.sideNavigationViewController;
    [[ContactManager sharedManager] syncContacts];
    [[LocationTracker sharedTracker] requestLocationPermission];
}

- (void)logoutOfServer
{
    self.registerViewController = [[RegistrationFlowViewController alloc] init];
    self.window.rootViewController = self.registerViewController;
    //nil out any view controllers that have user data
    [BeaconManager sharedManager].beacons = nil;
    [self clearUserDefaults];
    [User logoutUser];
    [[APIClient sharedClient] clearAuthorizationHeader];
}

- (void)clearUserDefaults
{
    NSDictionary *defaultsDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in [defaultsDict allKeys]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSelectedViewControllerToHome
{
    [self.setBeaconViewController updateDescriptionPlaceholder];
    [self.centerNavigationController setSelectedViewController:self.dealsViewController animated:YES];
}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    if ([sourceApplication isEqualToString:kHappyHoursAppURLIdentifier]) {
//        [self.centerNavigationController setSelectedViewController:self.dealsViewController animated:NO];
//    }
//    return YES;
//}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //if ([sourceApplication isEqualToString:kVenmoAppURLIdentifier]) {
    [Braintree handleOpenURL:url sourceApplication:sourceApplication];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    return YES;
}

#pragma mark - Beacon Profile

- (void)setSelectedViewControllerToBeaconProfileWithID:(NSNumber *)beaconID promptForCheckIn:(BOOL)promptForCheckIn
{
    Beacon *beacon = [[Beacon alloc] init];
    beacon.beaconID = beaconID;
    BeaconProfileViewController *beaconProfileViewController = [[BeaconProfileViewController alloc] init];
    beaconProfileViewController.beacon = beacon;
    [beaconProfileViewController refreshBeaconData];
    [self.centerNavigationController setSelectedViewController:beaconProfileViewController animated:YES];
    if (promptForCheckIn) {
        [beaconProfileViewController promptForCheckIn];
    }
}

- (void)setSelectedViewControllerToBeaconProfileWithBeacon:(Beacon *)beacon
{
    BeaconProfileViewController *beaconProfileViewController = [[BeaconProfileViewController alloc] init];
    beaconProfileViewController.beacon = beacon;
    if (beacon.deal) {
        beaconProfileViewController.openToDealView = YES;
    }
    [beaconProfileViewController refreshBeaconData];
    [self.centerNavigationController setSelectedViewController:beaconProfileViewController animated:YES];
}

- (void)setSelectedViewControllerToVoucherViewWithVoucher:(Voucher *)voucher
{
    VoucherViewController *voucherViewController = [[VoucherViewController alloc] init];
    voucherViewController.voucher = voucher;
    voucherViewController.openToDealView = YES;
    [voucherViewController refreshVoucherData];
    [self.centerNavigationController setSelectedViewController:voucherViewController animated:YES];
}

- (void)setSelectedViewControllerToSetBeaconWithRecommendationID:(NSNumber *)recommendationID
{
    [self.centerNavigationController setSelectedViewController:self.setBeaconViewController animated:NO];
    [self.setBeaconViewController preloadWithRecommendation:recommendationID];
}

- (void)setSelectedViewControllerToDealDetailWithDeal:(Deal *)deal animated:(BOOL)animated
{
    SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
    dealViewController.deal = deal;
    [self.centerNavigationController setSelectedViewController:dealViewController animated:animated];
}

- (void)setSelectedViewControllerToDealDetailWithDealID:(NSNumber *)dealID
{
    SetDealViewController *dealDetailViewController = [[SetDealViewController alloc] init];
    [self.centerNavigationController setSelectedViewController:dealDetailViewController];
    [dealDetailViewController preloadWithDealID:dealID];
}

#pragma mark - Location
- (void)receivedDidEnterRegionNotification:(NSNotification *)notification
{
    [[BeaconManager sharedManager] receivedDidEnterRegionNotification:notification];
}

- (void)receivedDidExitRegionNotification:(NSNotification *)notification
{
    [[BeaconManager sharedManager] receivedDidExitRegionNotification:notification];
}

- (void)receivedDidRangeBeaconNotification:(NSNotification *)notification
{
//    iBEACON
//    step 4
//    notification observer for did range beacon
    CLBeacon *beacon = notification.userInfo[@"beacon"];
    NSNumber *dealID = beacon.major;
    [[APIClient sharedClient] postRegionStateWithDealID:dealID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Deal *deal = [[Deal alloc] initWithDictionary:responseObject[@"deals"]];
        BOOL shouldNotify = [responseObject[@"show_notification"] boolValue];
        if (shouldNotify) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.userInfo = @{@"dealID": dealID};
            localNotification.alertBody = deal.notificationText;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
        [[AnalyticsManager sharedManager] postRegionState:YES notified:shouldNotify];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AnalyticsManager sharedManager] postRegionState:NO notified:NO];
    }];
}

#pragma mark - Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    [[NotificationManager sharedManager] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NotificationManager sharedManager] didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[NotificationManager sharedManager] didReceiveLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[NotificationManager sharedManager] didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

@end
