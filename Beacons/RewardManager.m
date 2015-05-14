//
//  RewardManager.m
//  Beacons
//
//  Created by Jasjit Singh on 5/13/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//


#import "RewardManager.h"
#import "Voucher.h"
#import <CocoaLumberjack/DDLog.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "Beacon+Time.h"
#import "APIClient.h"
#import "Beacon.h"
#import "LocationTracker.h"
#import "User.h"

@interface RewardManager()

@property (strong, nonatomic) NSDate *dateLastUpdatedBeacons;
@property (strong, nonatomic) NSDate *dateLastSentLocation;

@end

@implementation RewardManager

+ (RewardManager *)sharedManager
{
    static RewardManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[RewardManager alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)getActiveVouchers:(void (^)(NSArray *, BOOL))success failure:(void (^)(NSError *))failure
{
    [self updateActiveVouchers:^(NSArray *beacons) {
        success(beacons, NO);
    } failure:failure];
}

- (void)updateActiveVouchers:(void (^)(NSArray *beacons))success
              failure:(void (^)(NSError *error))failure
{
    self.isUpdatingRewards = YES;
    __weak RewardManager *weakSelf = self;
    [[APIClient sharedClient] getPath:@"rewards/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *vouchers = [[NSMutableArray alloc] init];
        for (NSDictionary *voucherData in responseObject[@"vouchers"]) {
            Voucher *voucher = [[Voucher alloc] initWithDictionary:voucherData];
            [vouchers addObject:voucher];
        }
        weakSelf.vouchers = [NSArray arrayWithArray:vouchers];
        if (success) {
            success(weakSelf.vouchers);
        }
        weakSelf.isUpdatingRewards = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        weakSelf.isUpdatingRewards = NO;
    }];
}

@end

