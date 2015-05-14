//
//  Voucher.m
//  Beacons
//
//  Created by Jasjit Singh on 5/13/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//


#import "Voucher.h"
#import "Deal.h"

@implementation Voucher

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.voucherID = dictionary[@"id"];
    NSDictionary *dealDictionary = dictionary[@"deal"];
    if (!isEmpty(dealDictionary)) {
        self.deal = [[Deal alloc] initWithDictionary:dealDictionary];
    }
    NSString *isRedeemed = dictionary[@"isRedeemed"];
    self.isRedeemed = [isRedeemed boolValue];
    
    return self;
}

@end
