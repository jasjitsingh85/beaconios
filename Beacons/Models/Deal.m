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
    self.todayDealHours = [[NSMutableArray alloc] init];
    
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
//    DealHours *hours = [self.hours firstObject];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    comps.hour = 0;
    comps.minute = 0;
    comps.second = self.end;
    NSDate *date = [gregorian dateFromComponents:comps];
    NSString * endString = [date formattedTime];
    comps.second = self.start;
    date = [gregorian dateFromComponents:comps];
    NSString *startString = [date formattedTime];
    return [NSString stringWithFormat:@"%@-%@", [self checkString:startString], [self checkString:endString]];
}

- (NSString *)endsAtString
{
//    DealHours *hours = [self.hours firstObject];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    comps.hour = 0;
    comps.minute = 0;
    comps.second = self.end;
    NSDate *date = [gregorian dateFromComponents:comps];
    NSString * endString = [date formattedTime];
//    comps.second = hours.start;
    date = [gregorian dateFromComponents:comps];
    return [NSString stringWithFormat:@"%@", [self checkString:endString]];
}

- (NSString *)checkString:(NSString *)string
{
    if ([string isEqualToString:@"12:00AM"]) {
        return @"Midnight";
    } else if ([string isEqualToString:@"12:00PM"]) {
        return @"Noon";
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

- (DealHours *)getTodayDealHour
{
    //self.todayDealHour = [self.hours firstObject];
    NSDate *now = [NSDate date];
    
    for (DealHours *hour in self.hours)
    {
        if ([hour isAvailableAtDate:now])
        {
            [self.todayDealHours addObject:hour];
        }
    }
    
    self.todayDealHour = [self.todayDealHours firstObject];
    for (DealHours *hour in self.todayDealHours)
    {
        if (self.nowInSeconds < hour.end && self.nowInSeconds > hour.start) {
            self.todayDealHour = hour;
            return self.todayDealHour;
        } else if (hour.start > self.nowInSeconds && hour.start < self.todayDealHour.start) {
            self.todayDealHour = hour;
        }
    }
    return self.todayDealHour;
}

- (DealHours *)getTomorrowDealHour
{
    if (self.todayDealHour.end == 86400) {
        NSDate *now = [NSDate date];
        int daysToAdd = 1;
        NSDate *tomorrow = [now dateByAddingTimeInterval:60 * 60 * 24 * daysToAdd];
        
        for (DealHours *hour in self.hours)
        {
            if ([hour isAvailableAtDate:tomorrow] && hour.start == 0 && hour.end != 86400)
            {
                return hour;
            }
        }
        return nil;
    } else {
        return nil;
    }
}

- (NSString *)dealStartString
{
//    DealHours *hours = [self.hours firstObject];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *now = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    self.nowInSeconds = (60*60*now.hour) + (60*now.minute) + now.second;
    
    DealHours *todayDealHour = [self getTodayDealHour];
    DealHours *tomorrowDealHour = [self getTomorrowDealHour];
    
    self.start = todayDealHour.start;
    if (tomorrowDealHour == nil) {
        self.end = todayDealHour.end;
    } else {
        self.end = tomorrowDealHour.end;
    }
    
    if (self.nowInSeconds > self.start && self.nowInSeconds < todayDealHour.end) {
        NSString *endsAtString = [NSString stringWithFormat:@"Ends at %@", [self endsAtString]];
        return endsAtString;
    } else if (now.second < self.start) {
        return [self hoursAvailableString];
    } else {
        return @"";
    }
}


@end
