//
//  NSDate+Day.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Day)

- (NSDate *)day;
- (NSDate *)week;
- (BOOL)sameDay:(NSDate *)date;
- (BOOL)sameWeek:(NSDate *)date;
+ (NSDate *)today;
+ (NSDate *)tomorrow;

@end
