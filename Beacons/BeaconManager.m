//
//  BeaconManager.m
//  Beacons
//
//  Created by Jeff Ames on 8/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconManager.h"
#import <CocoaLumberjack/DDLog.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "APIClient.h"
#import "Beacon.h"
#import "LocationTracker.h"
#import "User.h"

@interface BeaconManager()

@property (strong, nonatomic) NSDate *dateLastUpdatedBeacons;
@property (strong, nonatomic) NSDate *dateLastSentLocation;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
    [self unarchiveBeacons];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)updateArchivedBeaconsWithBeacon:(Beacon *)beacon
{
    NSMutableArray *beacons = self.beacons ? [NSMutableArray arrayWithArray:self.beacons] : [[NSMutableArray alloc] init];
    //remove existing beacon if necessary
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beaconID = %@", beacon.beaconID];
    NSArray *existing = [beacons filteredArrayUsingPredicate:predicate];
    if (existing && existing.count) {
        [beacons removeObject:[existing firstObject]];
    }
    [beacons addObject:beacon];
    self.beacons = [NSArray arrayWithArray:beacons];
    [self archiveBeacons];
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

- (void)cancelBeacon:(Beacon *)beacon success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"beacon_id" : beacon.beaconID,
                                 @"cancelled" : @(YES)};
    [[APIClient sharedClient] putPath:@"hotspot/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateBeacon:(Beacon *)beacon success:(void (^)(Beacon *updatedBeacon))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:beacon.beaconID forKey:@"beacon_id"];
    [parameters setValue:beacon.beaconDescription forKey:@"description"];
    [parameters setValue:@(beacon.time.timeIntervalSince1970) forKey:@"time"];
    [parameters setValue:@(beacon.coordinate.latitude) forKey:@"latitude"];
    [parameters setValue:@(beacon.coordinate.longitude) forKey:@"longitude"];
    if (beacon.address) {
        [parameters setValue:beacon.address forKey:@"address"];
    }
    else {
        [parameters setValue:@"" forKey:@"address"];
    }
    [[APIClient sharedClient] putPath:@"hotspot/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [beacon updateWithData:responseObject[@"beacon"]];
        if (success) {
            success(beacon);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateArchivedBeaconsWithBeacon:beacon];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postBeacon:(Beacon *)beacon success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    CLLocation *location = [LocationTracker sharedTracker].currentLocation;
    [[APIClient sharedClient] postBeacon:beacon userLocation:location success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [beacon updateWithData:responseObject[@"beacon"]];
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:beacon.coordinate radius:100 identifier:beacon.beaconID.stringValue];
        [[LocationTracker sharedTracker] monitorRegion:region];
        if (success) {
            success();
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateArchivedBeaconsWithBeacon:beacon];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)confirmBeacon:(Beacon *)beacon success:(void (^)())success failure:(void (^)(NSError *error))failure
{
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
    DDLogInfo(@"received did enter region notification");
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
    DDLogInfo(@"did arrive at beacon with id %@", beaconID);
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
    
    DDLogInfo(@"will show push notification for beacon with id %@ expiration date %@", beacon.beaconID, beacon.expirationDate);
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

- (void)shouldUpdateLocationSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [[LocationTracker sharedTracker] fetchCurrentLocation:^(CLLocation *location) {
        self.dateLastSentLocation = [NSDate date];
        [[APIClient sharedClient] postLocation:location success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[responseObject allKeys] containsObject:@"isHere"] && [responseObject[@"isHere"] count]) {
                [responseObject[@"isHere"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Beacon *beacon = [[Beacon alloc] initWithData:obj];
                    NSArray *checkInPrompts = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyCheckinPromptHotspots];
                    BOOL hasAlreadyPrompted = checkInPrompts && [checkInPrompts containsObject:beacon.beaconID];
                    if (!beacon.userHere && !hasAlreadyPrompted) {
                        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                        localNotification.alertBody = @"Looks like you are at a hotspot. Want to check in?";
                        localNotification.userInfo = @{kLocalNotificationTypeKey : kLocalNotificationTypeCheckinPrompt,
                                                       @"beaconID" : beacon.beaconID};
                        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                        *stop = YES;
                    }
                }];
            }
            if (success) {
                success();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)didUpdateLocation:(NSNotification *)notification
{
    if (self.dateLastSentLocation && [[NSDate date] timeIntervalSinceDate:self.dateLastSentLocation] < 60*2) {
        return;
    }
    CLLocation *location = notification.userInfo[@"location"];
    self.dateLastSentLocation = [NSDate date];
    [[APIClient sharedClient] postLocation:location success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject allKeys] containsObject:@"isHere"] && [responseObject[@"isHere"] count]) {
            [responseObject[@"isHere"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Beacon *beacon = [[Beacon alloc] initWithData:obj];
                if (!beacon.userHere) {
                    [self promptUserToCheckInToBeacon:beacon success:nil failure:nil];
                    *stop = YES;
                }
            }];
        }
    } failure:nil];
    
}

- (void)promptUserToCheckInToBeacon:(Beacon *)beacon success:(void (^)(BOOL checkedIn))success failure:(void (^)(NSError *error))failure
{
    NSMutableArray *checkInPrompts = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyCheckinPromptHotspots];
    if (!checkInPrompts) {
        checkInPrompts = [[NSMutableArray alloc] init];
    }
    else {
        checkInPrompts = [NSMutableArray arrayWithArray:checkInPrompts];
    }
    
    if ([checkInPrompts containsObject:beacon.beaconID]) {
        return;
    }
    [checkInPrompts addObject:beacon.beaconID];
    [[NSUserDefaults standardUserDefaults] setObject:checkInPrompts forKey:kDefaultsKeyCheckinPromptHotspots];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *title = @"You're here!";
    if (beacon.beaconDescription) {
        title = [NSString stringWithFormat:@"Looks like you've arrived at %@", beacon.beaconDescription];
    }
    NSString *message = @"Want to check in?";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message];
    [alertView addButtonWithTitle:@"No, thanks" handler:^{
        if (success) {
            success(NO);
        }
    }];
    [alertView setCancelButtonWithTitle:@"Yes" handler:^{
        [[APIClient sharedClient] checkInFriendWithID:[User loggedInUser].userID isUser:YES atbeacon:beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (success) {
                success(YES);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }];
    [alertView show];
}

@end
