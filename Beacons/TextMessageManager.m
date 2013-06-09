//
//  TextMessageSender.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "TextMessageManager.h"

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

- (void)presentMessageComposeViewControllerFromViewController:(UIViewController *)viewController messageRecipients:(NSArray *)messageRecipients
{
    MFMessageComposeViewController *messageViewController = [MFMessageComposeViewController new];
    messageViewController.recipients = messageRecipients;
    messageViewController.messageComposeDelegate = self;
    [viewController presentViewController:messageViewController animated:YES completion:nil];
}

#pragma mark - MFMessageViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
