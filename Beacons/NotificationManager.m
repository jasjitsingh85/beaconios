//
//  PushNotificationManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 7/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "NotificationManager.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "NSError+ServerErrorMessage.h"
#import "APIClient.h"
#import "Beacon.h"
#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "BeaconProfileViewController.h"
#import "AnalyticsManager.h"
#import "LocationTracker.h"
#import "BeaconManager.h"

typedef void (^RemoteNotificationRegistrationSuccessBlock)(NSData *devToken);
typedef void (^RemoteNotificationRegistrationFailureBlock)(NSError *error);

@interface NotificationManager()

@property (strong, nonatomic) RemoteNotificationRegistrationSuccessBlock remoteNotificationRegistrationSuccessBlock;
@property (strong, nonatomic) RemoteNotificationRegistrationFailureBlock remoteNotificationRegistrationFailureBlock;

@end

@implementation NotificationManager

+ (NotificationManager *)sharedManager
{
    static NotificationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [NotificationManager new];
    });
    return _sharedManager;
}

#pragma mark - Remote Notification Registering

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

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{    
    NSString *deviceToken = [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
//    [[[UIAlertView alloc] initWithTitle:@"" message:deviceToken delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    //update user with device token
    NSDictionary *params = @{@"device_token" : deviceToken};
    [[APIClient sharedClient] putPath:@"user/me/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Failed to register for push notifications" message:[error serverErrorMessage] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];
    if (self.remoteNotificationRegistrationSuccessBlock) {
        self.remoteNotificationRegistrationSuccessBlock(devToken);
    }
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
    if (self.remoteNotificationRegistrationFailureBlock) {
        self.remoteNotificationRegistrationFailureBlock(err);
    }
}

#pragma mark - Remote Notification Receiving
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    BOOL contentAvailable = [[userInfo[@"aps"] allKeys] containsObject:@"content-available"];
    if (contentAvailable) {
        [self didReceiveBackgroundFetchRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    else {
        [self didReceiveRemoteNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *notificationType = userInfo[@"type"];
    NSString *alert = [userInfo valueForKeyPath:@"aps.alert"];
    BOOL transitioningToForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateInactive;
    if (transitioningToForeground) {
        [self openFromBackgroundNotificationWithType:notificationType alert:alert userInfo:userInfo];
    }
    
    BOOL inForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    if (inForeground) {
        [self didReceiveInForegroundRemoteNotificationWithType:notificationType alert:alert userInfo:userInfo];
    }
}

- (void)didReceiveBackgroundFetchRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[BeaconManager sharedManager] shouldUpdateLocationSuccess:^{
        completionHandler(UIBackgroundFetchResultNewData);
    } failure:^(NSError *error) {
        completionHandler(UIBackgroundFetchResultFailed);
    }];
}

- (void)openFromBackgroundNotificationWithType:(NSString *)notificationType alert:(NSString *)alert userInfo:(NSDictionary *)userInfo
{
    if ([notificationType isEqualToString:kPushNotificationTypeBeaconUpdate] || [notificationType isEqualToString:kPushNotificationTypeMessage]) {
        NSNumber *beaconID = userInfo[@"beacon"];
        if (beaconID) {
            [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithID:beaconID promptForCheckIn:NO];
        }
    }
    else if ([notificationType isEqualToString:kPushNotificationTypeRecommendation]) {
        NSNumber *recommendationID = userInfo[@"rec"];
        [[AppDelegate sharedAppDelegate] setSelectedViewControllerToSetBeaconWithRecommendationID:recommendationID];
    }
    [[AnalyticsManager sharedManager] foregroundFromPush];
}

- (void)didReceiveInForegroundRemoteNotificationWithType:(NSString *)notificationType alert:(NSString *)alert userInfo:(NSDictionary *)userInfo
{
    NSNumber *beaconID = userInfo[@"beacon"];
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"New Message" message:alert];
    [alertView bk_addButtonWithTitle:@"Cancel" handler:nil];
    [alertView bk_setCancelButtonWithTitle:@"See More" handler:^{
        if (beaconID) {
            [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithID:beaconID promptForCheckIn:NO];
        }
    }];
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

#pragma mark - Local Notification Receiving

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    BOOL transitioningToForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateInactive;
    if (transitioningToForeground) {
            NSNumber *beaconID = notification.userInfo[@"beaconID"];
            if (beaconID) {
                [[AppDelegate sharedAppDelegate] setSelectedViewControllerToBeaconProfileWithID:beaconID promptForCheckIn:YES];
            }
    }
    
}



@end
