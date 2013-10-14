
//
//  BeaconChatViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/10/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconChatViewController.h"
#import "ChatMessage.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "Beacon.h"
#import "ChatTableViewCell.h"
#import "ImageViewController.h"
#import "SoundPlayer.h"
#import "User.h"

@interface BeaconChatViewController ()

@end

@implementation BeaconChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPushNotificationMessage:) name:kPushNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
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
    [self reloadMessagesFromServerCompletion:nil];
}

- (void)reloadMessagesFromServerCompletion:(void (^)())completion
{
    [[APIClient sharedClient] getMessagesForBeaconWithID:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseMessages:responseObject withCompletion:^(NSArray *messages) {
            self.messages = messages;
            [self reloadMessages];
            if (completion) {
                completion();
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)parseMessages:(NSDictionary *)messagesData withCompletion:(void (^)(NSArray *messages))completion
{
    if (![messagesData.allKeys containsObject:@"messages"]) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (NSDictionary *messageData in messagesData[@"messages"]) {
        ChatMessage *chatMessage = [[ChatMessage alloc] initWithData:messageData];
        [messages addObject:chatMessage];
    }
    if (completion) {
        completion([NSArray arrayWithArray:messages]);
    }
}

- (void)createChatMessageWithString:(NSString *)messageString
{
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    chatMessage.sender = [User loggedInUser];
    chatMessage.messageString = messageString;
    chatMessage.isUserMessage = YES;
    [self addChatMessage:chatMessage];
    [[APIClient sharedClient] postMessageWithText:chatMessage.messageString forBeaconWithID:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"fail" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)createChatMessageWithImage:(UIImage *)image
{
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    chatMessage.sender = [User loggedInUser];
    chatMessage.isUserMessage = YES;
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
