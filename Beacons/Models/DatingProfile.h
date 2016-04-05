//
//  DealStatus.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface DatingProfile : NSObject

@property (strong, nonatomic) NSNumber *datingProfileID;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *userGender;
@property (strong, nonatomic) NSString *userPreference;
@property (strong, nonatomic) NSURL *imageURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
