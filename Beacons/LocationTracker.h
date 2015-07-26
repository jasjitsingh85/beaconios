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
extern NSString * const kDidRangeBeaconNotification;

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (readonly) BOOL authorized;

+ (LocationTracker *)sharedTracker;
- (CLLocation *)currentLocation;
- (void)fetchCurrentLocation:(void (^)(CLLocation *location))success failure:(void (^)(NSError *error))failure;
- (void)requestLocationPermission;
- (void)startTrackingIfAuthorized;
- (void)stopTracking;
//- (void)monitorRegion:(CLRegion *)region;
//- (void)stopMonitoringForRegionWithIdentifier:(NSString *)regionIdentifier;
//- (void)stopMonitoringAllRegionsAroundHotspots;
//- (void)startMonitoringBeaconRegions;
- (CLLocationDistance)distanceFromCurrentLocationToCoordinate:(CLLocationCoordinate2D)coordinate;


@end
