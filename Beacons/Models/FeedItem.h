//
//  Feed.h
//  Beacons
//
//  Created by Jasjit Singh on 8/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface FeedItem : NSObject <SDWebImageManagerDelegate>

@property (strong, nonatomic) NSDate *dateCreated;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) BOOL isImageDownloaded;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSNumber *dealPlaceID;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)dateString;
- (UIImage *)image;

@end