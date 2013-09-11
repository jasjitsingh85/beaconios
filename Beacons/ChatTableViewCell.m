//
//  ChatTableViewCell.m
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ChatMessage.h"
#import "User.h"
#import "Theme.h"

#define kMaxTextBubbleSize CGSizeMake(200, 200)

@interface ChatTableViewCell()

@property (strong, nonatomic) UILabel *chatLabel;
@property (strong, nonatomic) UIImageView *chatBubble;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nameLabel;

@end

@implementation ChatTableViewCell

+ (CGFloat)heightForChatMessage:(ChatMessage *)chatMessage
{
    CGFloat textHeight = [chatMessage.messageString sizeWithFont:[ThemeManager regularFontOfSize:12.0] constrainedToSize:kMaxTextBubbleSize].height + 50;
    return textHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        UIImage *image = [[UIImage imageNamed:@"bubbleLeft"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 26, 25, 15)];
        self.chatBubble = [[UIImageView alloc] initWithImage:image];
//        self.chatBubble.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.chatBubble];
        
        self.chatLabel = [[UILabel alloc] init];
        self.chatLabel.textColor = [UIColor blackColor];
        self.chatLabel.font = [ThemeManager regularFontOfSize:12];
//        self.chatLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.chatLabel.numberOfLines = 0;
        [self.chatBubble addSubview:self.chatLabel];
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 0, 46, 46)];
        self.avatarImageView.layer.borderWidth = 2;
        self.avatarImageView.layer.borderColor = [UIColor greenColor].CGColor;
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0;
        self.avatarImageView.clipsToBounds = YES;
        [self addSubview:self.avatarImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 12)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [ThemeManager regularFontOfSize:10];
        [self addSubview:self.nameLabel];
        
    }
    return self;
}

- (void)setChatMessage:(ChatMessage *)chatMessage
{
    _chatMessage = chatMessage;
    self.chatLabel.text = chatMessage.messageString;
    self.nameLabel.text = chatMessage.sender.firstName;
    if (chatMessage.isUserMessage) {
        UIImage *image = [[UIImage imageNamed:@"bubbleRight"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 25, 26)];
        self.chatBubble.image = image;
    }
    else {
        UIImage *image = [[UIImage imageNamed:@"bubbleLeft"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 26, 25, 15)];
        self.chatBubble.image = image;
    }
    if (chatMessage.sender.avatarURL) {
        [self.avatarImageView setImageWithURL:chatMessage.sender.avatarURL];
    }
    else {
        self.avatarImageView.image = nil;
    }
}

- (void)layoutSubviews
{
    CGRect chatLabelFrame;
    chatLabelFrame.size  = [self.chatMessage.messageString sizeWithFont:[ThemeManager regularFontOfSize:12.0] constrainedToSize:kMaxTextBubbleSize];
    chatLabelFrame.origin = CGPointMake(30, 15);
    self.chatLabel.frame = chatLabelFrame;
    ;
    
    CGRect chatBubbleFrame;
    chatBubbleFrame.size.height = chatLabelFrame.size.height + 2*15;
    chatBubbleFrame.size.width = chatLabelFrame.size.width + 3*15;
    CGFloat bubbleBufferX = 50;
    CGFloat avatarBufferX = 7;
    CGRect avatarFrame = self.avatarImageView.frame;
    if (self.chatMessage.isUserMessage) {
        chatBubbleFrame.origin.x = self.frame.size.width - bubbleBufferX - chatBubbleFrame.size.width;
        avatarFrame.origin.x = self.frame.size.width - avatarBufferX - self.avatarImageView.frame.size.width;
    }
    else {
        chatBubbleFrame.origin.x = bubbleBufferX;
        avatarFrame.origin.x = avatarBufferX;
    }
    chatBubbleFrame.origin.y = 0.5*(self.frame.size.height - chatBubbleFrame.size.height);
    self.chatBubble.frame = chatBubbleFrame;
    self.avatarImageView.frame = avatarFrame;
    
    self.nameLabel.center = self.avatarImageView.center;
    CGRect nameLabelFrame = self.nameLabel.frame;
    nameLabelFrame.origin.y = CGRectGetMaxY(self.avatarImageView.frame);
    self.nameLabel.frame = nameLabelFrame;
}

@end
