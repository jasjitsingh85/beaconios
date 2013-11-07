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
    [self unarchiveBeacons];
    return self;
}

- (void)archiveBeacons
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.beacons];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kDefaultsKeyArchivedBeacons];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unarchiveBeacons
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyArchivedBeacons];
    self.beacons = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)setCurrentBeacon:(Beacon *)currentBeacon
{
    _currentBeacon = currentBeacon;
    [[LocationTracker sharedTracker] stopMonitoringAllRegions];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:currentBeacon.coordinate radius:100 identifier:currentBeacon.beaconID.stringValue];
    [[LocationTracker sharedTracker] monitorRegion:region];
}

- (void)setBeacons:(NSArray *)beacons
{
    _beacons = beacons;
    [[LocationTracker sharedTracker] stopMonitoringAllRegions];
    for (Beacon *beacon in beacons) {
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:beacon.coordinate radius:100 identifier:beacon.beaconID.stringValue];
        [[LocationTracker sharedTracker] monitorRegion:region];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self archiveBeacons];
    });
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
#if DEBUG
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Debugging. Entered region";
#endif
    
    CLRegion *region = notification.userInfo[@"region"];
    NSNumber *beaconID = @(region.identifier.integerValue);
    [self didArriveAtBeaconWithID:beaconID];
}

- (void)didArriveAtBeaconWithID:(NSNumber *)beaconID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beaconID = %@", beaconID];
    NSArray *filtered = [self.beacons filteredArrayUsingPredicate:predicate];
    Beacon *beacon = [filtered firstObject];
    if (!beacon) {
        return;
    }
//    make sure not expired
    if (!beacon.expirationDate || [[NSDate date] timeIntervalSinceDate:beacon.expirationDate] > 0) {
        return;
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You arrived at a Hotspot. Want to check yourself in?";
    localNotification.userInfo = @{@"beaconID" : beaconID};
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[LocationTracker sharedTracker] stopMonitoringForRegionWithIdentifier:beacon.beaconID.stringValue];
}

- (void)receivedDidExitRegionNotification:(NSNotification *)notification
{
#if DEBUG
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Debugging. Exited region";
#endif
}

@end
