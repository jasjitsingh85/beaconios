//
//  DealStatus.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealStatus.h"
#import "User.h"
#import "Contact.h"

@implementation DealStatus

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.dealStatus = dictionary[@"deal_status"];
    self.bonusStatus = dictionary[@"bonus_status"];
    
    NSDictionary *userDictionary = dictionary[@"user"];
    if (!isEmpty(userDictionary)) {
        self.user = [[User alloc] initWithUserDictionary:userDictionary];
    }
    
    NSNumber *startTimestamp = dictionary[@"start_time"];
    NSNumber *endTimestamp = dictionary[@"end_time"];
    self.startDate = [NSDate dateWithTimeIntervalSince1970:startTimestamp.floatValue];
    self.endDate = [NSDate dateWithTimeIntervalSince1970:endTimestamp.floatValue];
    
    NSDictionary *contactDictionary = dictionary[@"contact"];
    if (!isEmpty(contactDictionary)) {
        self.contact = [[Contact alloc] initWithData:contactDictionary];
    }
    
    NSString *feedback = dictionary[@"feedback_boolean"];
    self.feedback = [feedback boolValue];
    
    return self;
}

@end
