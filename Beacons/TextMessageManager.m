//
//  TextMessageSender.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "TextMessageManager.h"
#import "AnalyticsManager.h"
#import "LoadingIndictor.h"
#import "APIClient.h"

@interface TextMessageManager()

@property (weak, nonatomic) UIViewController *presentingViewController;
@property (strong, nonatomic) NSArray *recipients;
@property (strong, nonatomic) MFMessageComposeViewController *messageViewController;

@end

@implementation TextMessageManager

+ (TextMessageManager *)sharedManager
{
    static TextMessageManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TextMessageManager alloc] init];
        
    });
    return _sharedManager;
}

- (void)presentMessageComposeViewControllerFromViewController:(UIViewController *)viewController messageRecipients:(NSArray *)messageRecipients withMessage:(NSString *)smsMessage success:(void (^)(BOOL success))success failure:(void (^)(NSError *error))failure;
{
    if (![MFMessageComposeViewController canSendText]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Device can't send texts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    self.presentingViewController = viewController;
    self.messageViewController = [MFMessageComposeViewController new];
    self.messageViewController.recipients = messageRecipients;
    self.messageViewController.body = smsMessage;
    self.recipients = messageRecipients;
    self.messageViewController.messageComposeDelegate = self;
    [viewController presentViewController:self.messageViewController animated:YES completion:^{
        success(YES);
    }];
}

#pragma mark - MFMessageViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"MESSAGE RECIPIENTS: %@", self.messageViewController.recipients);
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [[APIClient sharedClient] postReferredPhoneNumbers:self.messageViewController.recipients success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Recipients Uploaded");
    } failure:nil];
}


@end
