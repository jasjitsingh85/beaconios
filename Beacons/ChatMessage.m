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
#import "User.h"

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
    
    self.messageType = messageData[@"chat_type"];
    self.avatarURL = messageData[@"profile_pic"];
    
    return self;
}

- (BOOL)isImageMessage
{
    return self.imageURL || self.cachedImage;
}

- (BOOL)isLoggedInUserMessage
{
    return [self.sender.userID isEqualToNumber:[User loggedInUser].userID];
}

- (BOOL)isSystemMessage
{
    return self.messageType && [self.messageType isEqualToString:kMessageTypeSystemMessage];
}

@end
