//
//  HappyHour.h
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HappyHourVenue.h"

@class HappyHourVenue;
@interface HappyHour : NSObject

@property (strong, nonatomic) NSNumber *ID;
@property (strong, nonatomic) NSString *happyHourDescription;
@property (strong, nonatomic) NSNumber *start;
@property (strong, nonatomic) NSNumber *end;
@property (strong, nonatomic) HappyHourVenue *venue;


- (id)initWithDictionary:(NSDictionary *)dictionary;

@end