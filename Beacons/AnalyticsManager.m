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
    [self sendEvent:@"app_foreground" withProperties:nil];
}

- (void)getDirectionsBeaconDetail
{
    [self sendEvent:@"requested_directions" withProperties:@{@"location" : @"beacon_detail"}];
}

- (void)getDirectionsMapView
{
    [self sendEvent:@"requested_directions" withProperties:@{@"location" : @"map_view"}];
}

@end
