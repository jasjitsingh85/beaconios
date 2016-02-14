//
//  LocationTracker.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LocationTracker.h"
#import "APIClient.h"

NSString * const kDidEnterRegionNotification = @"didEnterRegionNotification";
NSString * const kDidExitRegionNotification = @"didExitRegionNotification";
NSString * const kDidUpdateLocationNotification = @"didUpdateLocationNotification";
NSString * const kDidRangeBeaconNotification = @"didRangeBeaconNotification";

typedef void (^FetchLocationSuccessBlock)(CLLocation *location);
typedef void (^FetchLocationFailureBlock)(NSError *error);


@interface LocationTracker()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FetchLocationSuccessBlock fetchLocationSuccessBlock;
@property (strong, nonatomic) FetchLocationFailureBlock fetchLocationFailureBlock;
@property (assign, nonatomic) BOOL fetchingLocation;
@property (assign, nonatomic) BOOL fetchingiBeacon;
@property (nonatomic, strong) NSDateFormatter *dateFormatter; //REMOVE

@end

@implementation LocationTracker

+ (LocationTracker *)sharedTracker
{
    static LocationTracker *_sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTracker = [[LocationTracker alloc] init];
        
    });
    return _sharedTracker;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.delegate = self;
        self.dateFormatter = [[NSDateFormatter alloc] init]; //REMOVE
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)authorized
{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

//- (void)startMonitoringBeaconRegions
//{
////    iBEACON
////    step 1
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"66278782-119A-4BED-B12D-5BD38BB1DDD7"];
//    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"hotspot"];
////    beaconRegion.notifyEntryStateOnDisplay = YES;
//    [self.locationManager startMonitoringForRegion:beaconRegion];
//    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
//}

- (void)startTrackingIfAuthorized
{
    if (self.authorized) {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)startTrackingVisits
{
    if (self.authorized) {
        [self.locationManager startMonitoringVisits];
    }
}

- (void)stopTracking
{
    [self.locationManager stopUpdatingLocation];
}

- (void)requestLocationPermission
{
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)fetchCurrentLocation:(void (^)(CLLocation *location))success failure:(void (^)(NSError *error))failure
{
    self.fetchLocationSuccessBlock = success;
    self.fetchLocationFailureBlock = failure;
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        [self failedToFetchLocation];
    }
    else {
        CLLocation *currentLocation = self.currentLocation;
        NSTimeInterval maxAge = 60*2;
        CLLocationAccuracy requiredAccuracy = 100;
        BOOL locationIsValid = currentLocation && [[NSDate date] timeIntervalSinceDate:currentLocation.timestamp] < maxAge && currentLocation.horizontalAccuracy <= requiredAccuracy;
        if (locationIsValid) {
            [self fetchedLocation:currentLocation];
        }
        else {
            [self.locationManager startUpdatingLocation];
            self.fetchingLocation = YES;
            jadispatch_after_delay(5, dispatch_get_main_queue(), ^{
                //if after timeout still have location that isn't super old use that
                if ([[NSDate date] timeIntervalSinceDate:self.locationManager.location.timestamp] < maxAge) {
                    [self fetchedLocation:self.locationManager.location];
                }
                else if (self.fetchingLocation) {
                    [self failedToFetchLocation];
                }
            });
        }
    }
}

- (void)failedToFetchLocation
{
    self.fetchingLocation = NO;
    if (self.fetchLocationFailureBlock) {
        self.fetchLocationFailureBlock(nil);
    }
    self.fetchLocationSuccessBlock = nil;
    self.fetchLocationFailureBlock = nil;
}

- (void)fetchedLocation:(CLLocation *)location
{
    self.fetchingLocation = NO;
    if (self.fetchLocationSuccessBlock) {
        self.fetchLocationSuccessBlock(location);
    }
    self.fetchLocationSuccessBlock = nil;
    self.fetchLocationFailureBlock = nil;
}

- (CLLocation *)currentLocation
{
    if (self.authorized) {
        return self.locationManager.location;
    }
    NSLog(@"requested location before authorizing");
    return nil;
}

