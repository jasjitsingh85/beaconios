//
//  Event.h
//  Beacons
//
//  Created by Jasjit Singh on 10/4/15.
//  Copyright © 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Venue, SponsoredEvent;

@interface EventStatus : NSObject

@property (strong, nonatomic) NSNumber *eventStatusID;
@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end