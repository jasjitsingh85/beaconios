//
//  Event.m
//  Beacons
//
//  Created by Jasjit Singh on 10/4/15.
//  Copyright © 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "SponsoredEvent.h"
#import "EventStatus.h"

@implementation SponsoredEvent

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.eventID = dictionary[@"id"];
    
    self.itemPrice = dictionary[@"item_price"];
    
    self.title = dictionary[@"title"];
    
    self.eventDescription = dictionary[@"description"];
    
    NSDictionary *event_status = dictionary[@"event_status"];
    if (event_status == (id)[NSNull null]) {
        self.isReserved = NO;
        self.eventStatus = nil;
    } else {
        self.isReserved = YES;
        self.eventStatus = [[EventStatus alloc] initWithDictionary:dictionary[@"event_status"]];
    }
    
    NSNumber *startTimestamp = dictionary[@"start_time"];
    self.startTime = [NSDate dateWithTimeIntervalSince1970:startTimestamp.floatValue];
    
    NSNumber *endTimestamp = dictionary[@"end_time"];
    self.endTime = [NSDate dateWithTimeIntervalSince1970:endTimestamp.floatValue];
    
    if ([dictionary objectForKey:@"place"]) {
        self.venue = [[Venue alloc] initWithDictionary:dictionary[@"place"]];
    }
    
    NSString *websiteURLString = dictionary[@"web_url"];
    if (![websiteURLString isEqual:[NSNull null]]){
        self.websiteURL = [NSURL URLWithString:websiteURLString];
    }
    
    NSString *deepLinkURLString = dictionary[@"deep_link_url"];
    if (![deepLinkURLString isEqual:[NSNull null]]){
        self.deepLinkURL = [NSURL URLWithString:deepLinkURLString];
    }
    
    if (dictionary[@"social_message"] != nil || dictionary[@"social_message"] != (id)[NSNull null]) {
        self.socialMessage = dictionary[@"social_message"];
    } else {
        self.socialMessage = @"";
    }

    if (dictionary[@"status_message"] != nil || dictionary[@"status_message"] != (id)[NSNull null]) {
        self.statusMessage = dictionary[@"status_message"];
    } else {
        self.statusMessage = @"";
    }
    
    return self;
}

-(NSString *)getDateAsString
{
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE h:mma"];
    
    NSDateFormatter *endTimeFormat = [[NSDateFormatter alloc] init];
    [endTimeFormat setDateFormat: @"h:mma"];
    
    self.startTime = [self dateRoundedDownTo5Minutes:self.startTime];
    self.endTime = [self dateRoundedDownTo5Minutes:self.endTime];
    
    NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [day stringFromDate:self.startTime], [endTimeFormat stringFromDate:self.endTime]];
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