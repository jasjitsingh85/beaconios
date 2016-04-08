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

@class Beacon, Contact, Deal, HappyHour, Venue;
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
- (void)inviteMoreContacts:(NSArray *)contacts toBeacon:(Beacon *)beacon withMessage:(NSString *)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postImageMessage:(NSString *)imageUrl forEventWithID:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postStringMessage:(NSString *)messageText forEventWithID:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postImage:(UIImage *)image forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postImage:(UIImage *)image withImageName:(NSString *)imageName success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getDealsNearCoordinate:(CLLocationCoordinate2D)coordinate withRadius:(NSString *)radius success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getRewardsNearCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getDealWithID:(NSNumber *)dealID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//- (void)postRegionStateWithDealID:(NSNumber *)dealID success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)applyForDeal:(Deal *)deal invitedContacts:(NSArray *)contacts customMessage:(NSString *)customMessage time:(NSDate *)time imageUrl:(NSString *)imageUrl success:(void (^)(Beacon *beacon))success failure:(void (^)(NSError *error))failure;
- (void)redeemDeal:(Deal *)deal success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)feedbackDeal:(Deal *)deal success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getClientToken: (void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postPurchase: (NSString *)paymentNonce forBeaconWithID:(NSNumber *)beaconID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postPurchaseForEventWithPaymentNonce: (NSString *)paymentNonce success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)postPurchaseForEvent:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)checkIfPaymentOnFile: (NSNumber *)dealStatusID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//- (void)purchaseRewardItem: (NSNumber *)dealID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//- (void)redeemVoucher: (NSNumber *)voucherID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//- (void)deleteVoucher: (NSNumber *)voucherID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//- (void)getRewardsScore: (void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)addRewardItem:(NSString *)referringUserPhoneNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)getRewardsItems: (void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)inviteFriendsToApp:(NSArray *)contacts customMessage:(NSString *)customMessage success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
//- (void)addRewardItem: (void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)redeemRewardItem: (NSNumber *)dealStatusID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postPaymentNonce: (NSString *)paymentNonce success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)addPromoCode: (NSString *)promoCode success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getPromo: (void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)toggleFavorite: (NSNumber *)dealPlaceID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getFavoriteFeed: (void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)storeLastFollowView: (NSNumber *)timestamp success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postReferredPhoneNumbers: (NSArray *)contacts success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)checkInForDeal:(Deal *)deal isPresent:(BOOL)isPresent isPublic:(BOOL)isPublic success:(void (^)(Beacon *beacon))success failure:(void (^)(NSError *error))failure;
- (void)checkInForVenue:(Venue *)venue isPublic:(BOOL)isPublic success:(void (^)(Beacon *beacon))success failure:(void (^)(NSError *error))failure;
- (void)getFollowRecommendations:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)trackView:(NSNumber *)viewID ofType:(NSString *)viewType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postFacebookToken:(NSString *)fb_token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getPlacesNearCoordinate:(CLLocationCoordinate2D)coordinate withRadius:(NSString *)radius success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)getIsDealActive:(NSNumber *)venueID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getManageFriends:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)toggleFriendBlocking:(NSNumber *)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getTab:(NSNumber *)venueID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getPaymentInfo:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)closeTab:(NSNumber *)venueID withTip:(NSNumber *)tip success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postBackgroundLocation:(CLLocation *)location success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)checkIfPaymentOnFileForEvent:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)reserveTicket:(NSNumber *)eventID isPublic:(BOOL)isPublic withTip:(NSNumber *)tip success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getSponsoredEvent:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)redeemEvent:(NSNumber *)eventStatusID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)toggleInterested:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getDatingData:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postDatingProfile:(NSString *)imageUrl andGender:(NSString *)userGender andPreference:(NSString *)userPreference andEventID:(NSNumber *)event_id success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)swipeComplete:(NSNumber *)datingProfileID withSelection:(BOOL)isSelected forEvent:(NSNumber *)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
