//
//  RewardManager.h
//  Beacons
//
//  Created by Jasjit Singh on 5/13/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Voucher;
@interface RewardManager : NSObject

@property (strong, nonatomic) NSArray *vouchers;
@property (assign, nonatomic) BOOL isUpdatingRewards;

+ (RewardManager *)sharedManager;
- (void)updateActiveVouchers:(void (^)(NSArray *beacons))success
              failure:(void (^)(NSError *error))failure;
- (void)getActiveVouchers:(void (^)(NSArray *beacons, BOOL cached))success failure:(void (^)(NSError *error))failure;

@end
