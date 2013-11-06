//
//  Utilities.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Utilities.h"
#import "RandomObjectManager.h"
#import "AppDelegate.h"
#import "AnalyticsManager.h"

@implementation Utilities


+ (BOOL)americanPhoneNumberIsValid:(NSString *)phoneNumber
{
    NSString *normalizedNumber = [self normalizePhoneNumber:phoneNumber];
    NSString *phoneRegex = @"[1]?[2-9]{1}[0-9]{9}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [test evaluateWithObject:normalizedNumber];
}

+ (BOOL)passwordIsValid:(NSString *)password
{
//    NSString *passwordRegex = @"((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{6,20})";
    NSString *passwordRegex = @"(.{6,20})"; //between 6 and 20 characters long
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    return [test evaluateWithObject:password];
}

+ (NSString *)normalizePhoneNumber:(NSString *)phoneNumber
{
    if (!phoneNumber) {
        return nil;
    }
    //must be consistent with server
    NSString *normalizedNumber = phoneNumber;
    //trim out parentheses, plus, minus, and space
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    characterSet = [characterSet invertedSet];
    normalizedNumber = [[normalizedNumber componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString: @""];
    if (!normalizedNumber || !normalizedNumber.length) {
        return normalizedNumber;
    }
    if ([[normalizedNumber substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"]) {
        normalizedNumber = [normalizedNumber substringWithRange:NSMakeRange(1, normalizedNumber.length-1)];
    }
    return normalizedNumber;
}

+ (void)presentFriendInviter
{
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    NSString *text = [[RandomObjectManager sharedManager] randomInviteFriendsToAppString];
    [activityItems addObject:text];
    
    [activityItems addObject:[NSURL URLWithString:@"http://gethotspotapp.com"]];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    activityViewController.excludedActivityTypes =  @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        [[AnalyticsManager sharedManager] inviteToApp:activityType completed:completed];
    };
    [[AppDelegate sharedAppDelegate].window.rootViewController presentViewController:activityViewController animated:YES completion:^{}];
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

+ (void)reverseGeoCodeLocation:(CLLocation *)location completion:(void (^)(NSString *addressString, NSError *error))completion
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *address;
        if (placemarks.count)
        {
            address = [placemarks[0] name];
        }
        if (completion) {
            completion(address, error);
        }
    }];
}

@end
