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
    
    NSString *websiteURLString = dictionary[@"web_url"];
    if (![websiteURLString isEqual:[NSNull null]]){
        self.websiteURL = [NSURL URLWithString:websiteURLString];
    }
    
    NSString *deepLinkURLString = dictionary[@"deep_link_url"];
    if (![deepLinkURLString isEqual:[NSNull null]]){
        self.deepLinkURL = [NSURL URLWithString:deepLinkURLString];
    }
    
    NSNumber *startTimestamp = dictionary[@"start_time"];
    self.startTime = [NSDate dateWithTimeIntervalSince1970:startTimestamp.floatValue];
    
    if ([dictionary objectForKey:@"place"]) {
        self.venue = [[Venue alloc] initWithDealPlaceDictionary:dictionary[@"place"]];
    }
    
    return self;
}

-(NSString *)getDateAsString
{
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE h:mm a"];
    
    self.startTime = [self dateRoundedDownTo5Minutes:self.startTime];
    
    NSString *dateString = [NSString stringWithFormat:@"%@", [day stringFromDate:self.startTime]];
    return dateString;
}

- (NSDate *) dateRoundedDownTo5Minutes:(NSDate *)dt{
    int referenceTimeInterval = (int)[dt timeIntervalSinceReferenceDate];
    int remainingSeconds = referenceTimeInterval % 300;
    int timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
    if(remainingSeconds>150)
    {/// round up
        timeRoundedTo5Minutes = referenceTimeInterval +(300-remainingSeconds);
    }
    NSDate *roundedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)timeRoundedTo5Minutes];
    return roundedDate;
}

@end