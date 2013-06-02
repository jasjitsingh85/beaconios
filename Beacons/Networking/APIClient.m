//
//  APIClient.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "APIClient.h"
#import "Constants.h"

@implementation APIClient

static NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";


+ (APIClient *)sharedClient
{
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLStringDevelopment]];
        [_sharedClient setupAuthorization];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedClient selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
        
    });
    return _sharedClient;
}

- (void)setupAuthorization
{
    NSString *authorizationToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyLastAuthorizationToken];
    if (authorizationToken) {
        [self setAuthorizationHeaderWithToken:authorizationToken];
    }
}


- (void)setAuthorizationHeaderWithToken:(NSString *)token
{
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", token]];
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification
{
    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];
    
    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }
    if ([operation.response statusCode] == kHTTPStatusCodeUnauthorized) {
        // enqueue a new request operation here
    }
}

@end
