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

@end
