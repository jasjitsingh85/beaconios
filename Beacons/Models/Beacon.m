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
        
        NSMutableArray *attending = [NSMutableArray new];
        for (NSDictionary *userData in data[@"followers"]) {
            User *user = [[User alloc] initWithData:userData];
            Contact *contact = [[Contact alloc] initWithUser:user];
            [attending addObject:contact];
        }
        self.attending = [NSArray arrayWithArray:attending];
        
        NSMutableArray *invited = [NSMutableArray new];
        for (NSDictionary *userData in data[@"profiles_invited"]) {
            User *user = [[User alloc] initWithData:userData];
            Contact *contact = [[Contact alloc] initWithUser:user];
            [invited addObject:contact];
        }
        for (NSDictionary *contactData in data[@"contacts_invited"]) {
            Contact *contact = [[Contact alloc] initWithData:contactData];
            [invited addObject:contact];
        }
        self.invited = [NSArray arrayWithArray:invited];
        self.time = [NSDate date];
        
        if (!self.address) {
            [self geoCodeAddress];
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
