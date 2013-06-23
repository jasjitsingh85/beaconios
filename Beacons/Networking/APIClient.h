//
//  APIClient.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AFHTTPClient.h"
#import <AFNetworking/AFNetworking.h>
#import "HTTPStatusCodes.h"

@class Beacon, Contact;
@interface APIClient : AFHTTPClient

+ (APIClient *)sharedClient;

- (void)setAuthorizationHeaderWithToken:(NSString *)token;
- (void)confirmBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)cancelBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)inviteMoreContacts:(NSArray *)contacts toBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
