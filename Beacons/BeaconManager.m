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

- (void)setCurrentBeacon:(Beacon *)currentBeacon
{
    _currentBeacon = currentBeacon;
    [[LocationTracker sharedTracker] stopMonitoringAllRegions];
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:currentBeacon.coordinate radius:100 identifier:currentBeacon.beaconID.stringValue];
    [[LocationTracker sharedTracker] monitorRegion:region];
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

- (void)getBeaconWithID:(NSNumber *)beaconID success:(void (^)(Beacon *beacon))success
                failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon_id" : beaconID};
    [[APIClient sharedClient] getPath:@"beacon/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Beacon *beacon = [[Beacon alloc] initWithData:responseObject[@"beacon"]];
        if (success) {
            success(beacon);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateBeacons:(void (^)(NSArray *beacons))success
              failure:(void (^)(NSError *error))failure
{
    __weak BeaconManager *weakSelf = self;
    [[APIClient sharedClient] getPath:@"follow/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    [[APIClient sharedClient] postBeacon:beacon success:^(AFHTTPRequestOperation *operation, id responseObject) {
        beacon.beaconID = [responseObject valueForKeyPath:@"beacon.id"];
        self.currentBeacon = beacon;
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)confirmBeacon:(Beacon *)beacon success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    self.currentBeacon = beacon;
    [[APIClient sharedClient] confirmBeacon:beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
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
