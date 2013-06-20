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
#import "AnalyticsManager.h"

@interface TextMessageManager()

@property (weak, nonatomic) UIViewController *presentingViewController;
@property (strong, nonatomic) NSArray *recipients;

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
    self.presentingViewController = viewController;
    MFMessageComposeViewController *messageViewController = [MFMessageComposeViewController new];
    messageViewController.recipients = messageRecipients;
    self.recipients = messageRecipients;
    messageViewController.messageComposeDelegate = self;
    [viewController presentViewController:messageViewController animated:YES completion:nil];
}

#pragma mark - MFMessageViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if ([self.presentingViewController isKindOfClass:[MapViewController class]]) {
        [[AnalyticsManager sharedManager] sentText:AnalyticsLocationMapView recipients:self.recipients];
    }
    else if ([self.presentingViewController isKindOfClass:[BeaconDetailViewController class]]) {
        [[AnalyticsManager sharedManager] sentText:AnalyticsLocationBeaconDetail recipients:self.recipients];
    }
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
