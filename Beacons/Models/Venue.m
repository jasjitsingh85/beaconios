//
//  Venue.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Venue.h"

@implementation Venue

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.name = data[@"name"];
        NSNumber *latitude = [data valueForKeyPath:@"location.lat"];
        NSNumber *longitude = [data valueForKeyPath:@"location.lng"];
        self.coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
        self.address = [data valueForKeyPath:@"location.address"];
        NSNumber *distance = [data valueForKeyPath:@"location.distance"];
        if (distance) {
            self.distance = distance.floatValue;
        }
    }
    return self;
}

@end
