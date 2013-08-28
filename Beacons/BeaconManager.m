//
//  BeaconManager.m
//  Beacons
//
//  Created by Jeff Ames on 8/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconManager.h"
#import "APIClient.h"
#import "Beacon.h"
#import "LocationTracker.h"

@interface BeaconManager()

@property (strong, nonatomic) NSDate *dateLastUpdatedBeacons;

@end

@implementation BeaconManager

+ (BeaconManager *)sharedManager
{
    static BeaconManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BeaconManager alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDidEnterRegionNotification:) name:kDidEnterRegionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDidExitRegionNotification:) name:kDidExitRegionNotification object:nil];
    return self;
}

- (void)getBeacons:(void (^)(NSArray *, BOOL))success failure:(void (^)(NSError *))failure
{
    if (self.beacons) {
        success(self.beacons, YES);
        return;
    }
    [self updateBeacons:^(NSArray *beacons) {
        success(beacons, NO);
    } failure:failure];
}

- (void)updateBeacons:(void (^)(NSArray *beacons))success
              failure:(void (^)(NSError *error))failure
{
    __weak BeaconManager *weakSelf = self;
    [[APIClient sharedClient] getPath:@"beacon/follow/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *beacons = [[NSMutableArray alloc] init];
        for (NSDictionary *beaconData in responseObject) {
            Beacon *beacon = [[Beacon alloc] initWithData:beaconData];
            [beacons addObject:beacon];
        }
        weakSelf.beacons = [NSArray arrayWithArray:beacons];
        success(weakSelf.beacons);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)postBeacon:(Beacon *)beacon success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    self.currentBeacon = beacon;
    [[APIClient sharedClient] postBeacon:beacon success:^(AFHTTPRequestOperation *operation, id responseObject) {
        beacon.beaconID = [responseObject valueForKeyPath:@"beacon.id"];
        CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:beacon.coordinate radius:100 identifier:beacon.beaconID.stringValue];
        [[LocationTracker sharedTracker] monitorRegion:region];
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)confirmBeacon:(Beacon *)beacon
{
    self.currentBeacon = beacon;
    [[APIClient sharedClient] confirmBeacon:beacon.beaconID success:nil failure:nil];
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:beacon.coordinate radius:100 identifier:beacon.beaconID.stringValue];
    [[LocationTracker sharedTracker] monitorRegion:region];
}

- (void)receivedDidEnterRegionNotification:(NSNotification *)notification
{
    [[APIClient sharedClient] arriveBeacon:self.currentBeacon.beaconID success:nil failure:nil];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"you arrived at the beacon!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[LocationTracker sharedTracker] stopMonitoringForRegionWithIdentifier:self.currentBeacon.beaconID.stringValue];
}

- (void)receivedDidExitRegionNotification:(NSNotification *)notification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"you left the beacon!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

@end
