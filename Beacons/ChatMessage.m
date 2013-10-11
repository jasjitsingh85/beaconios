//
//  ChatMessage.m
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatMessage.h"
#import "User.h"
#import "AppDelegate.h"
#import "BeaconImage.h"

@implementation ChatMessage

- (id)initWithData:(NSDictionary *)messageData
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSDictionary *userData = messageData[@"sender"];
    if (userData && ![userData isEqual:[NSNull null]]) {
        self.sender = [[User alloc] initWithData:messageData[@"sender"]];
    }
    self.messageString = messageData[@"message"];
    if ([self.messageString isEqual:[NSNull null]]) {
        self.messageString = @"";
    }
    NSDictionary *imageData = messageData[@"image"];
    if (imageData && ![imageData isEqual:[NSNull null]]) {
        self.imageURL = [NSURL URLWithString:imageData[@"image_url"]];
    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.isUserMessage = [self.sender.userID isEqualToNumber:appDelegate.loggedInUser.userID];
    return self;
}

- (BOOL)isImageMessage
{
    return self.imageURL || self.cachedImage;
}

@end
