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
    
    self.chatChannelUrl = dictionary[@"chat_channel_url"];
    
    NSString *isSoldOut = dictionary[@"is_sold_out"];
    self.isSoldOut = [isSoldOut boolValue];
    
    NSDictionary *event_status = dictionary[@"event_status"];
    if (event_status == (id)[NSNull null]) {
        self.eventStatusOption = EventStatusNoSelection;
        self.eventStatus = nil;
    } else {
        self.eventStatus = [[EventStatus alloc] initWithDictionary:dictionary[@"event_status"]];
        if ([self.eventStatus.status isEqualToString:@"I"]) {
            self.eventStatusOption = EventStatusInterested;
        } else if ([self.eventStatus.status isEqualToString:@"U"]) {
            self.eventStatusOption = EventStatusGoing;
        } else if ([self.eventStatus.status isEqualToString:@"R"]) {
            self.eventStatusOption = EventStatusRedeemed;
        } else if ([self.eventStatus.status isEqualToString:@"N"]) {
            self.eventStatusOption = EventStatusNoSelection;
        }
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
    self.startTime = [self dateRoundedDownTo5Minutes:self.startTime];
    self.endTime = [self dateRoundedDownTo5Minutes:self.endTime];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    comps.day = 7;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *nextWeek = [calendar dateByAddingComponents:comps toDate:now options:nil];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compToCheckMinutes = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.startTime];
    
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    NSDateFormatter *endTimeFormat = [[NSDateFormatter alloc] init];
    if ([self date:self.startTime isBetweenDate:now andDate:nextWeek]) {
        
        if (compToCheckMinutes.minute == 0) {
            [day setDateFormat: @"EEEE ha"];
            [endTimeFormat setDateFormat: @"ha"];
        } else {
            [day setDateFormat: @"EEEE h:mma"];
            [endTimeFormat setDateFormat: @"h:mma"];
        }
        
        NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [day stringFromDate:self.startTime], [endTimeFormat stringFromDate:self.endTime]];
        return dateString;
    } else {
        
        if (compToCheckMinutes.minute == 0) {
            [day setDateFormat: @"MMM d, ha"];
            [endTimeFormat setDateFormat: @"ha"];
        } else {
            [day setDateFormat: @"MMM d, h:mma"];
            [endTimeFormat setDateFormat: @"h:mma"];
        }
        
        NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [day stringFromDate:self.startTime], [endTimeFormat stringFromDate:self.endTime]];
        return dateString;
    }
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
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