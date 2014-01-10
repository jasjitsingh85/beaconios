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

typedef void (^FetchLocationSuccessBlock)(CLLocation *location);
typedef void (^FetchLocationFailureBlock)(NSError *error);


@interface LocationTracker()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FetchLocationSuccessBlock fetchLocationSuccessBlock;
@property (strong, nonatomic) FetchLocationFailureBlock fetchLocationFailureBlock;
@property (assign, nonatomic) BOOL fetchingLocation;

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
        self.locationManager.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)startTrackingIfAuthorized
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopTracking
{
    [self.locationManager stopUpdatingLocation];
}

- (void)requestLocationPermission
{
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
        NSTimeInterval maxAge = 60;
        CLLocationAccuracy requiredAccuracy = 100;
        BOOL locationIsValid = currentLocation && [[NSDate date] timeIntervalSinceDate:currentLocation.timestamp] < maxAge && currentLocation.horizontalAccuracy <= requiredAccuracy;
        if (locationIsValid) {
            [self fetchedLocation:currentLocation];
        }
        else {
            [self.locationManager startUpdatingLocation];
            self.fetchingLocation = YES;
            jadispatch_after_delay(10, dispatch_get_main_queue(), ^{
                if (self.fetchingLocation) {
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
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return self.locationManager.location;
    }
    NSLog(@"requested location before authorizing");
    return nil;
}

- (void)monitorRegion:(CLRegion *)region
{
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringForRegionWithIdentifier:(NSString *)regionIdentifier
{
    NSSet *regions = [self.locationManager.monitoredRegions filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", regionIdentifier]];
    CLRegion *region = [regions anyObject];
    if (region) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void)stopMonitoringAllRegions
{
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidEnterRegionNotification object:self userInfo:@{@"region" : region}];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidExitRegionNotification object:self userInfo:@{@"region" : region}];
}

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
        [[[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"Go to Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else if (status == kCLAuthorizationStatusRestricted) {
     
    }
    else if (status == kCLAuthorizationStatusAuthorized) {
        [self startTrackingIfAuthorized];
    }
}

#pragma mark - UIApplication Notifications
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    CLLocation *currentLocation = [self currentLocation];
    if (!currentLocation || (currentLocation && [[NSDate date] timeIntervalSinceDate:currentLocation.timestamp] > 60)) {
        [self startTrackingIfAuthorized];
    }
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
