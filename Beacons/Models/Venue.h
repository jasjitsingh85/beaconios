//
//  Venue.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Deal;
@interface Venue : NSObject

@property (strong, nonatomic) NSNumber *venueID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationDistance distance;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *foursquareID;
@property (strong, nonatomic) NSString *yelpID;
@property (strong, nonatomic) NSURL *yelpRating;
@property (strong, nonatomic) NSString *yelpReviewCount;
@property (strong, nonatomic) NSString *placeDescription;
@property (strong, nonatomic) NSString *placeType;
@property (strong, nonatomic) Deal *deal;
@property (assign, nonatomic) BOOL isFollowed;

- (id)initWithFoursquareDictionary:(NSDictionary *)data;
- (id)initWithDealPlaceDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;


@end
