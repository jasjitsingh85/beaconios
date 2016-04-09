//
//  DealStatus.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DatingProfile.h"
#import "User.h"

@implementation DatingProfile

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.datingProfileID = dictionary[@"id"];
    
    NSDictionary *userDictionary = dictionary[@"dating_profile"];
    if (!isEmpty(userDictionary)) {
        self.user = [[User alloc] initWithData:userDictionary];
    }

    self.imageURL = [NSURL URLWithString:dictionary[@"image_url"]];
    
    self.userGender = dictionary[@"user_gender"];
    
    self.userPreference = dictionary[@"preference"];
    
    return self;
}

@end
