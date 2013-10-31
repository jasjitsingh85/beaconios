//
//  ChatMessage.h
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Contact;
@interface ChatMessage : NSObject

@property (strong, nonatomic) NSString *messageString;
@property (strong, nonatomic) NSURL *avatarURL;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIImage *cachedImage;
@property (strong, nonatomic) NSDate *sentDate;
@property (strong, nonatomic) User *sender;
@property (strong, nonatomic) Contact *contactSender;
@property (strong, nonatomic) NSString *messageType;
@property (readonly) BOOL isImageMessage;
//@property (readonly) BOOL isUserMessage;
@property (readonly) BOOL isLoggedInUserMessage;
@property (readonly) BOOL isSystemMessage;

- (id)initWithData:(NSDictionary *)messageData;

@end
