//
//  Venue.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Venue : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationDistance distance;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *foursquareID;

- (id)initWithFoursquareDictionary:(NSDictionary *)data;
- (id)initWithDealPlaceDictionary:(NSDictionary *)dictionary;

@end
