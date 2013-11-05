//
//  PushNotificationManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 7/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "PushNotificationManager.h"
#import "APIClient.h"
#import "Beacon.h"
#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "BeaconProfileViewController.h"

static NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";
static NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
static NSString * const kBaseURLStringProduction = @"http://www.getbeacons.com/api/";
static NSString * const kBaseURLStringStaging = @"http://beaconspushtest.herokuapp.com/api/";

static NSString * const kPushNotificationURLStringStaging = @"http://beaconspushtest.herokuapp.com/ios-notifications/";
static NSString * const kPushNotificationURLStringProduction = @"http://www.getbeacons.com/ios-notifications/";

typedef void (^RemoteNotificationRegistrationSuccessBlock)(NSData *devToken);
typedef void (^RemoteNotificationRegistrationFailureBlock)(NSError *error);

@interface PushNotificationManager()

@property (strong, nonatomic) RemoteNotificationRegistrationSuccessBlock remoteNotificationRegistrationSuccessBlock;
@property (strong, nonatomic) RemoteNotificationRegistrationFailureBlock remoteNotificationRegistrationFailureBlock;

@end

@implementation PushNotificationManager

+ (PushNotificationManager *)sharedManager
{
    static PushNotificationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [PushNotificationManager new];
    });
    return _sharedManager;
}

- (void)registerForRemoteNotificationsSuccess:(void (^)(NSData *devToken))success failure:(void (^)(NSError *error))failure
{
    self.remoteNotificationRegistrationSuccessBlock = success;
    self.remoteNotificationRegistrationFailureBlock = failure;
#if !DEBUG
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#else
    if (failure) {
        NSError *error = [[NSError alloc] initWithDomain:@"qsCustomErrorDomain" code:-1 userInfo:nil];
        failure(error);
    }
#endif
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{    
    NSString *deviceToken = [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
//    [[[UIAlertView alloc] initWithTitle:@"" message:deviceToken delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    //update user with device token
    NSDictionary *params = @{@"device_token" : deviceToken};
    [[APIClient sharedClient] putPath:@"user/me/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"push fail" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];
    if (self.remoteNotificationRegistrationSuccessBlock) {
        self.remoteNotificationRegistrationSuccessBlock(devToken);
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
    if (self.remoteNotificationRegistrationFailureBlock) {
        self.remoteNotificationRegistrationFailureBlock(err);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *notificationType = userInfo[@"type"];
    NSString *alert = userInfo[@"aps.alert"];
    BOOL transitioningToForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateInactive;
    if (transitioningToForeground) {
        [self openFromBackgroundNotificationWithType:notificationType alert:alert userInfo:userInfo];
    }
    
    BOOL inForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    if (inForeground) {
        [self didReceiveInForegroundRemoteNotificationWithType:notificationType alert:alert userInfo:userInfo];
    }
}

- (void)openFromBackgroundNotificationWithType:(NSString *)notificationType alert:(NSString *)alert userInfo:(NSDictionary *)userInfo
{
    if ([notificationType isEqualToString:kPushNotificationTypeBeaconUpdate] || [notificationType isEqualToString:kPushNotificationTypeMessage]) {
        NSNumber *beaconID = userInfo[@"beacon"];
        if (beaconID) {
            [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithID:beaconID];
        }
    }
}

- (void)didReceiveInForegroundRemoteNotificationWithType:(NSString *)notificationType alert:(NSString *)alert userInfo:(NSDictionary *)userInfo
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Message" message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if ([notificationType isEqualToString:kPushNotificationTypeMessage]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushNotificationMessageReceived object:nil userInfo:userInfo];
        BOOL showingChat = [[AppDelegate sharedAppDelegate].centerNavigationController.selectedViewController isKindOfClass:[BeaconProfileViewController class]] || ([AppDelegate sharedAppDelegate].centerNavigationController.viewControllers.count && [[AppDelegate sharedAppDelegate].centerNavigationController.visibleViewController  isKindOfClass:[BeaconProfileViewController class]]);
        if (!showingChat) {
            [alertView show];
        }
    }
    else {
        [alertView show];
    }
}

@end
