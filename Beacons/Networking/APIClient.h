//
//  APIClient.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AFHTTPClient.h"
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import "NSError+ServerErrorMessage.h"
#import "HTTPStatusCodes.h"

@class Beacon, Contact;
@interface APIClient : AFHTTPClient

+ (APIClient *)sharedClient;

+ (void)changeServerPath:(NSString *)serverPath;

- (void)setAuthorizationHeaderWithToken:(NSString *)token;
- (void)postBeacon:(Beacon *)beacon userLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)deleteBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)markBeaconAsSeen:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)confirmBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)arriveBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)checkInFriendWithID:(NSNumber *)userID isUser:(BOOL)isUser atbeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)checkoutFriendWithID:(NSNumber *)userID isUser:(BOOL)isUser atBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)inviteMoreContacts:(NSArray *)contacts toBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getMessagesForBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postMessageWithText:(NSString *)messageText forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postImage:(UIImage *)image forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
