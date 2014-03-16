//
//  Beacon+Time.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "Beacon+Time.h"

@implementation Beacon (Time)

- (BOOL)expired
{
    return !self.expirationDate || [[NSDate date] timeIntervalSinceDate:self.expirationDate] > 0;
}

- (BOOL)inDistantFuture
{
    return !self.time || [[NSDate date] timeIntervalSinceDate:self.time] < 60*60*2;
}

@end
