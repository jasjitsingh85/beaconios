//
//  PushNotificationManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 7/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationManager : NSObject

+ (NotificationManager *)sharedManager;

- (void)registerForRemoteNotificationsSuccess:(void (^)(NSData *devToken))success failure:(void (^)(NSError *error))failure;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

@end
