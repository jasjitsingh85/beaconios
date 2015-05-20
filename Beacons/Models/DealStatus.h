//
//  DealStatus.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Contact, Deal, Venue;
@interface DealStatus : NSObject

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) NSString *dealStatus;
@property (strong, nonatomic) NSString *bonusStatus;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (assign, nonatomic) BOOL feedback;
@property (assign, nonatomic) BOOL paymentAuthorization;
@property (strong, nonatomic) NSURL *imageURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
