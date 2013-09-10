//
//  ChatTableViewCell.h
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatMessage;
@interface ChatTableViewCell : UITableViewCell

+ (CGFloat)heightForChatMessage:(ChatMessage *)chatMessage;

@property (strong, nonatomic) ChatMessage *chatMessage;

@end
