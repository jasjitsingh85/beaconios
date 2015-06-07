//
//  HappyHour.m
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HappyHour.h"
#import "HappyHourVenue.h"

@implementation HappyHour

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.ID = dictionary[@"id"];
    self.happyHourDescription = dictionary[@"description"];
    self.start = dictionary[@"start"];
    self.end = dictionary[@"end"];
    self.venue = [[HappyHourVenue alloc] initWithDictionary:dictionary[@"place"]];

    return self;
}


@end