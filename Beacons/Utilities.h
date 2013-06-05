//
//  Utilities.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (BOOL)americanPhoneNumberIsValid:(NSString *)phoneNumber;
+ (BOOL)passwordIsValid:(NSString *)password;

@end
