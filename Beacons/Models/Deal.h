//
//  Deal.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Venue;
@interface Deal : NSObject

@property (strong, nonatomic) NSNumber *dealID;
@property (strong, nonatomic) NSString *dealDescription;
@property (strong, nonatomic) NSString *dealDescriptionShort;
@property (strong, nonatomic) NSString *inviteDescription;
@property (strong, nonatomic) NSString *invitePrompt;
@property (strong, nonatomic) NSString *notificationText;
@property (strong, nonatomic) NSString *bonusDescription;
@property (strong, nonatomic) NSString *additionalInfo;
@property (strong, nonatomic) NSString *dealType;
@property (strong, nonatomic) NSNumber *inviteRequirement;
@property (strong, nonatomic) NSNumber *bonusRequirement;
@property (strong, nonatomic) NSArray *hours;
@property (strong, nonatomic) Venue *venue;

@property (readonly) NSString *hoursAvailableString;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isAvailableAtDate:(NSDate *)date;

@end
