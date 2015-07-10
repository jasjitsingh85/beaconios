//
//  HappyHourVenue.h
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HappyHourVenue : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *placeDescription;
@property (assign, nonatomic) CLLocationDistance distance;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *yelpID;
@property (strong, nonatomic) NSString *yelpReviewCount;
@property (strong, nonatomic) NSURL *yelpRating;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
