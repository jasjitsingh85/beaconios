
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
#import "PhotoManager.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "LoadingIndictor.h"
#import "SponsoredEvent.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface EventChatViewController () <UIImagePickerControllerDelegate>

@end

@implementation EventChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPushNotificationMessage:) name:kPushNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)setSponsoredEvent:(SponsoredEvent *)sponsoredEvent
{
    _sponsoredEvent = sponsoredEvent;
    
    [self initSendBird];
}

-(void)initSendBird
{
    User *loggedInUser = [User loggedInUser];
    NSString *APP_ID = @"E646196E-AE50-4BA7-99C9-EADF05C2267B";
    [SendBird initAppId:APP_ID withDeviceId:[SendBird deviceUniqueID]];
    [SendBird loginWithUserId:[loggedInUser.userID stringValue] andUserName:loggedInUser.fullName andUserImageUrl:[loggedInUser.avatarURL absoluteString] andAccessToken:loggedInUser.phoneNumber];
    [SendBird joinChannel:self.sponsoredEvent.chatChannelUrl];
//    [SendBird joinChannel:@"1fc48.24"];
    
    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
        [self reloadMessagesFromServerCompletion:nil];
    } errorBlock:^(NSInteger code) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingInRedemptionView" object:self userInfo:nil];
    } channelLeftBlock:^(SendBirdChannel *channel) {
        // Calls when the user leaves a channel.
    } messageReceivedBlock:^(SendBirdMessage *message) {
        [self reloadMessagesFromServerCompletion:^ {
//            [[SoundPlayer sharedPlayer] vibrate];
        }];
    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
        // Received a system message
    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
        // When broadcast message has been received
    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
        [self reloadMessagesFromServerCompletion:^ {
//            [[SoundPlayer sharedPlayer] vibrate];
        }];
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
    [self sendMessageToServer:message];
}

- (void) loadPreviousMessages
{
    // Load last 50 messages then connect to SendBird.
    [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:LLONG_MAX andLimit:50 resultBlock:^(NSMutableArray *queryResult) {
        long long maxMessageTs = LLONG_MIN;
        for (SendBirdMessageModel *model in queryResult) {
            if (maxMessageTs <= [model getMessageTimestamp]) {
                maxMessageTs = [model getMessageTimestamp];
            }
        }
        
        // Load last 50 messages then connect to SendBird.
//        [SendBird connectWithMessageTs:maxMessageId];
    } endBlock:^(NSError *error) {
        
    }];
}


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
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLoadingForEvent object:self userInfo:nil];
    [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:LLONG_MAX andLimit:50 resultBlock:^(NSMutableArray *queryResult) {
        long long maxMessageTs = LLONG_MIN;
        for (SendBirdMessageModel *model in queryResult) {
            // Add message to an array here.
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kEndLoadingForEvent object:self userInfo:nil];
        // Load last 50 messages then connect to SendBird.
        //        [SendBird connectWithMessageTs:maxMessageId];
    } endBlock:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEndLoadingForEvent object:self userInfo:nil];
    }];
    
}

- (void)parseMessages:(NSMutableArray *)messagesData withCompletion:(void (^)(NSArray *messages))completion
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (SendBirdMessageModel *messageModel in messagesData) {
        SEL messageSelector = NSSelectorFromString(@"message");
        SEL fileSelector = NSSelectorFromString(@"fileInfo");
        if ([messageModel respondsToSelector:messageSelector]) {
            SendBirdMessage *message = (SendBirdMessage *)messageModel;
            ChatMessage *chatMessage = [[ChatMessage alloc] initMessageWithSendBirdData:message];
            [messages addObject:chatMessage];
        } else if ([messageModel respondsToSelector:fileSelector]) {
            SendBirdFileLink *file = (SendBirdFileLink *)messageModel;
            ChatMessage *chatMessage = [[ChatMessage alloc] initFileWithSendBirdData:file];
            [messages addObject:chatMessage];
        }
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

- (void)cameraButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Do you want to take a photo or add one from your library?"];
    [actionSheet bk_addButtonWithTitle:@"Take a Photo" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet bk_addButtonWithTitle:@"Add From Library" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)source
{
    [[PhotoManager sharedManager] presentImagePickerForSourceType:source fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        if (image) {
            NSData *imageFileData = UIImageJPEGRepresentation(image, .4);
            [SendBird uploadFile:imageFileData type:@"image/jpg" hasSizeOfFile:[imageFileData length] withCustomField:@"" uploadBlock:^(SendBirdFileInfo *fileInfo, NSError *error) {
                [SendBird sendFile:fileInfo];
                [self sendFileToServer:fileInfo.url];
            }];
            
        }
    }];
}

-(void)sendFileToServer:(NSString *)imageUrlString
{
        [[APIClient sharedClient] postImageMessage:imageUrlString forEventWithID:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Image Link Sent");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image Send Failed");
        }];
}

-(void)sendMessageToServer:(NSString *)message
{
    [[APIClient sharedClient] postStringMessage:message forEventWithID:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Message Sent");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Message Send Failed");
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        // other codes
    }];
}


@end
