//
//  User.m
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "User.h"
#import "Utilities.h"

@implementation User

- (id)initWithData:(NSDictionary *)userData
{
    self = [super init];
    if (self) {
        self.firstName = [userData valueForKeyPath:@"user.first_name"];
        self.lastName = [userData valueForKeyPath:@"user.last_name"];
        self.userID = [userData valueForKeyPath:@"user.id"];
        self.phoneNumber = userData[@"phone_number"];
        NSString *avatarString = userData[@"avatar_url"];
        if (avatarString) {
            self.avatarURL = [NSURL URLWithString:avatarString];
        }
    }
    return self;
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    _normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
}

@end
