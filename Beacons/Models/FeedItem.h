//
//  Feed.h
//  Beacons
//
//  Created by Jasjit Singh on 8/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedItem : NSObject

@property (strong, nonatomic) NSDate *dateCreated;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)dateString;

@end