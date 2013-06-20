//
//  TextMessageSender.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "TextMessageManager.h"
#import "MapViewController.h"
#import "BeaconDetailViewController.h"

@interface TextMessageManager()

@property (weak, nonatomic) UIViewController *presentingViewController;

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

- (void)presentMessageComposeViewControllerFromViewController:(UIViewController *)viewController messageRecipients:(NSArray *)messageRecipients
{
    if (![MFMessageComposeViewController canSendText]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Device can't send texts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    MFMessageComposeViewController *messageViewController = [MFMessageComposeViewController new];
    messageViewController.recipients = messageRecipients;
    messageViewController.messageComposeDelegate = self;
    [viewController presentViewController:messageViewController animated:YES completion:nil];
}

#pragma mark - MFMessageViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if ([controller.presentingViewController isKindOfClass:[MapViewController class]]) {
        
    }
    else if ([controller.presentingViewController isKindOfClass:[BeaconDetailViewController class]]) {
        
    }
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
