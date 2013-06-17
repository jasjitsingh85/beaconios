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
static NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
static NSString * const kBaseURLStringProduction = @"http://mighty-reef-7102.herokuapp.com/api/";


+ (APIClient *)sharedClient
{
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLStringLAN]];
        [_sharedClient setupAuthorization];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedClient selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
        
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
    
    return self;
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
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kDefaultsKeyLastAuthorizationToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - server calls
- (void)confirmBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self beaconFollow:YES beaconID:beaconID success:success failure:failure];
}

- (void)cancelBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self beaconFollow:NO beaconID:beaconID success:success failure:failure];
}

- (void)beaconFollow:(BOOL)follow beaconID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon_id" : beaconID,
                                 @"follow" : @(follow)};
    [[APIClient sharedClient] postPath:@"beacon/follow/" parameters:parameters success:success failure:failure];
}

@end
