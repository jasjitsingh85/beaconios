//
//  CrashManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 7/23/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CrashManager.h"
#import <Crittercism/Crittercism.h>
#import "User.h"

@interface CrashManager()

@property (assign, nonatomic) BOOL crittercismEnabled;

@end

@implementation CrashManager

+ (CrashManager *)sharedManager
{
    static CrashManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [CrashManager new];
        
    });
    return _sharedManager;
}

+ (void)enableCrittercism
{
    [Crittercism enableWithAppID:@"51ef4f30558d6a5c00000003"];
    [CrashManager sharedManager].crittercismEnabled = YES;
}

+ (void)setupForUser
{
    if (![CrashManager sharedManager].crittercismEnabled) {
        [CrashManager enableCrittercism];
    }
    User *loggedInUser = [User loggedInUser];
    if (!loggedInUser || !loggedInUser.userID) {
        return;
    }
    NSString *firstName = loggedInUser.firstName ? loggedInUser.firstName : @"";
    NSString *lastName = loggedInUser.lastName ? loggedInUser.lastName : @"";
    NSString *username = [firstName stringByAppendingString:lastName];
    [Crittercism setUsername:username];
}

@end