- (void)monitorRegion:(CLRegion *)region
{
    if (!self.authorized) {
        return;
    }
    [self.locationManager startMonitoringForRegion:region];
}

//- (void)stopMonitoringForRegionWithIdentifier:(NSString *)regionIdentifier
//{
//    if (!self.authorized) {
//        return;
//    }
//    NSSet *regions = [self.locationManager.monitoredRegions filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", regionIdentifier]];
//    CLRegion *region = [regions anyObject];
//    if (region) {
//        [self.locationManager stopMonitoringForRegion:region];
//    }
//}

//- (void)stopMonitoringAllRegionsAroundHotspots
//{
//    if (!self.authorized) {
//        return;
//    }
//    for (CLRegion *region in self.locationManager.monitoredRegions) {
//        if ([region isKindOfClass:[CLCircularRegion class]]) {
//            [self.locationManager stopMonitoringForRegion:region];
//        }
//    }
//}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
//    iBEACON
//    step 3
//    after entering region and starting to range for beacon. this gives you distance reading
    CLBeacon *beacon = [beacons firstObject];
    if (beacon && self.fetchingiBeacon) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidRangeBeaconNotification object:nil userInfo:@{@"beacon" : beacon}];
        self.fetchingiBeacon = NO;
    }
}

//- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
//{
//}

//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
//{
//    //    iBEACON
//    //    step 2
////    called when you first connect to beacon
//    if ([region isKindOfClass:[CLBeaconRegion class]]) {
//        self.fetchingiBeacon = YES;
//        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
//        //beaconRegion.notifyEntryStateOnDisplay = YES;
//        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kDidEnterRegionNotification object:self userInfo:@{@"region" : region}];
//}

//- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kDidExitRegionNotification object:self userInfo:@{@"region" : region}];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSTimeInterval maxAge = 60;
    CLLocationAccuracy requiredAccuracy = 100;
    BOOL locationIsValid = [[NSDate date] timeIntervalSinceDate:location.timestamp] < maxAge && location.horizontalAccuracy <= requiredAccuracy;
    if (locationIsValid) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdateLocationNotification object:nil userInfo:@{@"location" : location}];
        [self fetchedLocation:location];
        [self stopTracking];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {

    }
    else if (status == kCLAuthorizationStatusRestricted) {
     
    }
    else if (status == kCLAuthorizationStatusAuthorized) {
        [self startTrackingIfAuthorized];
//        [self startMonitoringBeaconRegions];
    }
}

-(void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:visit.coordinate.latitude longitude:visit.coordinate.longitude];
    [[APIClient sharedClient] postBackgroundLocation:location success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types & UIUserNotificationTypeAlert) {
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.alertTitle = @"Visit";
//            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\nTo: %@\nLocation: (%f, %f)",
//                                           [self.dateFormatter stringFromDate:visit.arrivalDate],
//                                           [self.dateFormatter stringFromDate:visit.departureDate],
//                                           visit.coordinate.latitude,
//                                           visit.coordinate.longitude];
//            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
//            localNotification.category = @"GLOBAL"; // Lazy categorization
//            
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        }
        NSLog(@"Background location sent to server successfully");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types & UIUserNotificationTypeAlert) {
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.alertTitle = @"Visit";
//            localNotification.alertBody = [NSString stringWithFormat:@"FAILURE! From: %@\nTo: %@\nLocation: (%f, %f)",
//                                           [self.dateFormatter stringFromDate:visit.arrivalDate],
//                                           [self.dateFormatter stringFromDate:visit.departureDate],
//                                           visit.coordinate.latitude,
//                                           visit.coordinate.longitude];
//            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
//            localNotification.category = @"GLOBAL"; // Lazy categorization
//            
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        }
        NSLog(@"Background location sent to server successfully");
    }];
}

#pragma mark - UIApplication Notifications
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self startTrackingIfAuthorized];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self stopTracking];
}

#pragma mark - other
- (CLLocationDistance)distanceFromCurrentLocationToCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    return [self.locationManager.location distanceFromLocation:location];
}


@end
