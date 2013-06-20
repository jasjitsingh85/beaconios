//
//  AnalyticsManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AnalyticsManager.h"
#import "AppDelegate.h"
#import "User.h"

static NSString * const kLocationKey = @"location";
static NSString * const kRecipientKey = @"recipient";
static NSString * const kLocationMapView = @"map_view";
static NSString *const kLocationBeaconDetail = @"beacon_detail";
static NSString * const kRecipientSingle = @"single";
static NSString * const kRecipientGroup = @"group";

static NSString * const kEventAppForeground = @"app_foreground";
static NSString * const kEventRequestedDirections = @"requested_directions";
static NSString * const kEventSentText = @"sent_text";

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
        // Mixpanel initialization
        [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
        [self setupForUser];
    }
    return self;
}

- (void)setupForUser
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    User *loggedInUser = appDelegate.loggedInUser;
    if (!loggedInUser || !loggedInUser.userID) {
        return;
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:loggedInUser.userID.stringValue];
    NSArray *mixpanelProperties = @[@"$email", @"$first_name", @"$last_name", @"$username"];
    NSArray *userProperties = @[@"email", @"firstName", @"lastName", @"username"];
    for (NSInteger i=0; i<mixpanelProperties.count; i++) {
        id value = [loggedInUser valueForKeyPath:userProperties[i]];
        if (value) {
            [mixpanel.people set:mixpanelProperties[i] to:value];
        }
    }
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
    [self sendEvent:kEventAppForeground withProperties:nil];
}

- (void)getDirectionsBeaconDetail
{
    [self sendEvent:kEventRequestedDirections withProperties:@{kLocationKey : kLocationBeaconDetail}];
}

- (void)getDirectionsMapView
{
    [self sendEvent:kEventRequestedDirections withProperties:@{kLocationKey : kLocationMapView}];
}

- (void)sentTextBeaconDetail:(NSArray *)recipients
{
    NSString *recipient = recipients.count > 1 ? kRecipientGroup : kRecipientSingle;
    [self sendEvent:kEventSentText withProperties:@{kRecipientKey : recipient,
      kLocationKey : kLocationBeaconDetail}];
}

- (void)sentTextMapView:(NSArray *)recipients
{
    NSString *recipient = recipients.count > 1 ? kRecipientGroup : kRecipientSingle;
    [self sendEvent:kEventSentText withProperties:@{kRecipientKey : recipient,
      kLocationKey : kLocationMapView}];
}

@end
