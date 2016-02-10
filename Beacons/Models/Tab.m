//
//  Tab.m
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tab.h"

@implementation Tab

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.tabID = dictionary[@"id"];
    
    NSString *isClaimed = dictionary[@"tab_claimed"];
    self.isClaimed = [isClaimed boolValue];
    self.subtotal = dictionary[@"subtotal"];
    self.tax = dictionary[@"tax"];
    self.convenienceFee = dictionary[@"convenience_fee"];
    
    return self;
}

@end
