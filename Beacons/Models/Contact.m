//
//  Contact.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "Contact.h"
#import "Utilities.h"
#import "User.h"
@implementation Contact


- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.fullName = data[@"name"];
        self.phoneNumber = data[@"phone_number"];
    }
    return self;
}

- (id)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        self.phoneNumber = user.phoneNumber;
        self.fullName = user.firstName;
        self.isUser = YES;
    }
    return self;
}


- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    _normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
}

@end
