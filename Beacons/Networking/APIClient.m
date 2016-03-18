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
#import "Deal.h"
#import "HappyHour.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "BeaconManager.h"

@implementation APIClient


static NSString *_serverPath = nil;
static APIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

+ (APIClient *)sharedClient
{
    if (!_serverPath) {
        _serverPath = kBaseURLStringStaging;
    }
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:_serverPath]];
    });
    return _sharedClient;
}

+ (void)changeServerPath:(NSString *)serverPath
{
    _serverPath = serverPath;
    _sharedClient = nil;
    onceToken = 0;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
    
    [self setupAuthorization];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyIsLoggedIn];
        if (isLoggedIn) {
            [[AppDelegate sharedAppDelegate] logoutOfServer];
            [[[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Please log in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
//#if DEBUG
//    if (operation.error) {
//        NSString *title = [NSString stringWithFormat:@"error request: %@", operation.request];
//        [[[UIAlertView alloc] initWithTitle:title message:operation.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }
//#endif
}

#pragma mark - server calls
- (void)postBeacon:(Beacon *)beacon userLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSArray *invites = [self paramArrayForContacts:[beacon.guestStatuses.allValues valueForKey:@"contact"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:beacon.beaconDescription forKey:@"description"];
    [parameters setValue:@(beacon.time.timeIntervalSince1970) forKey:@"time"];
    [parameters setValue:@(beacon.coordinate.latitude) forKey:@"latitude"];
    [parameters setValue:@(beacon.coordinate.longitude) forKey:@"longitude"];
    if (location) {
        [parameters setValue:@(location.coordinate.latitude) forKey:@"user_latitude"];
        [parameters setValue:@(location.coordinate.longitude) forKey:@"user_longitude"];
    }
    if (invites.count) {
        [parameters setValue:invites forKey:@"invite_list"];
    }
    if (beacon.address) {
        [parameters setValue:beacon.address forKey:@"address"];
    }
    else {
        [parameters setValue:@"" forKey:@"address"];
    }
    [[APIClient sharedClient] postPath:@"hotspot/" parameters:parameters success:success failure:failure];
}

- (void)markBeaconAsSeen:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon_id" : beacon.beaconID};
    [[APIClient sharedClient] postPath:@"saw_invite/" parameters:parameters success:success failure:failure];
}

- (void)deleteBeacon:(Beacon *)beacon success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"isActivated" : @"False"};
    [[APIClient sharedClient] putPath:@"beacon/" parameters:parameters success:success failure:failure];
}

- (void)confirmBeacon:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self beaconFollow:@"Attending" beaconID:beaconID success:success failure:failure];
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
    [[APIClient sharedClient] postPath:@"follow/" parameters:parameters success:success failure:failure];
}

- (void)beaconFollow:(NSString *)followStatus beaconID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon_id" : beaconID,
                                 @"follow" : followStatus};
    [[APIClient sharedClient] postPath:@"follow/" parameters:parameters success:success failure:failure];
}

- (void)inviteMoreContacts:(NSArray *)contacts toBeacon:(Beacon *)beacon withMessage:(NSString *)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableArray *invites = [NSMutableArray new];
    for (Contact *contact in contacts) {
        [invites addObject:contact.serializedString];
    }
    NSDictionary *paramaters = @{@"beacon" : beacon.beaconID,
                                 @"invite_list" : invites,
                                 @"message": message};
    
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

#pragma mark - deals
- (void)getDealWithID:(NSNumber *)dealID success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{@"deal_id" : dealID};
    [self getPath:@"deal/detail/" parameters:parameters success:success failure:failure];
}

//- (void)postRegionStateWithDealID:(NSNumber *)dealID success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
//{
////    we only do this for entering regions with iBeacon for now but this can change later
//    NSDictionary *parameters = @{@"deal_id" : dealID,
//                                 @"region_type" : @"IBeacon",
//                                 @"region_state" : @"Enter"};
//    [self postPath:@"region_state/" parameters:parameters success:success failure:failure];
//}


- (void)getDealsNearCoordinate:(CLLocationCoordinate2D)coordinate withRadius:(NSString *)radius success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters;
    if (radius != nil) {
        parameters = @{@"latitude" : @(coordinate.latitude),
                                     @"longitude" : @(coordinate.longitude),
                                     @"radius" : radius };
    } else {
        parameters = @{@"latitude" : @(coordinate.latitude),
                    @"longitude" : @(coordinate.longitude)};
    }
    [self getPath:@"deals/" parameters:parameters success:success failure:failure];
}

- (void)getRewardsNearCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{@"latitude" : @(coordinate.latitude),
                                 @"longitude" : @(coordinate.longitude)};
    [self getPath:@"rewards/" parameters:parameters success:success failure:failure];
}

