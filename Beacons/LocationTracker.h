//
//  LocationTracker.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kDidEnterRegionNotification;
extern NSString * const kDidExitRegionNotification;
extern NSString * const kDidUpdateLocationNotification;

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

+ (LocationTracker *)sharedTracker;
- (CLLocation *)currentLocation;
- (void)requestLocationPermission;

- (void)monitorRegion:(CLRegion *)region;
- (void)stopMonitoringForRegion:(CLRegion *)region;


@end
