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
} AnalyticsLocation;


@class Beacon;
@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedManager;

- (void)setupForUser;
- (void)appForeground;

- (void)getDirections:(AnalyticsLocation)analyticsLocation;
- (void)sentText:(AnalyticsLocation)analyticsLocation recipients:(NSArray *)recipients;

- (void)acceptInvite:(AnalyticsLocation)analyticsLocation beacon:(Beacon *)beacon;

@end
