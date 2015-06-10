//
//  HappyHour.m
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HappyHour.h"
#import "HappyHourVenue.h"
#import "NSDate+FormattedDate.h"
#import <math.h>

@implementation HappyHour

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.ID = dictionary[@"id"];
    self.happyHourDescription = dictionary[@"description"];
    self.start = dictionary[@"start"];
    self.end = dictionary[@"end"];
    self.venue = [[HappyHourVenue alloc] initWithDictionary:dictionary[@"place"]];

    return self;
}

- (NSString *)happyHourStartString
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *now = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    now.second = (60*60*now.hour) + (60*now.minute) + now.second;
    
    NSInteger start = [self.start integerValue];
    NSInteger end = [self.end integerValue];
    
    if (now.second > start && now.second < end) {
        return @"Now";
    } else if (now.second < start) {
        //const float roundingValue = 0.5;
        CGFloat timeTillDeal = (start - now.second)/(60*60);
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
        return @"Ended";
    }
}

@end