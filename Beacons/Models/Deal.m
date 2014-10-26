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

@end
