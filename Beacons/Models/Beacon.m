//
//  Beacon.m
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Beacon.h"
#import "User.h"

@implementation Beacon

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.beaconID = data[@"id"];
        self.creator = [[User alloc] initWithData:data[@"creator"]];
        self.beaconDescription = data[@"description"];
        NSNumber *latitude = data[@"latitude"];
        NSNumber *longitude = data[@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    }
    return self;
}

@end
