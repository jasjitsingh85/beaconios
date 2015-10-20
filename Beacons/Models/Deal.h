//
//  Deal.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Venue, DealHours;
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
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSNumber *itemPrice;
@property (strong, nonatomic) NSNumber *itemPointCost;
@property (strong, nonatomic) NSNumber *itemMarketPrice;
@property (strong, nonatomic) NSNumber *inviteRequirement;
@property (strong, nonatomic) NSNumber *bonusRequirement;
@property (strong, nonatomic) NSArray *hours;
@property (strong, nonatomic) Venue *venue;
@property (assign, nonatomic) BOOL groupDeal;
@property (assign, nonatomic) BOOL inAppPayment;
@property (assign, nonatomic) BOOL locked;
@property (assign, nonatomic) BOOL rewardEligibility;
@property (assign, nonatomic) BOOL isRewardItem;
@property (assign, nonatomic) BOOL isFollowed;
@property (assign, nonatomic) long nowInSeconds;
@property (assign, nonatomic) long start;
@property (assign, nonatomic) long end;
@property (strong, nonatomic) DealHours *todayDealHour;

@property (readonly) NSString *hoursAvailableString;
@property (readonly) NSString *dealStartString;
//@property (readonly) NSString *todayOrTonightString;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isAvailableAtDate:(NSDate *)date;

@end
