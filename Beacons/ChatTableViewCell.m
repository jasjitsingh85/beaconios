//
//  ChatTableViewCell.m
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "ChatMessage.h"
#import "Theme.h"

#define kMaxTextBubbleSize CGSizeMake(100, 200)

@interface ChatTableViewCell()

@property (strong, nonatomic) UILabel *chatLabel;

@end

@implementation ChatTableViewCell

+ (CGFloat)heightForChatMessage:(ChatMessage *)chatMessage
{
    CGFloat textHeight = [chatMessage.messageString sizeWithFont:[ThemeManager regularFontOfSize:12.0] constrainedToSize:kMaxTextBubbleSize].height;
    return textHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.chatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kMaxTextBubbleSize.width, kMaxTextBubbleSize.height)];
        self.chatLabel.textColor = [UIColor blackColor];
        self.chatLabel.font = [ThemeManager regularFontOfSize:12];
//        self.chatLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.chatLabel.numberOfLines = 0;
        [self addSubview:self.chatLabel];
    }
    return self;
}

- (void)setChatMessage:(ChatMessage *)chatMessage
{
    _chatMessage = chatMessage;
    self.chatLabel.text = chatMessage.messageString;
}

- (void)layoutSubviews
{
    CGRect chatLabelFrame = self.chatLabel.frame;
    chatLabelFrame.size.height = [ChatTableViewCell heightForChatMessage:self.chatMessage];
    self.chatLabel.frame = chatLabelFrame;
}

@end
