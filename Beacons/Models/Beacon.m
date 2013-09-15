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
#import "AppDelegate.h"
#import "BeaconStatus.h"

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
        
        NSMutableArray *invited = [NSMutableArray new];
        Contact *creatorContact = [[Contact alloc] initWithUser:self.creator];
        BeaconStatus *creatorBeaconStatus = [[BeaconStatus alloc] init];
        creatorBeaconStatus.user = self.creator;
        creatorBeaconStatus.contact = creatorContact;
        creatorBeaconStatus.beaconStatusOption = BeaconStatusOptionGoing;
        [invited addObject:creatorBeaconStatus];
        for (NSDictionary *userData in data[@"followers"]) {
            User *user = [[User alloc] initWithData:userData];
            Contact *contact = [[Contact alloc] initWithUser:user];
            BeaconStatus *beaconStatus = [[BeaconStatus alloc] init];
            beaconStatus.user = user;
            beaconStatus.contact = contact;
            beaconStatus.beaconStatusOption = BeaconStatusOptionGoing;
            [invited addObject:beaconStatus];
        }
        
        for (NSDictionary *userData in data[@"profiles_invited"]) {
            User *user = [[User alloc] initWithData:userData];
            Contact *contact = [[Contact alloc] initWithUser:user];
            BeaconStatus *beaconStatus = [[BeaconStatus alloc] init];
            beaconStatus.user = user;
            beaconStatus.contact = contact;
            beaconStatus.beaconStatusOption = BeaconStatusOptionInvited;
            [invited addObject:beaconStatus];
        }
        for (NSDictionary *contactData in data[@"contacts_invited"]) {
            Contact *contact = [[Contact alloc] initWithData:contactData];
            BeaconStatus *beaconStatus = [[BeaconStatus alloc] init];
            beaconStatus.contact = contact;
            beaconStatus.beaconStatusOption = BeaconStatusOptionInvited;
            [invited addObject:beaconStatus];
        }
        self.invited = [NSArray arrayWithArray:invited];
        self.time = [NSDate dateWithTimeIntervalSince1970:[data[@"beacon_time"] doubleValue]];
        self.address = data[@"address"];
        if (!self.address || [self.address isEqualToString:@""]) {
            [self geoCodeAddress];
        }
        
        //by default user is attending
        self.userAttending = self.isUserBeacon;
        if (!self.userAttending) {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"beaconStatusOption = %d", BeaconStatusOptionGoing]];
            NSArray *beaconStatusGoing = [self.invited filteredArrayUsingPredicate:predicate];
            NSLog(@"going %@", beaconStatusGoing);
            for (BeaconStatus *beaconStatus in beaconStatusGoing) {
                self.userAttending = self.userAttending || [appDelegate.loggedInUser.normalizedPhoneNumber isEqualToString:beaconStatus.contact.normalizedPhoneNumber];
            }
        }
        
    }
    return self;
}

- (BOOL)isUserBeacon
{    
    if (!self.creator) {
        return NO;
    }
    //get logged in user id
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.loggedInUser && [appDelegate.loggedInUser.userID isEqualToNumber:self.creator.userID]) {
        return YES;
    }
    return NO;
}

- (void)geoCodeAddress
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count)
        {
            self.address = [placemarks[0] name];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBeaconUpdated object:self userInfo:nil];
        }
    }];
}

@end
