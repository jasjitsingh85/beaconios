//
//  HappyHourVenue.m
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "HappyHourVenue.h"

@implementation HappyHourVenue

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.name = dictionary[@"name"];
    NSNumber *latitude = dictionary[@"latitude"];
    NSNumber *longitude = dictionary[@"longitude"];
    self.coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    self.address = dictionary[@"street_address"];
    self.imageURL = [NSURL URLWithString:dictionary[@"image_url"]];
    return self;
}

@end