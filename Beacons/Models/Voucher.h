//
//  Voucher.h
//  Beacons
//
//  Created by Jasjit Singh on 5/13/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Deal;
@interface Voucher : NSObject

@property (strong, nonatomic) NSNumber *voucherID;
@property (strong, nonatomic) Deal *deal;
@property (assign, nonatomic) BOOL isRedeemed;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
