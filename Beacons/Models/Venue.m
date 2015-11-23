//
//  Venue.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Venue.h"
#import "Deal.h"
#import "HappyHour.h"
#import "Event.h"

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

- (id)initWithDictionary:(NSDictionary *)dictionary
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
    
    NSDictionary *dealDictionary = dictionary[@"deal"];
    if (!isEmpty(dealDictionary)) {
        self.deal = [[Deal alloc] initWithDictionary:dealDictionary];
    }
    
    NSString *isFollowed = dictionary[@"is_followed"];
    self.isFollowed = [isFollowed boolValue];
    
    NSString *placeType = dictionary[@"place_type"];
    self.placeType = placeType;
    
    NSString *neighborhood = dictionary[@"neighborhood"];
    self.neighborhood = neighborhood;
    
    if (!isEmpty(dictionary[@"happy_hour"])) {
        self.happyHour = [[HappyHour alloc] initWithDictionary:dictionary[@"happy_hour"]] ;
    }
    
    self.events = [[NSMutableArray alloc] init];
    if (!isEmpty(dictionary[@"events"])) {
        for (NSDictionary *eventJSON in dictionary[@"events"]) {
            Event *event = [[Event alloc] initWithDictionary:eventJSON];
            [self.events addObject:event];
        }
    }

    self.photos = [[NSMutableArray alloc] init];
    if (!isEmpty(dictionary[@"photos"])) {
        for (NSString *photo in dictionary[@"photos"]) {
            NSURL *photoURL = [[NSURL alloc] initWithString:photo];
            [self.photos addObject:photoURL];
        }
    }
    
    return self;
}

@end
