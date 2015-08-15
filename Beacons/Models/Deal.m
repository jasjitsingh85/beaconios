//
//  Deal.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "Deal.h"
#import "Venue.h"
#import "DealHours.h"
#import "NSDate+FormattedDate.h"
#import <math.h>

@implementation Deal

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.dealID = dictionary[@"id"];
    self.inviteDescription = dictionary[@"invite_description"];
    self.inviteRequirement = dictionary[@"invite_requirement"];
    self.bonusDescription = dictionary[@"bonus_description"];
    self.itemName = dictionary[@"item_name"];
    self.itemPrice = dictionary[@"item_price"];
    self.notificationText = dictionary[@"notification_text"];
    self.additionalInfo = dictionary[@"additional_info"];
    self.dealType = dictionary[@"deal_type"];
    self.itemPointCost = dictionary[@"item_point_cost"];
    self.itemMarketPrice = dictionary[@"item_market_price"];
    NSNumber *bonusRequirement = dictionary[@"bonus_invite_requirement"];
    if (!isEmpty(bonusRequirement)) {
        self.bonusRequirement = bonusRequirement;
    }
    self.venue = [[Venue alloc] initWithDealPlaceDictionary:dictionary[@"place"]];
    NSMutableArray *hours = [[NSMutableArray alloc] init];
    for (NSDictionary *hoursDictionary in dictionary[@"hours"]) {
        [hours addObject:[[DealHours alloc] initWithDictionary:hoursDictionary]];
    }
    self.hours = [NSArray arrayWithArray:hours];
    
    if ([self.inviteRequirement intValue] > 1) {
        self.groupDeal = YES;
    } else {
        self.groupDeal = NO;
    }
    
    NSString *inAppPayment = dictionary[@"in_app_payment"];
    self.inAppPayment = [inAppPayment boolValue];
    
    NSString *rewardEligibility = dictionary[@"reward_eligibility"];
    self.rewardEligibility = [rewardEligibility boolValue];
    
    NSString *isRewardItem = dictionary[@"is_reward_item"];
    self.isRewardItem = [isRewardItem boolValue];
    
    NSString *isFollowed = dictionary[@"is_followed"];
    self.isFollowed = [isFollowed boolValue];
    
    if (self.inAppPayment) {
        self.dealDescriptionShort = [NSString stringWithFormat:@"%@ for $%@",self.itemName, self.itemPrice];
        self.dealDescription = [NSString stringWithFormat:@"%@ for $%@",self.itemName, self.itemPrice];
        self.invitePrompt = [NSString stringWithFormat:@"We're getting our first %@ for $%@",[self.itemName lowercaseString], self.itemPrice];
    } else {
        self.dealDescriptionShort = dictionary[@"deal_description_short"];
        self.dealDescription = dictionary[@"deal_description"];
        self.invitePrompt = dictionary[@"invite_prompt"];
    }
    
    return self;
}

- (BOOL)isAvailableAtDate:(NSDate *)date
{
    BOOL isAvailableAtDate = NO;
    for (DealHours *hours in self.hours) {
        isAvailableAtDate = isAvailableAtDate || [hours isAvailableAtDate:date];
    }
    return isAvailableAtDate;
}

- (NSString *)hoursAvailableString
{
    DealHours *hours = [self.hours firstObject];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    comps.hour = 0;
    comps.minute = 0;
    comps.second = hours.end;
    NSDate *date = [gregorian dateFromComponents:comps];
    NSString * endString = [date formattedTime];
    comps.second = hours.start;
    date = [gregorian dateFromComponents:comps];
    NSString *startString = [date formattedTime];
    return [NSString stringWithFormat:@"%@-%@", [self checkString:startString], [self checkString:endString]];
}

- (NSString *)endsAtString
{
    DealHours *hours = [self.hours firstObject];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    comps.hour = 0;
    comps.minute = 0;
    comps.second = hours.end;
    NSDate *date = [gregorian dateFromComponents:comps];
    NSString * endString = [date formattedTime];
    comps.second = hours.start;
    date = [gregorian dateFromComponents:comps];
    return [NSString stringWithFormat:@"%@", [self checkString:endString]];
}

- (NSString *)checkString:(NSString *)string
{
    if ([string isEqualToString:@"12:00AM"]) {
        return @"Midnight";
    } else {
        return string;
    }
}

//- (NSString *)todayOrTonightString
//{
//    DealHours *hours = [self.hours firstObject];
//    if (hours.start <= 64800) {
//        return @"DAILY SPECIALS";
//    } else {
//        return @"DAILY SPECIALS";
//    }
//}

- (NSString *)dealStartString
{
    DealHours *hours = [self.hours firstObject];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *now = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    now.second = (60*60*now.hour) + (60*now.minute) + now.second;
    
    if (now.second > hours.start && now.second < hours.end) {
        NSString *endsAtString = [NSString stringWithFormat:@"Ends at %@", [self endsAtString]];
        return endsAtString;
    } else if (now.second < hours.start) {
//        //const float roundingValue = 0.5;
//        CGFloat timeTillDeal = (hours.start - now.second)/(60*60);
//        timeTillDeal = round(timeTillDeal * 2.0)/2.0;
//        //int multiplier = floor(timeTillDeal / roundingValue);
//        NSString *hourString;
//        if (timeTillDeal == 1) {
//            hourString = @"hour";
//        } else {
//            hourString = @"hours";
//        }
//        if (timeTillDeal == 0) {
//            return @"Now";
//        } else {
//            if (timeTillDeal == (int)timeTillDeal) {
//                NSString *timeTillDealString = [NSString stringWithFormat: @"%i", (int)timeTillDeal];
//                return [NSString stringWithFormat: @"In %@ %@", timeTillDealString, hourString];
//            } else {
//                NSString *timeTillDealString = [NSString stringWithFormat: @"%.1f", (timeTillDeal)];
//                return [NSString stringWithFormat: @"In %@ %@", timeTillDealString, hourString];
//            }
//        }
        return [self hoursAvailableString];
    } else {
        return @"";
    }
}


@end
