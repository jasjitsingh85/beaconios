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
- (void)registrationBegan;
- (void)registrationFinished;
- (void)getDirections;
- (void)createBeaconWithDescription:(NSString *)description location:(NSString *)location date:(NSDate *)date numInvites:(NSInteger)numInvites;

@end
