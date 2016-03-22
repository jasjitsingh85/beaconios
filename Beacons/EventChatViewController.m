
//
//  BeaconChatViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/10/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "EventChatViewController.h"
#import "ChatMessage.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "Beacon.h"
#import "ChatTableViewCell.h"
#import "ImageViewController.h"
#import "SoundPlayer.h"
#import "User.h"
#import <SendBirdSDK/SendBirdSDK.h>

@interface EventChatViewController ()

@end

@implementation EventChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSendBird];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPushNotificationMessage:) name:kPushNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)initSendBird
{
    User *loggedInUser = [User loggedInUser];
    NSString *APP_ID = @"E646196E-AE50-4BA7-99C9-EADF05C2267B";
    [SendBird initAppId:APP_ID withDeviceId:[SendBird deviceUniqueID]];
    [SendBird loginWithUserId:[loggedInUser.userID stringValue] andUserName:loggedInUser.fullName andUserImageUrl:[loggedInUser.avatarURL absoluteString] andAccessToken:loggedInUser.phoneNumber];
    [SendBird joinChannel:@"1fc48.TEST"];
    
    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
        [self reloadMessagesFromServerCompletion:nil];
    } errorBlock:^(NSInteger code) {
        // Error occured due to bad APP_ID (or other unknown reason)
    } channelLeftBlock:^(SendBirdChannel *channel) {
        // Calls when the user leaves a channel.
    } messageReceivedBlock:^(SendBirdMessage *message) {
        [self reloadMessagesFromServerCompletion:nil];
    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
        // Received a system message
    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
        // When broadcast message has been received
    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
        // Received a file
    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
        // Callback for [SendBird startMessagingWithUserId:]
    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
        // Callback for [SendBird inviteMessagingWithChannelUrl:]
    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
        // Callback for [SendBird endMessagingWithChannelUrl:]
    } allMessagingEndedBlock:^ {
        // Calls when all messaging has ended at once.
    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
        // Callback for [SendBird hideMessagingWithChannelUrl:]
    } allMessagingHiddenBlock:^ {
        // Calls when all messaging channels becomes hidden at once.
    } readReceivedBlock:^(SendBirdReadStatus *status) {
        // When ReadStatus has been received
    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
        // When TypeStatus has been received
    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
        // When TypeStatus has been received
    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
        // Callback for [SendBird loadMoreMessagesWithLimit:]
    } messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *messageId) {
        NSLog(@"MESSAGE SENT");
        NSLog(@"MESSAGE: %@", message);
        NSLog(@"%d", send);
    }];
    
    [SendBird connect];
}

-(void) sendMessage:(NSString *)message
{
    [SendBird sendMessage:message];
}

- (void) loadPreviousMessages
{
    // Load last 50 messages then connect to SendBird.
    [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:LLONG_MAX andLimit:50 resultBlock:^(NSMutableArray *queryResult) {
        long long maxMessageTs = LLONG_MIN;
        for (SendBirdMessageModel *model in queryResult) {
            // Add message to an array here.
            NSLog(@"model: %@", model);
            if (maxMessageTs <= [model getMessageTimestamp]) {
                maxMessageTs = [model getMessageTimestamp];
            }
        }
        
        // Load last 50 messages then connect to SendBird.
//        [SendBird connectWithMessageTs:maxMessageId];
    } endBlock:^(NSError *error) {
        
    }];
}

//- (void) addMessage:(SendBirdMessageModel *)message
//{
//    if ([message isPast]) { // Check if the message is old one.
//        [self insertObject:message atIndex:0]; // Insert the message at the beginning of the list
//    }
//    else {
//        [self addObject:message]; // Append the mssage at the end of the list
//    }
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    [self reloadMessagesFromServerCompletion:nil];
}

- (void)receivedPushNotificationMessage:(NSNotification *)notification
{
    [self reloadMessagesFromServerCompletion:^{
        [[SoundPlayer sharedPlayer] vibrate];
    }];
}

- (void)receivedWillEnterForegroundNotification:(NSNotification *)notification
{
    if (self.beacon && self.beacon.beaconID) {
        [self reloadMessagesFromServerCompletion:nil];
    }
}

- (void)reloadMessagesFromServerCompletion:(void (^)())completion
{
//    [[APIClient sharedClient] getMessagesForBeaconWithID:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self parseMessages:responseObject withCompletion:^(NSArray *messages) {
//            self.messages = messages;
//            [self reloadMessages];
//            if (completion) {
//                completion();
//            }
//        }];
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
    
    // Load last 50 messages then connect to SendBird.
    [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:LLONG_MAX andLimit:50 resultBlock:^(NSMutableArray *queryResult) {
        long long maxMessageTs = LLONG_MIN;
        for (SendBirdMessageModel *model in queryResult) {
            // Add message to an array here.
            NSLog(@"model: %@", model);
            if (maxMessageTs <= [model getMessageTimestamp]) {
                maxMessageTs = [model getMessageTimestamp];
            }
        }
        
        [self parseMessages:queryResult withCompletion:^(NSArray *messages) {
            self.messages = messages;
            [self reloadMessages];
            if (completion) {
                completion();
            }
        }];
        
        // Load last 50 messages then connect to SendBird.
        //        [SendBird connectWithMessageTs:maxMessageId];
    } endBlock:^(NSError *error) {
        
    }];
    
}

- (void)parseMessages:(NSMutableArray *)messagesData withCompletion:(void (^)(NSArray *messages))completion
{
//    if (![messagesData.allKeys containsObject:@"messages"]) {
//        if (completion) {
//            completion(nil);
//        }
//        return;
//    }
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (SendBirdMessage *message in messagesData) {
        ChatMessage *chatMessage = [[ChatMessage alloc] initWithSendBirdData:message];
        [messages addObject:chatMessage];
    }
    
    messages = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
    
    if (completion) {
        completion([NSArray arrayWithArray:messages]);
    }
}

- (void)createChatMessageWithString:(NSString *)messageString
{
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    chatMessage.sender = [User loggedInUser];
    chatMessage.avatarURL = [User loggedInUser].avatarURL;
    chatMessage.messageString = messageString;
    [self addChatMessage:chatMessage];
    
    [self sendMessage:messageString];
}

- (void)createChatMessageWithImage:(UIImage *)image
{
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    chatMessage.sender = [User loggedInUser];
    chatMessage.avatarURL = [User loggedInUser].avatarURL;
    chatMessage.cachedImage = image;
    //right now we don't send image messages to server in the same way we send text messages
    [self addChatMessage:chatMessage];
}

- (void)addChatMessage:(ChatMessage *)chatMessage
{
    NSMutableArray *chatMessages = [[NSMutableArray alloc] initWithArray:self.messages];
    [chatMessages addObject:chatMessage];
    self.messages = [NSArray arrayWithArray:chatMessages];
    [self reloadMessages];
}

- (void)didEnterText:(NSString *)text
{
    [super didEnterText:text];
    [self createChatMessageWithString:text];
}


@end
