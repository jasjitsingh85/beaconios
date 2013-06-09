//
//  Utilities.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities


+ (BOOL)americanPhoneNumberIsValid:(NSString *)phoneNumber
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"()-"];
    NSString *trimmedNumber = [phoneNumber stringByTrimmingCharactersInSet:characterSet];
    NSString *phoneRegex = @"[1]?[235689]{1}[0-9]{9}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [test evaluateWithObject:trimmedNumber];
}

+ (BOOL)passwordIsValid:(NSString *)password
{
//    NSString *passwordRegex = @"((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{6,20})";
    NSString *passwordRegex = @"(.{6,20})"; //between 6 and 20 characters long
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    return [test evaluateWithObject:password];
}

+ (void)launchMapDirectionsToCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary destinationName:(NSString *)destinationName
{
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = destinationName;
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}

@end
