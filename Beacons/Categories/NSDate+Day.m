//
//  NSDate+Day.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "NSDate+Day.h"

@implementation NSDate (Day)

- (NSDate *)day
{
    return [NSDate dayWithTimeIntervalSinceNow:[self timeIntervalSinceNow]];
}

- (NSDate *)week
{
    return [NSDate weekWithTimeIntervalSinceNow:[self timeIntervalSinceNow]];
}

- (BOOL)sameDay:(NSDate *)date
{
    return [self.day isEqualToDate:date.day];
}

- (BOOL)sameWeek:(NSDate *)date
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSUInteger flag = (NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit);
//    NSDateComponents *selfComponents = [cal components:flag fromDate:self];
//    NSDateComponents *dateComponents = [cal components:flag fromDate:date];
//    return selfComponents.era == dateComponents.era && selfComponents.year == dateComponents.year && selfComponents.month ==
}

+ (NSDate *)today
{
    return [self dayWithTimeIntervalSinceNow:0];
}

+ (NSDate *)tomorrow
{
    return [self dayWithTimeIntervalSinceNow:60*60*24];
}

+ (NSDate *)weekWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSWeekCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    NSDate *date = [cal dateFromComponents:components];
    return date;
}

+ (NSDate *)dayWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    NSDate *date = [cal dateFromComponents:components];
    return date;
}

@end
