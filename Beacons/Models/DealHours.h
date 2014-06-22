//
//  DealHours.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/22/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DealHours : NSObject

@property (assign, nonatomic) CGFloat start;
@property (assign, nonatomic) CGFloat end;
@property (strong, nonatomic) NSString *days;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isAvailableAtDate:(NSDate *)date;

@end
