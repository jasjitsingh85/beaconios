
//
//  Utilities.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Utilities : NSObject

+ (BOOL)americanPhoneNumberIsValid:(NSString *)phoneNumber;
+ (BOOL)passwordIsValid:(NSString *)password;
+ (NSString *)normalizePhoneNumber:(NSString *)phoneNumber;
+ (void)presentFriendInviter;
+ (void)reverseGeoCodeLocation:(CLLocation *)location completion:(void (^)(NSString *addressString, NSError *error))completion;
+ (void)launchMapDirectionsToCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary destinationName:(NSString *)destinationName;
+ (void)launchGoogleMapsDirectionsToCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary destinationName:(NSString *)destinationName;
+ (void)launchAppleMapsDirectionsToCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary destinationName:(NSString *)destinationName;


@end
