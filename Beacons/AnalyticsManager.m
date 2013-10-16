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

static NSString * const kLocationMapView = @"map_view";
static NSString * const kLocationBeaconDetail = @"beacon_detail";
static NSString * const kLocationRegistration = @"registration";
static NSString * const kLocationSignIn = @"sign_in";
static NSString * const kLocationActivation = @"activation";
static NSString * const kRecipientSingle = @"single";
static NSString * const kRecipientGroup = @"group";

static NSString * const kPropertyAppLocation = @"app_location";
static NSString * const kPropertyRecipient = @"recipient";
static NSString * const kPropertyBeaconDescription = @"beacon_description";
static NSString * const kPropertyBeaconInvites = @"beacon_invites";
static NSString * const kPropertyBeaconTime = @"beacon_time";
static NSString * const kPropertyBeaconLocation = @"beacon_location";

static NSString * const kEventAppForeground = @"app_foreground";
static NSString * const kEventRequestedDirections = @"requested_directions";
static NSString * const kEventSentText = @"sent_text";
static NSString * const kEventAcceptInvite = @"accept_invite";
static NSString * const kEventCreatedBeacon = @"created_beacon";
static NSString * const kEventViewPage = @"view_page";
static NSString * const kEventDidRegister = @"did_register";

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
    User *loggedInUser = [User loggedInUser];
    if (!loggedInUser || !loggedInUser.userID) {
        return;
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:loggedInUser.userID.stringValue];
    NSArray *mixpanelProperties = @[@"$email", @"$first_name", @"$last_name", @"$username", @"phone_number"];
    NSArray *userProperties = @[@"email", @"firstName", @"lastName", @"username", @"phoneNumber"];
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

- (NSString *)stringForAnalyticsLocation:(AnalyticsLocation)analyticsLocation
{
    NSString *analyticsLocationString = @"";
    if (analyticsLocation == AnalyticsLocationMapView) {
        analyticsLocationString = kLocationMapView;
    }
    else if (analyticsLocation == AnalyticsLocationBeaconDetail) {
        analyticsLocationString = kLocationBeaconDetail;
    }
    else if (analyticsLocation == AnalyticsLocationActivation) {
        analyticsLocationString = kLocationActivation;
    }
    else if (analyticsLocation == AnalyticsLocationRegistration) {
        analyticsLocationString = kLocationRegistration;
    }
    else if (analyticsLocation == AnalyticsLocationSignIn) {
        analyticsLocationString = kLocationSignIn;
    }
    return analyticsLocationString;
}

- (void)appForeground
{
    [self sendEvent:kEventAppForeground withProperties:nil];
}

- (void)viewPage:(AnalyticsLocation)analyticsLocation
{
    NSDictionary *properties = @{kPropertyAppLocation : [self stringForAnalyticsLocation:analyticsLocation]};
    [self sendEvent:kEventViewPage withProperties:properties];
}

- (void)getDirections:(AnalyticsLocation)analyticsLocation
{
    NSDictionary *properties = @{kPropertyAppLocation : [self stringForAnalyticsLocation:analyticsLocation]};
    [self sendEvent:kEventRequestedDirections withProperties:properties];
}

- (void)sentText:(AnalyticsLocation)analyticsLocation recipients:(NSArray *)recipients
{
    NSString *recipient = recipients.count > 1 ? kRecipientGroup : kRecipientSingle;
    NSString *appLocation = [self stringForAnalyticsLocation:analyticsLocation];
    NSDictionary *properties = @{kPropertyAppLocation : appLocation, kPropertyRecipient : recipient};
    [self sendEvent:kEventSentText withProperties:properties];
}

- (void)didRegister
{
    [self setupForUser];
    [self sendEvent:kEventDidRegister withProperties:nil];
}

- (void)acceptInvite:(AnalyticsLocation)analyticsLocation beacon:(Beacon *)beacon
{
    NSDictionary *properties = @{kPropertyAppLocation : [self stringForAnalyticsLocation:analyticsLocation],
                                 kPropertyBeaconDescription : beacon.beaconDescription};
    [self sendEvent:kEventAcceptInvite withProperties:properties];
}

- (void)createBeacon:(Beacon *)beacon
{
    NSDictionary *properties = @{kPropertyBeaconDescription : beacon.beaconDescription,
                               kPropertyBeaconInvites : @(beacon.guestStatuses.count),
                               kPropertyBeaconTime : [beacon.time formattedDate]};
    [self sendEvent:kEventCreatedBeacon withProperties:properties];
                               
}

@end
