//
//  BeaconChatViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/10/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatViewController.h"

@class Beacon;
@interface EventChatViewController : ChatViewController

@property (strong, nonatomic) Beacon *beacon;

- (void)createChatMessageWithString:(NSString *)messageString;
- (void)createChatMessageWithImage:(UIImage *)image;
- (void)reloadMessagesFromServerCompletion:(void (^)())completion;

@end
