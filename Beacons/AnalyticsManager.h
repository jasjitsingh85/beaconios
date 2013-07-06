//
//  AnalyticsManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mixpanel/Mixpanel.h>

typedef enum {
    AnalyticsLocationMapView=0,
    AnalyticsLocationBeaconDetail,
    AnalyticsLocationRegistration,
    AnalyticsLocationSignIn,
    AnalyticsLocationActivation,
} AnalyticsLocation;


@class Beacon;
@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedManager;

- (void)setupForUser;
- (void)appForeground;
- (void)viewPage:(AnalyticsLocation)location;
- (void)getDirections:(AnalyticsLocation)analyticsLocation;
- (void)sentText:(AnalyticsLocation)analyticsLocation recipients:(NSArray *)recipients;
- (void)didRegister;

- (void)acceptInvite:(AnalyticsLocation)analyticsLocation beacon:(Beacon *)beacon;
- (void)createBeacon:(Beacon *)beacon;

@end
