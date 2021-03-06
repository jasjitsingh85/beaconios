//
//  AnalyticsManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AnalyticsManager.h"
#import "User.h"
#import "Beacon.h"

@implementation AnalyticsManager

+ (id)sharedManager
{
    static AnalyticsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupForUser];
    }
    return self;
}

- (void)startMixpanel
{
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
}

- (void)setupForUser
{
    User *loggedInUser = [User loggedInUser];
    if (loggedInUser && [self userIsBlacklisted:loggedInUser]) {
        return;
    }
    [self startMixpanel];
    if (!loggedInUser || !loggedInUser.userID) {
        return;
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:loggedInUser.userID.stringValue];
    NSArray *mixpanelProperties = @[@"$email", @"$first_name", @"$last_name", @"$username", @"phone_number"];
    NSArray *userProperties = @[@"email", @"firstName", @"lastName", @"username", @"phoneNumber"];
    NSMutableDictionary *superProperties = [[NSMutableDictionary alloc] init];
    for (NSInteger i=0; i<mixpanelProperties.count; i++) {
        id value = [loggedInUser valueForKeyPath:userProperties[i]];
        if (value) {
            [mixpanel.people set:mixpanelProperties[i] to:value];
            [superProperties setObject:value forKey:userProperties[i]];
        }
    }
    [mixpanel registerSuperProperties:superProperties];
}

- (BOOL)userIsBlacklisted:(User *)user
{
    NSArray *blackListPhones = @[@"6176337532", @"5413359388", @"6695556969", @"5551234567", @"2162695105", @"6094398069", @"2064731300"];
    BOOL blackListed = user.normalizedPhoneNumber && [blackListPhones containsObject:user.normalizedPhoneNumber];
    return blackListed;
}

- (void)sendEvent:(NSString *)event withProperties:(NSDictionary *)properties
{
    if (properties) {
        [[Mixpanel sharedInstance] track: event properties:properties];
    }
    else {
        [[Mixpanel sharedInstance] track: event];
    }
}


- (void)appForeground
{
    [self sendEvent:@"app_foreground" withProperties:nil];
}

- (void)foregroundFromPush
{
    [self sendEvent:@"foreground_push" withProperties:nil];
}

- (void)registrationBegan
{
    [self sendEvent:@"registration_begin" withProperties:nil];
}

- (void)registrationFinished
{
    [self sendEvent:@"registration_finish" withProperties:nil];
}

- (void)getDirections
{
    [self sendEvent:@"get_directions" withProperties:nil];
}

- (void)createBeaconWithDescription:(NSString *)description location:(NSString *)location date:(NSDate *)date numInvites:(NSInteger)numInvites
{
    NSDictionary *properties = @{@"description" : description,
                                 @"num_invites" : @(numInvites),
                                 @"location" : location,
                                 @"time" : [date formattedTime]};
    [self sendEvent:@"set_hotspot" withProperties:properties];
    
}

- (void)inviteToBeacon:(NSInteger)numInvites
{
    NSDictionary *properties = @{@"num_invites" : @(numInvites)};
    [self sendEvent:@"invite_to_hotspot" withProperties:properties];
}

- (void)setBeaconStatus:(NSString *)status forSelf:(BOOL)forSelf
{
    NSDictionary *properties = @{@"status" : status,
                                 @"for_self" : @(forSelf)};
    [self sendEvent:@"attending_status" withProperties:properties];
}

- (void)inviteToApp:(NSString *)activityType completed:(BOOL)completed
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    if (activityType) {
        [properties setObject:activityType forKey:@"activity_type"];
    }
    [properties setObject:@(completed) forKey:@"completed"];
    [self sendEvent:@"invite_friends" withProperties:properties];
}

- (void)viewedDealTable
{
    [self sendEvent:@"viewed_deal_table" withProperties:nil];
}

- (void)viewedDeals:(NSInteger)numDeals
{
    NSDictionary *properties = @{@"num_deals" : @(numDeals)};
    [self sendEvent:@"viewed_deals" withProperties:properties];
}

- (void)viewedDeal:(NSString *)dealID withPlaceName:(NSString *)placeName
{
    NSDictionary *properties = @{@"deal_id" : dealID, @"place" : placeName};
    [self sendEvent:@"viewed_deal_detail" withProperties:properties];
}

- (void)invitedFriendsDeal:(NSString *)dealID withPlaceName:(NSString *)placeName
{
    NSDictionary *properties = @{@"deal_id" : dealID, @"place" : placeName};
    [self sendEvent:@"invite_friends_deal" withProperties:properties];
}

- (void)setDeal:(NSString *)dealID withPlaceName:(NSString *)placeName numberOfInvites:(NSInteger)numInvited
{
    NSDictionary *properties = @{@"deal_id" : dealID, @"place" : placeName, @"num_invites": @(numInvited)};
    [self sendEvent:@"set_deal" withProperties:properties];
}

- (void)openNewsfeedWithNumberOfFollowItems:(NSInteger)numFollowItems
{
    NSDictionary *properties = @{@"num_follow_items": @(numFollowItems)};
    [self sendEvent:@"open_newsfeed" withProperties:properties];
}

//- (void)postRegionState:(BOOL)success notified:(BOOL)notified
//{
//    NSDictionary *properties = @{@"success" : @(success), @"notified" : @(notified)};
//    [self sendEvent:@"post_region_state" withProperties:properties];
//}



@end
