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
    self.dealDescription = dictionary[@"deal_description"];
    self.dealDescriptionShort = dictionary[@"deal_description_short"];
    self.inviteDescription = dictionary[@"invite_description"];
    self.inviteRequirement = dictionary[@"invite_requirement"];
    self.bonusDescription = dictionary[@"bonus_description"];
    self.notificationText = dictionary[@"notification_text"];
    self.invitePrompt = dictionary[@"invite_prompt"];
    self.additionalInfo = dictionary[@"additional_info"];
    self.dealType = dictionary[@"deal_type"];
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
    return [NSString stringWithFormat:@"%@-%@", startString, endString];
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
        return @"Now";
    } else if (now.second < hours.start) {
        //const float roundingValue = 0.5;
        CGFloat timeTillDeal = (hours.start - now.second)/(60*60);
        timeTillDeal = round(timeTillDeal * 2.0)/2.0;
        //int multiplier = floor(timeTillDeal / roundingValue);
        NSString *hourString;
        if (timeTillDeal == 1) {
            hourString = @"hour";
        } else {
            hourString = @"hours";
        }
        if (timeTillDeal == 0) {
            return @"Now";
        } else {
            if (timeTillDeal == (int)timeTillDeal) {
                NSString *timeTillDealString = [NSString stringWithFormat: @"%i", (int)timeTillDeal];
                return [NSString stringWithFormat: @"In %@ %@", timeTillDealString, hourString];
            } else {
                NSString *timeTillDealString = [NSString stringWithFormat: @"%.1f", (timeTillDeal)];
                return [NSString stringWithFormat: @"In %@ %@", timeTillDealString, hourString];
            }
        }
    } else {
        return @"";
    }

//    comps.hour = 0;
//    comps.minute = 0;
//    comps.second = hours.end;
//    NSDate *date = [gregorian dateFromComponents:comps];
//    NSString * endString = [date formattedTime];
//    comps.second = hours.start;
//    date = [gregorian dateFromComponents:comps];
//    NSString *startString = [date formattedTime];
//    return [NSString stringWithFormat:@"%@-%@", startString, endString];
}


@end
