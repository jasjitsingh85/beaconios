//
//  LocationTracker.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LocationTracker.h"

@interface LocationTracker()

@property (strong, nonatomic) CLLocationManager *locationManager;

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
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            [self.locationManager startUpdatingLocation];
        }
    }
    return self;
}

- (void)requestLocationPermission
{
    [self.locationManager startUpdatingLocation];
}

- (CLLocation *)currentLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return self.locationManager.location;
    }
    NSLog(@"requested location before authorizing");
    return [[CLLocation alloc] initWithLatitude:0 longitude:0];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidUpdateLocation object:nil userInfo:@{@"location" : location}];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"Go to Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else if (status == kCLAuthorizationStatusRestricted) {
     
    }
    else if (status == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - UIApplication Notifications
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.locationManager stopUpdatingLocation];
}


@end
