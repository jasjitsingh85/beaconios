//
//  Event.m
//  Beacons
//
//  Created by Jasjit Singh on 10/4/15.
//  Copyright © 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "Event.h"

@implementation Event

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.title = dictionary[@"title"];
    //self.websiteURL = dictionary[@"website"];
    
    NSString *websiteURLString = dictionary[@"website"];
    if (![websiteURLString isEqual:[NSNull null]]){
        self.websiteURL = [NSURL URLWithString:websiteURLString];
    }
    
    NSNumber *startTimestamp = dictionary[@"start_time"];
    self.startTime = [NSDate dateWithTimeIntervalSince1970:startTimestamp.floatValue];
    
    self.venue = [[Venue alloc] initWithDealPlaceDictionary:dictionary[@"place"]];
    
    return self;
}

-(NSString *)getDateAsString
{
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE - h:mm a"];
    
    
    
    NSString *dateString = [NSString stringWithFormat:@"%@", [day stringFromDate:self.startTime]];
    return dateString;
}

@end