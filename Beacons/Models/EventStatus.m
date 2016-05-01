//
//  Event.m
//  Beacons
//
//  Created by Jasjit Singh on 10/4/15.
//  Copyright © 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "EventStatus.h"
#import "SponsoredEvent.h"

@implementation EventStatus

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.eventStatusID = dictionary[@"id"];
    
    self.status = dictionary[@"status"];
    
    NSString *isPresale = dictionary[@"is_presale"];
    self.isPresale = [isPresale boolValue];
    
//    if ([dictionary objectForKey:@"event"]) {
//        self.sponsoredEvent = [[SponsoredEvent alloc] initWithDictionary:dictionary[@"event"]];
//    }
    
    return self;
}

@end