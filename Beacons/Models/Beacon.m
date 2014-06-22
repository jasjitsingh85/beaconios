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
#import "DealStatus.h"
#import "Deal.h"
#import "BeaconImage.h"
#import "Utilities.h"

@implementation Beacon

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        [self updateWithData:data];
    }
    return self;
}

- (void)updateWithData:(NSDictionary *)data
{
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
    
//    deals
    NSArray *dealStatusesDictionary = data[@"deal_statuses"];
    if (!isEmpty(dealStatusesDictionary)) {
        NSMutableArray *dealStatuses = [[NSMutableArray alloc] init];
        for (NSDictionary *dealStatusDictionary in dealStatusesDictionary) {
            [dealStatuses addObject:[[DealStatus alloc] initWithDictionary:dealStatusDictionary]];
        }
        self.dealStatuses = [NSArray arrayWithArray:dealStatuses];
    }
    NSDictionary *dealDictionary = data[@"deal"];
    if (!isEmpty(dealDictionary)) {
        self.deal = [[Deal alloc] initWithDictionary:dealDictionary];
    }
    
    self.time = [NSDate dateWithTimeIntervalSince1970:[data[@"beacon_time"] doubleValue]];
    self.expirationDate = [NSDate dateWithTimeIntervalSince1970:[data[@"expiration"] doubleValue]];
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

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.beaconID = [aDecoder decodeObjectForKey:@"beaconID"];
    self.time = [aDecoder decodeObjectForKey:@"time"];
    self.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.beaconID forKey:@"beaconID"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];
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

- (BOOL)hasDeal
{
    return self.dealStatuses && self.dealStatuses.count;
}

- (BOOL)userAttending
{
    if (self.isUserBeacon) {
        return YES;
    }
    BeaconStatus *userStatus = self.guestStatuses[[User loggedInUser].normalizedPhoneNumber];
    return userStatus && (userStatus.beaconStatusOption == BeaconStatusOptionGoing || userStatus.beaconStatusOption == BeaconStatusOptionHere);
}

- (BOOL)userHere
{
    BeaconStatus *userStatus = self.guestStatuses[[User loggedInUser].normalizedPhoneNumber];
    return userStatus && userStatus.beaconStatusOption == BeaconStatusOptionHere;
}

- (DealStatus *)userDealStatus
{
    DealStatus *dealStatus = nil;
    if (self.dealStatuses) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userID = %@", [User loggedInUser].userID];
        NSArray *results = [self.dealStatuses filteredArrayUsingPredicate:predicate];
        dealStatus = [results firstObject];
    }
    return dealStatus;
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
