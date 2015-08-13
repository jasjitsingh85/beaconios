//
//  FeedItem.m
//  Beacons
//
//  Created by Jasjit Singh on 8/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@implementation FeedItem

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.source = dictionary[@"source"];
    NSNumber *dateCreated = dictionary[@"date_created"];
    self.dateCreated = [NSDate dateWithTimeIntervalSince1970:dateCreated.floatValue];
    self.message = dictionary[@"message"];
    self.thumbnailURL = dictionary[@"thumbnail"];
    NSString *imageUrl = [NSString stringWithFormat:@"%@", dictionary[@"image_url"]];
    if (imageUrl != (id)[NSNull null] || imageUrl.length != 0) {
        self.imageURL = [NSURL URLWithString:imageUrl];
    }
    self.name = dictionary[@"name"];

    return self;
}

- (NSString *) dateString {
    NSDate *now = [NSDate date];
    NSTimeInterval interval;
    interval = [now timeIntervalSinceDate:self.dateCreated];
    NSInteger days = floor(interval/(60.0*60.0*24));
    NSInteger hours = floor((interval - days*60*60*24)/(60.0*60.0));
    NSInteger minutes = floor((interval - days*60*60*24 - hours*60*60)/60.0);
    
    if (days == 0 && hours == 0 && minutes < 15) {
        return @"Now";
    } else if (days == 0 && hours == 0 && minutes >= 15 && minutes < 60) {
        NSString *dateString = [NSString stringWithFormat:@"%ld min", (long)minutes];
        return dateString;
    } else if (days == 0 && hours == 1 && minutes <= 30) {
        NSString *dateString = [NSString stringWithFormat:@"%ld hour", (long)hours];
        return dateString;
    } else if (days == 0 && hours == 1 && minutes <= 30) {
        NSString *dateString = [NSString stringWithFormat:@"%ld hour", (long)hours];
        return dateString;
    } else if (days == 0 && hours > 2 && minutes <= 30) {
        NSString *dateString = [NSString stringWithFormat:@"%ld hours", (long)hours];
        return dateString;
    }  else if (days == 0 && hours > 1 && hours <= 23 && minutes >= 30) {
        hours = hours + 1;
        NSString *dateString = [NSString stringWithFormat:@"%ld hours", (long)hours];
        return dateString;
    } else if (days == 1) {
        return @"Yesterday";
    } else if (days > 1) {
        NSString *dateString = [NSString stringWithFormat:@"%ld days", (long)days];
        return dateString;
    }
//    NSInteger seconds = interval - 60*60*hours - 60*minutes;
    
    
    NSString *timeLeft = [NSString stringWithFormat:@" %ld %ld:%02ld", (long)days, (long)hours, (long)minutes];
    return timeLeft;
}

@end