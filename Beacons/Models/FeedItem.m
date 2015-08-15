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
    self.isImageDownloaded = NO;
    if (imageUrl != (id)[NSNull null] || imageUrl.length != 0) {
        self.imageURL = [NSURL URLWithString:imageUrl];
        [self getImage];
        
    }
    self.name = dictionary[@"name"];
    
    NSString *dealPlaceString = dictionary[@"deal_place_id"];
    self.dealPlaceID = [NSNumber numberWithInteger: [dealPlaceString integerValue]];
    
    return self;
}

- (NSString *) dateString {
    NSDate *now = [NSDate date];
    NSTimeInterval interval;
    interval = [now timeIntervalSinceDate:self.dateCreated];
    NSInteger days = floor(interval/(60.0*60.0*24));
    NSInteger hours = floor((interval - days*60*60*24)/(60.0*60.0));
    NSInteger minutes = floor((interval - days*60*60*24 - hours*60*60)/60.0);
    
//    NSLog(@"DATE CREATED: %@", self.dateCreated);
//    NSLog(@"Days: %ld", (long)days);
//    NSLog(@"Hours: %ld", (long)hours);
//    NSLog(@"Min: %ld", (long)minutes);
    
    if (days == 0 && hours == 0 && minutes < 15) {
        return @"Now";
    } else if (days == 0 && hours == 0 && minutes >= 15 && minutes < 60) {
        NSString *dateString = [NSString stringWithFormat:@"%ld min", (long)minutes];
        return dateString;
    } else if (days == 0 && hours == 1 && minutes <= 30) {
        NSString *dateString = [NSString stringWithFormat:@"%ld hr", (long)hours];
        return dateString;
    } else if (days == 0 && hours == 1 && minutes <= 30) {
        NSString *dateString = [NSString stringWithFormat:@"%ld hr", (long)hours];
        return dateString;
    } else if (days == 0 && hours >= 2 && minutes <= 30) {
        NSString *dateString = [NSString stringWithFormat:@"%ld hr", (long)hours];
        return dateString;
    }  else if (days == 0 && hours > 1 && hours <= 23 && minutes > 30) {
        hours = hours + 1;
        NSString *dateString = [NSString stringWithFormat:@"%ld hr", (long)hours];
        return dateString;
    } else if (days == 1) {
        return @"1 day";
    } else if (days > 1) {
        NSString *dateString = [NSString stringWithFormat:@"%ld days", (long)days];
        return dateString;
    } else {
        return @"";
    }
//    NSInteger seconds = interval - 60*60*hours - 60*minutes;
    
//    
//    NSString *timeLeft = [NSString stringWithFormat:@" %ld %ld:%02ld", (long)days, (long)hours, (long)minutes];
//    return timeLeft;
}

- (void)getImage
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:self.imageURL options:(0) progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        self.image = [self scaleImage:image scaledToMaxWidth:280 maxHeight:280];
        self.isImageDownloaded = YES;
    }];
}

- (UIImage *)scaleImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end