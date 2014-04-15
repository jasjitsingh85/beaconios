//
//  NSDate+FormattedDate.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FormattedDate)

- (NSString *)formattedTime;
- (NSString *)fullFormattedDate;
- (NSString *)formattedDay;

@end
