//
//  Beacon.h
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class User;
@interface Beacon : NSObject

@property (readonly) BOOL isUserBeacon;
@property (nonatomic, strong) NSNumber *beaconID;
@property (nonatomic, strong) User *creator;
@property (nonatomic, strong) NSArray *invited;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *beaconDescription;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, assign) BOOL userAttending;

- (id)initWithData:(NSDictionary *)data;

@end
