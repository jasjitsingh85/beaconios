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
    NSArray *messageTexts = @[@"hey", @"hello", @"wanna party?", @"yeah im down", @"you got blow", @"no but I know where to get some. There's this sketchy place downtown."];
    NSArray *userNames = @[@"jeff", @"jas", @"jenn"];
    NSArray *userPictures = @[@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc1/372183_100002526091955_998385602_q.jpg", @"https://graph.facebook.com/jasjitsingh85/picture", @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc1/372183_100002526091955_998385602_q.jpg"];
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:userNames.count];
    for (NSInteger i=0; i<userNames.count; i++) {
        NSString *userName = userNames[i];
        User *user = [[User alloc] init];
        user.firstName = userName;
        user.avatarURL = [NSURL URLWithString:userPictures[i]];
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

+ (NSArray *)updateFromMessages:(NSArray *)messages
{
    NSMutableArray *messagesMutable = [[NSMutableArray alloc] initWithArray:messages];
    ChatMessage *randomMessage = [messagesMutable objectAtIndex:arc4random_uniform(messages.count)];
    User *user = randomMessage.sender;
    NSString *messageString = @"blah";
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    chatMessage.sender = user;
    chatMessage.messageString = messageString;
    [messagesMutable addObject:chatMessage];
    return [[NSArray alloc] initWithArray:messagesMutable];
}



@end
