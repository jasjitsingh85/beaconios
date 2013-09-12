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

@implementation ChatMessage

- (id)initWithData:(NSDictionary *)messageData
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.sender = [[User alloc] initWithData:messageData[@"sender"]];
    self.messageString = messageData[@"message"];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.isUserMessage = [self.sender.userID isEqualToNumber:appDelegate.loggedInUser.userID];
    return self;
}

@end
