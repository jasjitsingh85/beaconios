//
//  APIClient.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "APIClient.h"
#import "Beacon.h"
#import "Contact.h"

@implementation APIClient

static NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";
static NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
static NSString * const kBaseURLStringProduction = @"https://www.getbeacons.com/api/";


+ (APIClient *)sharedClient
{
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLStringProduction]];
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

#ifdef DEBUG
    if (operation.error) {
        [[[UIAlertView alloc] initWithTitle:@"Server Error" message:operation.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
#endif
}

#pragma mark - server calls
- (void)postBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSArray *invites = [self paramArrayForContacts:beacon.invited];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:beacon.beaconDescription forKey:@"description"];
    [parameters setValue:@(beacon.time.timeIntervalSince1970) forKey:@"time"];
    [parameters setValue:@(beacon.coordinate.latitude) forKey:@"latitude"];
    [parameters setValue:@(beacon.coordinate.longitude) forKey:@"longitude"];
    if (invites.count) {
        [parameters setValue:invites forKey:@"invite"];
    }
    if (beacon.address) {
        [parameters setValue:beacon.address forKey:@"address"];
    }
    else {
        [parameters setValue:@"" forKey:@"address"];
    }
    [[APIClient sharedClient] postPath:@"beacon/me/" parameters:parameters success:success failure:failure];
}

- (void)deleteBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"isActivated" : @(NO)};
    [[APIClient sharedClient] putPath:@"beacon/me/" parameters:parameters success:success failure:failure];
}

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

- (void)inviteMoreContacts:(NSArray *)contacts toBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableArray *invites = [NSMutableArray new];
    for (Contact *contact in contacts) {
        NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
        [invites addObject:contactString];
    }
    NSDictionary *paramaters = @{@"invite" : invites};
    
    [[APIClient sharedClient] putPath:@"beacon/me/" parameters:paramaters success:success failure:failure];
}

#pragma mark - Private
- (NSString *)stringForContact:(Contact *)contact
{
    NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
    return contactString;
}

- (NSArray *)paramArrayForContacts:(NSArray *)contacts
{
    NSMutableArray *array = [NSMutableArray new];
    for (Contact *contact in contacts) {
        NSString *contactString = [self stringForContact:contact];
        [array addObject:contactString];
    }
    return array;
}

@end
