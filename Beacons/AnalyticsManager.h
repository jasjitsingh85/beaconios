//
//  AnalyticsManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mixpanel/Mixpanel.h>

@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedManager;

- (void)setupForUser;
- (void)appForeground;
- (void)foregroundFromPush;
- (void)registrationBegan;
- (void)registrationFinished;
- (void)getDirections;
- (void)createBeaconWithDescription:(NSString *)description location:(NSString *)location date:(NSDate *)date numInvites:(NSInteger)numInvites;
- (void)inviteToBeacon:(NSInteger)numInvites;
- (void)setBeaconStatus:(NSString *)status forSelf:(BOOL)forSelf;
- (void)inviteToApp:(NSString *)activityType completed:(BOOL)completed;
- (void)viewedDealTable;
- (void)viewedDeals:(NSInteger)numDeals;
- (void)viewedDeal:(NSString *)dealID withPlaceName:(NSString *)placeName;
- (void)invitedFriendsDeal:(NSString *)dealID withPlaceName:(NSString *)placeName;
- (void)setDeal:(NSString *)dealID withPlaceName:(NSString *)placeName numberOfInvites:(NSInteger)numInvited;
- (void)openNewsfeedWithNumberOfFollowItems:(NSInteger)numFollowItems;
//- (void)postRegionState:(BOOL)success notified:(BOOL)notified;

@end
