//
//  Venue.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Venue.h"

@implementation Venue

- (id)initWithFoursquareDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.name = data[@"name"];
        self.foursquareID = data[@"id"];
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

- (id)initWithDealPlaceDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.venueID = dictionary[@"id"];
    self.name = dictionary[@"name"];
    NSNumber *latitude = dictionary[@"latitude"];
    NSNumber *longitude = dictionary[@"longitude"];
    self.coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    self.address = dictionary[@"street_address"];
    NSString *imageUrl = [NSString stringWithFormat:@"%@", dictionary[@"image_url"]];
    if (imageUrl != (id)[NSNull null] || imageUrl.length != 0) {
        self.imageURL = [NSURL URLWithString:imageUrl];
    }
    self.foursquareID = dictionary[@"foursquare_id"];
    self.placeDescription = dictionary[@"place_description"];
    self.yelpID = dictionary[@"yelp_id"];
    
    self.yelpReviewCount = dictionary[@"yelp_review_count"];
    NSString *yelpRatingImage = dictionary[@"yelp_rating_image_url"];
    if (![yelpRatingImage isEqual:[NSNull null]]){
        self.yelpRating = [NSURL URLWithString:yelpRatingImage];
    }
    return self;
}

@end