- (void)applyForDeal:(Deal *)deal invitedContacts:(NSArray *)contacts customMessage:(NSString *)customMessage time:(NSDate *)time imageUrl:(NSString *)imageUrl success:(void (^)(Beacon *beacon))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"invite_list"] = [self paramArrayForContacts:contacts];
    parameters[@"deal_id"] = deal.dealID;
    parameters[@"time"] = @([time timeIntervalSince1970]);
    parameters[@"custom_message"] = customMessage;
    parameters[@"image_url"] = imageUrl;
    [[APIClient sharedClient] postPath:@"deal/apply/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Beacon *beacon = [[Beacon alloc] initWithData:responseObject[@"beacon"]];
        [[BeaconManager sharedManager] addBeacon:beacon];
        if (success) {
            success(beacon);
        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)inviteFriendsToApp:(NSArray *)contacts customMessage:(NSString *)customMessage success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"invite_list"] = [self paramArrayForContacts:contacts];
    parameters[@"custom_message"] = customMessage;
    [[APIClient sharedClient] postPath:@"invite-friends-to-app/" parameters:parameters success:success failure:failure];
}

- (void)redeemDeal:(Deal *)deal success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"deal_id" : deal.dealID};
    [[APIClient sharedClient] postPath:@"deal/redeem/" parameters:parameters success:success failure:failure];
}

- (void)feedbackDeal:(Deal *)deal success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"deal_id" : deal.dealID};
    [[APIClient sharedClient] postPath:@"deal/feedback/" parameters:parameters success:success failure:failure];
}

- (void)getClientToken:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"client_token/" parameters:parameters success:success failure:failure];
}

- (void)postPurchase: (NSString *)paymentNonce forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{ @"payment_nonce" : paymentNonce , @"beacon_id" : beaconID };
    [[APIClient sharedClient] postPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)postPurchaseForEventWithPaymentNonce: (NSString *)paymentNonce success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{ @"payment_nonce" : paymentNonce , @"is_event" : [NSNumber numberWithBool:YES]};
    [[APIClient sharedClient] postPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)postPurchaseForEvent:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{ @"is_event" : [NSNumber numberWithBool:YES]};
    [[APIClient sharedClient] postPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)postPaymentNonce: (NSString *)paymentNonce success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{ @"payment_nonce" : paymentNonce };
    [[APIClient sharedClient] postPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)checkIfPaymentOnFile:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{ @"beacon_id" : beaconID };
    [[APIClient sharedClient] putPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)checkIfPaymentOnFileForEvent:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] putPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)addRewardItem:(NSString *)referringUserPhoneNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{ @"referring_user" : referringUserPhoneNumber };
    [[APIClient sharedClient] postPath:@"reward/item/" parameters:parameters success:success failure:failure];
}

- (void)getRewardsItems:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"reward/item/" parameters:parameters success:success failure:failure];
}

//- (void)addRewardItem:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
//{
//    NSDictionary *parameters = @{};
//    [[APIClient sharedClient] postPath:@"reward/item/" parameters:parameters success:success failure:failure];
//}

- (void)redeemRewardItem: (NSNumber *)dealStatusID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"deal_status_id" : dealStatusID };
    [[APIClient sharedClient] putPath:@"reward/item/" parameters:parameters success:success failure:failure];
}

- (void)addPromoCode: (NSString *)promoCode success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"promo_code" : promoCode };
    [[APIClient sharedClient] postPath:@"promo/" parameters:parameters success:success failure:failure];
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

- (void)getPromo:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"promo/" parameters:parameters success:success failure:failure];
}

- (void)toggleFavorite: (NSNumber *)dealPlaceID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"deal_place_id" : dealPlaceID };
    [[APIClient sharedClient] postPath:@"favorite-feed/" parameters:parameters success:success failure:failure];
}

- (void)getFavoriteFeed:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"favorite-feed/" parameters:parameters success:success failure:failure];
}

- (void)storeLastFollowView: (NSNumber *)timestamp success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"timestamp" : timestamp };
    [[APIClient sharedClient] putPath:@"favorite-feed/" parameters:parameters success:success failure:failure];
}

- (void)postReferredPhoneNumbers: (NSArray *)contacts success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"contact_array" : contacts };
    [[APIClient sharedClient] postPath:@"contact_status/" parameters:parameters success:success failure:failure];
}

