//
//  PushNotificationManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 7/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "PushNotificationManager.h"
#import "APIClient.h"

static NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";
static NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
static NSString * const kBaseURLStringProduction = @"http://www.getbeacons.com/api/";
static NSString * const kBaseURLStringStaging = @"http://beaconspushtest.herokuapp.com/api/";

static NSString * const kPushNotificationURLStringStaging = @"http://beaconspushtest.herokuapp.com/ios-notifications/";
static NSString * const kPushNotificationURLStringProduction = @"http://www.getbeacons.com/ios-notifications/";
NSInteger const kAPNSServerDevelopment = 2;
NSInteger const kAPNSServerProduction = 3;

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

- (void)registerForRemoteNotifications
{
    //register for push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{    
    NSString *deviceToken = [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    AFHTTPClient *client = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:kPushNotificationURLStringProduction]];
    NSDictionary *parameters = @{@"token" : deviceToken,
                                 @"service" : @(kAPNSServerProduction)};
    [client postPath:@"device/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //update user with device token
        NSDictionary *params = @{@"device_token" : deviceToken};
        [[APIClient sharedClient] putPath:@"user/me/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"push fail" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *alert = [userInfo valueForKeyPath:@"aps.alert"];
    [[[UIAlertView alloc] initWithTitle:@"New Message" message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
