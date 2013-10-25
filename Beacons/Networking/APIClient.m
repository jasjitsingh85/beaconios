//
//  APIClient.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "APIClient.h"
#import "UIImage+Resize.h"
#import "Beacon.h"
#import "Contact.h"

@implementation APIClient

static NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";
static NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
static NSString * const kBaseURLStringProduction = @"http://www.getbeacons.com/api/";
static NSString * const kBaseURLStringStaging = @"http://beaconspushtest.herokuapp.com/api/";


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
#if DEBUG
    if (operation.error) {
        NSString *title = [NSString stringWithFormat:@"error request: %@", operation.request];
        [[[UIAlertView alloc] initWithTitle:title message:operation.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
#endif
}

#pragma mark - server calls
- (void)postBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSArray *invites = [self paramArrayForContacts:[beacon.guestStatuses.allValues valueForKey:@"contact"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:beacon.beaconDescription forKey:@"description"];
    [parameters setValue:@(beacon.time.timeIntervalSince1970) forKey:@"time"];
    [parameters setValue:@(beacon.coordinate.latitude) forKey:@"latitude"];
    [parameters setValue:@(beacon.coordinate.longitude) forKey:@"longitude"];
    if (invites.count) {
        [parameters setValue:invites forKey:@"invite_list"];
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
    NSDictionary *parameters = @{@"isActivated" : @"False"};
    [[APIClient sharedClient] putPath:@"beacon/me/" parameters:parameters success:success failure:failure];
}

- (void)confirmBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self beaconFollow:@"Going" beaconID:beaconID success:success failure:failure];
}

- (void)checkoutFriendWithID:(NSNumber *)userID isUser:(BOOL)isUser atBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setStatusOfFriendWithID:userID isUser:isUser atBeacon:beaconID status:@"Invited" success:success failure:failure];
}

- (void)arriveBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self beaconFollow:@"Here" beaconID:beaconID success:success failure:failure];
}

- (void)checkInFriendWithID:(NSNumber *)userID isUser:(BOOL)isUser atbeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setStatusOfFriendWithID:userID isUser:isUser atBeacon:beaconID status:@"Here" success:success failure:failure];
}

- (void)setStatusOfFriendWithID:(NSNumber *)userID isUser:(BOOL)isUser atBeacon:(NSNumber *)beaconID status:(NSString *)status success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *key = isUser ? @"user_id" : @"contact_id";
    NSDictionary *parameters = @{@"beacon_id" : beaconID,
                                 key : userID,
                                 @"follow" : status};
    [[APIClient sharedClient] postPath:@"beacon/follow/" parameters:parameters success:success failure:failure];
}

- (void)beaconFollow:(NSString *)followStatus beaconID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon_id" : beaconID,
                                 @"follow" : followStatus};
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
    NSDictionary *paramaters = @{@"beacon" : beacon.beaconID,
                                 @"invite_list" : invites};
    
    [[APIClient sharedClient] postPath:@"invite/" parameters:paramaters success:success failure:failure];
}

- (void)postLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"latitude" : @(location.coordinate.latitude),
                                 @"longitude" : @(location.coordinate.longitude)};
    [[APIClient sharedClient] postPath:@"location/" parameters:parameters success:success failure:failure];
}

- (void)getMessagesForBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon" : beaconID};
    [[APIClient sharedClient] getPath:@"message/" parameters:parameters success:success failure:failure];
}

- (void)postMessageWithText:(NSString *)messageText forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon" : beaconID,
                                 @"message" : messageText};
    [[APIClient sharedClient] postPath:@"message/" parameters:parameters success:success failure:failure];
}

- (void)postImage:(UIImage *)image forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    NSDictionary *parameters = @{@"beacon" : beaconID};
    NSString *imageName = beaconID.stringValue;
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"image/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:[imageName stringByAppendingString:@".jpg"] mimeType:@"image/jpg"];
    }];
    request.timeoutInterval = 10*60;
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
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
