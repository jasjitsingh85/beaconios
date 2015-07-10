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
    NSString *imageUrl = [NSString stringWithFormat:@"%@", dictionary[@"image_url"]];
    if (imageUrl != (id)[NSNull null] || imageUrl.length != 0) {
         self.imageURL = [NSURL URLWithString:imageUrl];
    }
    self.placeDescription = dictionary[@"place_description"];
    self.yelpID = @"test";
    self.yelpRating = [NSURL URLWithString:@"http://s3-media2.fl.yelpcdn.com/assets/2/www/img/ccf2b76faa2c/ico/stars/v1/stars_large_4.png"];
    
    return self;
}

@end