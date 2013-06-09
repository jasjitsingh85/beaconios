//
//  TextMessageSender.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface TextMessageManager : NSObject <MFMessageComposeViewControllerDelegate>

+ (TextMessageManager *)sharedManager;

- (void)presentMessageComposeViewControllerFromViewController:(UIViewController *)viewController messageRecipients:(NSArray *)messageRecipients;

@end
