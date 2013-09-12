//
//  ChatMessage.h
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface ChatMessage : NSObject

@property (strong, nonatomic) NSString *messageString;
@property (strong, nonatomic) NSDate *sentDate;
@property (strong, nonatomic) User *sender;
@property (assign, nonatomic) BOOL isUserMessage;

- (id)initWithData:(NSDictionary *)messageData;

@end
