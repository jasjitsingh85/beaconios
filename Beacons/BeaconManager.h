//
//  BeaconManager.h
//  Beacons
//
//  Created by Jeff Ames on 8/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Beacon;
@interface BeaconManager : NSObject

@property (strong, nonatomic) NSArray *beacons;
@property (strong, nonatomic) Beacon *currentBeacon;

+ (BeaconManager *)sharedManager;
- (void)updateBeacons:(void (^)(NSArray *beacons))success
              failure:(void (^)(NSError *error))failure;
- (void)getBeaconWithID:(NSNumber *)beaconID success:(void (^)(Beacon *beacon))success
                failure:(void (^)(NSError *error))failure;
- (void)getBeacons:(void (^)(NSArray *beacons, BOOL cached))success failure:(void (^)(NSError *error))failure;
- (void)confirmBeacon:(Beacon *)beacon;
- (void)postBeacon:(Beacon *)beacon success:(void (^)())success failure:(void (^)(NSError *error))failure;
@end
