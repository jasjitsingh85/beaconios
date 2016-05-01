//
//  Event.h
//  Beacons
//
//  Created by Jasjit Singh on 10/4/15.
//  Copyright © 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    EventStatusNoSelection=0,
    EventStatusGoing,
    EventStatusInterested,
    EventStatusRedeemed,
} EventStatusOption;

@class Venue, EventStatus;

@interface SponsoredEvent : NSObject

@property (strong, nonatomic) NSNumber *eventID;
@property (strong, nonatomic) NSNumber *itemPrice;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSNumber *presaleItemPrice;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *eventDescription;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
//@property (assign, nonatomic) BOOL isReserved;
@property (assign, nonatomic) BOOL isSoldOut;
@property (strong, nonatomic) Venue *venue;
@property (strong, nonatomic) NSString *socialMessage;
@property (strong, nonatomic) NSString *statusMessage;
@property (strong, nonatomic) NSString *chatChannelUrl;
@property (strong, nonatomic) NSURL *websiteURL;
@property (strong, nonatomic) NSURL *deepLinkURL;
@property (strong, nonatomic) EventStatus *eventStatus;
@property (assign, nonatomic) EventStatusOption eventStatusOption;
@property (assign, nonatomic) BOOL presaleActive;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)getDateAsString;

@end