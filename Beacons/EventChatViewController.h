//
//  BeaconChatViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/10/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatViewController.h"

@class Beacon, SponsoredEvent;
@interface EventChatViewController : ChatViewController

@property (strong, nonatomic) Beacon *beacon;
@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;

- (void)createChatMessageWithString:(NSString *)messageString;
- (void)createChatMessageWithImage:(UIImage *)image;
- (void)reloadMessagesFromServerCompletion:(void (^)())completion;

@end
