//
//  User.m
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "User.h"
#import "Utilities.h"

static User *_loggedInUser = nil;
static dispatch_once_t onceToken;

@implementation User

+ (User *)loggedInUser
{
    if (!_loggedInUser && [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyIsLoggedIn]) {
        dispatch_once(&onceToken, ^{
            _loggedInUser = [[User alloc] init];
            if (!_loggedInUser.userID) {
                _loggedInUser.phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyPhone];
                _loggedInUser.firstName = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyFirstName];
                _loggedInUser.lastName = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyLastName];
                _loggedInUser.userID = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyUserID];
                NSString *avatarURLString = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsAvatarURLKey];
                if (avatarURLString) {
                    _loggedInUser.avatarURL = [NSURL URLWithString:avatarURLString];
                }
            }
        });
    }
    return _loggedInUser;
}

+ (void)logoutUser
{
    _loggedInUser = nil;
    onceToken = 0;
}

- (id)initWithData:(NSDictionary *)userData
{
    self = [super init];
    if (self) {
        self.firstName = [userData valueForKeyPath:@"user.first_name"];
        self.lastName = [userData valueForKeyPath:@"user.last_name"];
        self.userID = [userData valueForKeyPath:@"user.id"];
        self.phoneNumber = userData[@"phone_number"];
        self.rewardScore = userData[@"reward_score"];
        NSString *avatarString = userData[@"avatar_url"];
        if (avatarString) {
            self.avatarURL = [NSURL URLWithString:avatarString];
        }
    }
    return self;
}

- (id)initWithUserDictionary:(NSDictionary *)userDictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.firstName = userDictionary[@"first_name"];
    self.lastName = userDictionary[@"last_name"];
    self.userID = userDictionary[@"id"];
    return self;
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    _normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
}

- (NSString *)fullName
{
    BOOL hasFirstName = self.firstName && self.firstName.length > 0;
    BOOL hasLastName = self.lastName && self.lastName.length > 0;
    if (hasFirstName && !hasLastName) {
        return self.firstName;
    }
    else if (hasFirstName && hasLastName) {
        return [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
    }
    return nil;
}

- (NSString *)abbreviatedName
{
    BOOL hasFirstName = self.firstName && self.firstName.length > 0;
    BOOL hasLastName = self.lastName && self.lastName.length > 0;
    if (hasFirstName && !hasLastName) {
        return self.firstName;
    }
    else if (hasFirstName && hasLastName) {
        return [NSString stringWithFormat:@"%@ %@.",self.firstName, [self.lastName substringToIndex:1]];
    }
    return nil;
}

@end
