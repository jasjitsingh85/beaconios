//
//  Beacon.m
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Beacon.h"
#import "User.h"
#import "Contact.h"
#import "Constants.h"
#import "BeaconStatus.h"
#import "BeaconImage.h"
#import "Utilities.h"

@implementation Beacon

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.beaconID = data[@"id"];
        self.creator = [[User alloc] initWithData:data[@"profile"]];
        self.beaconDescription = data[@"description"];
        NSNumber *latitude = data[@"latitude"];
        NSNumber *longitude = data[@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        
        NSMutableDictionary *guestStatuses = [[NSMutableDictionary alloc] init];
        for (NSDictionary *guestData in data[@"guests"]) {
            BeaconStatus *status = [[BeaconStatus alloc] initWithData:guestData];
            NSString *key;
            if (status.contact) {
                key = status.contact.normalizedPhoneNumber;
            }
            else if (status.user) {
                key = status.user.normalizedPhoneNumber;
            }
            [guestStatuses setObject:status forKey:key];
        }
        self.guestStatuses = [NSDictionary dictionaryWithDictionary:guestStatuses];
        
        self.time = [NSDate dateWithTimeIntervalSince1970:[data[@"beacon_time"] doubleValue]];
        self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:[data[@"expiration"] doubleValue]];
        self.address = data[@"address"];
        if (!self.address || [self.address isEqualToString:@""]) {
            [self geoCodeAddress];
        }
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSDictionary *imageData in data[@"images"]) {
            BeaconImage *beaconImage = [[BeaconImage alloc] init];
            beaconImage.uploader = [[User alloc] initWithData:imageData[@"user"]];
            beaconImage.imageURL = [NSURL URLWithString:imageData[@"image_url"]];
            [images addObject:beaconImage];
        }
        self.images = [NSArray arrayWithArray:images];
        
    }
    return self;
}

- (BOOL)isUserBeacon
{    
    if (!self.creator) {
        return NO;
    }
    //get logged in user id
    if ([User loggedInUser] && [[User loggedInUser].userID isEqualToNumber:self.creator.userID]) {
        return YES;
    }
    return NO;
}

- (BOOL)userAttending
{
    if (self.isUserBeacon) {
        return YES;
    }
    BeaconStatus *userStatus = self.guestStatuses[[User loggedInUser].normalizedPhoneNumber];
    return userStatus && (userStatus.beaconStatusOption == BeaconStatusOptionGoing || userStatus.beaconStatusOption == BeaconStatusOptionHere);
}

- (void)geoCodeAddress
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    [Utilities reverseGeoCodeLocation:location completion:^(NSString *addressString, NSError *error) {
        self.address = addressString;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBeaconUpdated object:self userInfo:nil];
        }];
}

@end
