//
//  Event.h
//  Beacons
//
//  Created by Jasjit Singh on 10/4/15.
//  Copyright © 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Venue;

@interface Event : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *websiteURL;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) Venue *venue;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)getDateAsString;

@end