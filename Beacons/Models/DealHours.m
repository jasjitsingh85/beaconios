//
//  DealHours.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealHours.h"

@implementation DealHours

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.start = [dictionary[@"start"] floatValue];
    self.end = [dictionary[@"end"] floatValue];
    self.days = dictionary[@"days"];
    return self;
}

- (BOOL)isAvailableAtDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];
    NSInteger weekday = [comps weekday];
    BOOL availableToday = [[self.days substringWithRange:NSMakeRange(weekday, 1)] isEqualToString:@"1"];
    NSTimeInterval time = comps.second + 60*comps.minute + 60*60*comps.hour;
    return availableToday && (time <= self.end && time >= self.start);

}

@end
