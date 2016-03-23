//
//  ChatMessage.m
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatMessage.h"
#import "User.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "BeaconImage.h"
#import "User.h"
#import <SendBirdSDK/SendBirdSDK.h>

@implementation ChatMessage

- (id)initWithData:(NSDictionary *)messageData
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSDictionary *userData = messageData[@"sender"];
    if (![userData isEmpty]) {
        self.sender = [[User alloc] initWithData:userData];
    }
    NSDictionary *contactData = messageData[@"contact"];
    if (![contactData isEmpty]) {
        self.contactSender = [[Contact alloc] initWithData:contactData];
    }
    self.messageString = messageData[@"message"];
    if ([self.messageString isEqual:[NSNull null]]) {
        self.messageString = @"";
    }
    NSDictionary *imageData = messageData[@"image"];
    if (![imageData isEmpty]) {
        self.imageURL = [NSURL URLWithString:imageData[@"image_url"]];
    }
    
    self.messageType = messageData[@"chat_type"];
    self.avatarURL = messageData[@"profile_pic"];
    
    return self;
}

- (id)initMessageWithSendBirdData:(SendBirdMessage *)messageData
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.sender = [[User alloc] initWithSendBirdUserData:messageData.sender];
    
    NSDictionary *contactData = nil;
    if (![contactData isEmpty]) {
        self.contactSender = [[Contact alloc] initWithData:contactData];
    }
    
    if ([self.messageString isEqual:[NSNull null]]) {
        self.messageString = @"";
    } else {
        self.messageString = messageData.message;
    }
    
    NSString *imageData = messageData.data;
    if (![imageData isEmpty]) {
        self.imageURL = [NSURL URLWithString:imageData];
    }
    
    self.messageType = @"";
    self.avatarURL = [NSURL URLWithString:messageData.sender.imageUrl];
    
    return self;
}

- (id)initFileWithSendBirdData:(SendBirdFileLink *)fileData
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.sender = [[User alloc] initWithSendBirdUserData:fileData.sender];
    
    NSDictionary *contactData = nil;
    if (![contactData isEmpty]) {
        self.contactSender = [[Contact alloc] initWithData:contactData];
    }
    
    self.messageString = @"";
    
    SendBirdFileInfo *fileInfo = fileData.fileInfo;
    if (![fileInfo isEmpty]) {
        self.imageURL = [NSURL URLWithString:fileInfo.url];
    }
    
    self.messageType = @"";
    self.avatarURL = [NSURL URLWithString:fileData.sender.imageUrl];
    
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
