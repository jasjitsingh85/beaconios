//
//  Beacon.h
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class User, Deal, DealStatus, Venue;
@interface Beacon : NSObject <NSCoding>

@property (readonly) BOOL isUserBeacon;
@property (nonatomic, strong) NSNumber *beaconID;
@property (nonatomic, strong) User *creator;
@property (nonatomic, strong) NSDictionary *guestStatuses;
@property (nonatomic, strong) NSArray *dealStatuses;
@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) Venue *venue;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *beaconDescription;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSDate *expirationDate;
@property (assign, nonatomic) BOOL isAuthorized;
@property (readonly) BOOL userAttending;
@property (readonly) BOOL userHere;
@property (strong, nonatomic) NSURL *imageURL;
@property (readonly) DealStatus *userDealStatus;

- (id)initWithData:(NSDictionary *)data;
- (void)updateWithData:(NSDictionary *)data;

@end
