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

@end
