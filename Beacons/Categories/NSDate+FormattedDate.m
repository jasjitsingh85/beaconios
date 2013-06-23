//
//  NSDate+FormattedDate.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "NSDate+FormattedDate.h"

@implementation NSDate (FormattedDate)

- (NSString *)formattedDate
{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"hh:mm a";
    return [timeFormatter stringFromDate:self];
}

@end
