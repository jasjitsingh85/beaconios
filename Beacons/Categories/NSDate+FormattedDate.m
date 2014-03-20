//
//  NSDate+FormattedDate.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "NSDate+FormattedDate.h"
#import "NSDate+Day.h"

@implementation NSDate (FormattedDate)

- (NSString *)formattedDate
{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"h:mm a";
    return [timeFormatter stringFromDate:self];
}

- (NSString *)fullFormattedDate
{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    NSString *stringFromDate;
    if ([self.day sameDay:[NSDate today]]) {
        timeFormatter.dateFormat = @"h:mm a";
        stringFromDate = [NSString stringWithFormat:@"Today, %@", [timeFormatter stringFromDate:self]];
    }
    else if ([self.day sameDay:[NSDate tomorrow]]) {
        timeFormatter.dateFormat = @"h:mm a";
        stringFromDate = [NSString stringWithFormat:@"Tomorrow, %@", [timeFormatter stringFromDate:self]];
        
    }
    else if ([self.week sameWeek:[NSDate date]]) {
        timeFormatter.dateFormat = @"E h:mm a";
        stringFromDate = [timeFormatter stringFromDate:self];
    }
    else {
        timeFormatter.dateFormat = @"EEEE MMMM d h:mm a";
        stringFromDate = [timeFormatter stringFromDate:self];
    }
    return stringFromDate;
}

- (NSString *)formattedDay
{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    NSString *stringFromDate;
    if ([[self day] isEqualToDate:[NSDate today]]) {
        stringFromDate = @"Today";
    }
    else if ([[self day] isEqualToDate:[NSDate tomorrow]]) {
        timeFormatter.dateFormat = @"MMMM d";
        stringFromDate = [NSString stringWithFormat:@"Tomorrow, %@", [timeFormatter stringFromDate:self]];
        
    }
    else {
        timeFormatter.dateFormat = @"EEEE, MMMM d";
        stringFromDate = [timeFormatter stringFromDate:self];
    }
    return stringFromDate;
}

@end
