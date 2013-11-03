//
//  PushNotificationManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 7/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushNotificationManager : NSObject

+ (PushNotificationManager *)sharedManager;

- (void)registerForRemoteNotificationsSuccess:(void (^)(NSData *devToken))success failure:(void (^)(NSError *error))failure;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
