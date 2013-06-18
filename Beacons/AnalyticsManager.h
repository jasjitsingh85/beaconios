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

- (void)appForeground;

@end
