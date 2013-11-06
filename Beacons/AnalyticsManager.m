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
    NSMutableDictionary *superProperties = [[NSMutableDictionary alloc] init];
    for (NSInteger i=0; i<mixpanelProperties.count; i++) {
        id value = [loggedInUser valueForKeyPath:userProperties[i]];
        if (value) {
            [mixpanel.people set:mixpanelProperties[i] to:value];
            [superProperties setObject:value forKey:userProperties[i]];
        }
    }
    [mixpanel registerSuperProperties:superProperties]	;
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

- (void)getDirections
{
    [self sendEvent:@"get_directions" withProperties:nil];
}

- (void)createBeaconWithDescription:(NSString *)description location:(NSString *)location date:(NSDate *)date numInvites:(NSInteger)numInvites
{
    NSDictionary *properties = @{@"description" : description,
                                 @"num_invites" : @(numInvites),
                                 @"location" : location,
                                 @"time" : [date formattedDate]};
    [self sendEvent:@"set_hotspot" withProperties:properties];
    
}

@end
