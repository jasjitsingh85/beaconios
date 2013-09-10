//
//  ChatTest.m
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatTest.h"
#import "User.h"
#import "ChatMessage.h"

@implementation ChatTest

+ (NSArray *)testMessages
{
    NSArray *messageTexts = @[@"hey", @"hello", @"wanna party?", @"yeah im down", @"you got blow", @"no but I know where to get some"];
    NSArray *userNames = @[@"jeff", @"jas", @"jenn"];
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:userNames.count];
    for (NSString *userName in userNames) {
        User *user = [[User alloc] init];
        user.firstName = userName;
        [users addObject:user];
    }
    
    NSMutableArray *chatMessages = [[NSMutableArray alloc] initWithCapacity:messageTexts.count];
    for (NSInteger i=0; i<messageTexts.count; i++) {
        NSString *messageText = messageTexts[i];
        User *user = [users objectAtIndex:i%users.count];
        ChatMessage *chatMessage = [[ChatMessage alloc] init];
        chatMessage.sender = user;
        chatMessage.sentDate = [NSDate dateWithTimeInterval:i sinceDate:[NSDate date]];
        chatMessage.messageString = messageText;
        [chatMessages addObject:chatMessage];
    }
    return chatMessages;
}

@end
