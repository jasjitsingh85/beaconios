//
//  APIClient.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AFHTTPClient.h"
#import <AFNetworking/AFNetworking.h>

@interface APIClient : AFHTTPClient

+ (APIClient *)sharedClient;

- (void)setAuthorizationHeaderWithToken:(NSString *)token;

@end