- (void)checkInForDeal:(Deal *)deal isPresent:(BOOL)isPresent isPublic:(BOOL)isPublic success:(void (^)(Beacon *beacon))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"deal_id"] = deal.dealID;
    parameters[@"is_deal"] = [NSNumber numberWithBool:YES];
    parameters[@"is_present"] = [NSNumber numberWithBool:isPresent];
    parameters[@"is_public"] = [NSNumber numberWithBool:isPublic];
    [[APIClient sharedClient] postPath:@"check-in/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Beacon *beacon = [[Beacon alloc] initWithData:responseObject[@"beacon"]];
        [[BeaconManager sharedManager] addBeacon:beacon];
        if (success) {
            success(beacon);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)checkInForVenue:(Venue *)venue isPublic:(BOOL)isPublic success:(void (^)(Beacon *beacon))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"place_id"] = venue.venueID;
    parameters[@"is_deal"] = [NSNumber numberWithBool:YES];
    parameters[@"is_public"] = [NSNumber numberWithBool:isPublic];
    [[APIClient sharedClient] postPath:@"v2/check-in/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Beacon *beacon = [[Beacon alloc] initWithData:responseObject[@"beacon"]];
        [[BeaconManager sharedManager] addBeacon:beacon];
        if (success) {
            success(beacon);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getFollowRecommendations:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"recommendation/" parameters:parameters success:success failure:failure];
}

- (void)trackView:(NSNumber *)viewID ofType:(NSString *)viewType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"view_id" : viewID, @"view_type" : viewType };
    [[APIClient sharedClient] postPath:@"view-tracker/" parameters:parameters success:success failure:failure];
}

- (void)postFacebookToken:(NSString *)fb_token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"fb_token" : fb_token };
    [[APIClient sharedClient] postPath:@"facebook-token/" parameters:parameters success:success failure:failure];
}

- (void)getPlacesNearCoordinate:(CLLocationCoordinate2D)coordinate withRadius:(NSString *)radius success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters;
    if (radius != nil) {
        parameters = @{@"latitude" : @(coordinate.latitude),
                       @"longitude" : @(coordinate.longitude),
                       @"radius" : radius };
    } else {
        parameters = @{@"latitude" : @(coordinate.latitude),
                       @"longitude" : @(coordinate.longitude)};
    }
    [self getPath:@"places/" parameters:parameters success:success failure:failure];
}

- (void)getIsDealActive:(NSNumber *)venueID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSDictionary *parameters = @{@"venue_id" : venueID};
    [[APIClient sharedClient] getPath:@"check-in/" parameters:parameters success:success failure:failure];
}

- (void)getManageFriends:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"friend/manage/" parameters:parameters success:success failure:failure];
}

- (void)toggleFriendBlocking:(NSNumber *)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{ @"user_id" : userID };
    [[APIClient sharedClient] postPath:@"friend/manage/" parameters:parameters success:success failure:failure];
}

- (void)getTab:(NSNumber *)venueID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSDictionary *parameters = @{@"place_id" : venueID};
    [[APIClient sharedClient] getPath:@"tab/" parameters:parameters success:success failure:failure];
}

- (void)getPaymentInfo:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSDictionary *parameters = @{};
    [[APIClient sharedClient] getPath:@"purchases/" parameters:parameters success:success failure:failure];
}

- (void)closeTab:(NSNumber *)venueID withTip:(NSNumber *)tip success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSDictionary *parameters = @{@"place_id" : venueID, @"tip" : tip};
    [[APIClient sharedClient] postPath:@"tab/" parameters:parameters success:success failure:failure];
}

- (void)postBackgroundLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"latitude" : @(location.coordinate.latitude),
                                 @"longitude" : @(location.coordinate.longitude)};
    [[APIClient sharedClient] postPath:@"background/location/" parameters:parameters success:success failure:failure];
}

- (void)reserveTicket:(NSNumber *)eventID isPublic:(BOOL)isPublic success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"event_id"] = eventID;
    parameters[@"is_public"] = [NSNumber numberWithBool:isPublic];
    
    [[APIClient sharedClient] postPath:@"reserve/" parameters:parameters success:success failure:failure];
}

- (void)getSponsoredEvent:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSDictionary *parameters = @{@"event_id" : eventID};
    [[APIClient sharedClient] getPath:@"reserve/" parameters:parameters success:success failure:failure];
}

- (void)redeemEvent:(NSNumber *)eventStatusID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *parameters = @{@"event_status_id" : eventStatusID};
    [[APIClient sharedClient] putPath:@"reserve/" parameters:parameters success:success failure:failure];
}

- (void)toggleInterested:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"event_id"] = eventID;
    parameters[@"is_interested"] = [NSNumber numberWithBool:0];
    
    [[APIClient sharedClient] postPath:@"reserve/" parameters:parameters success:success failure:failure];
}

@end
