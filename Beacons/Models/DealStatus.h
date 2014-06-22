//
//  DealStatus.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Contact;
@interface DealStatus : NSObject

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) NSString *dealStatus;
@property (strong, nonatomic) NSString *bonusStatus;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
