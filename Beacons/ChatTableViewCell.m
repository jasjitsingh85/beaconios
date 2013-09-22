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
#define kImageMessageSize CGSizeMake(100, 130)

@interface ChatTableViewCell()

@property (strong, nonatomic) UILabel *chatLabel;
@property (strong, nonatomic) UIImageView *chatBubble;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *chatImageView;

@end

@implementation ChatTableViewCell

+ (CGFloat)heightForChatMessage:(ChatMessage *)chatMessage
{
    CGFloat height;
    if (chatMessage.isImageMessage) {
        height = kImageMessageSize.height + 50;
    }
    else {
        height = [chatMessage.messageString sizeWithFont:[ThemeManager regularFontOfSize:12.0] constrainedToSize:kMaxTextBubbleSize].height + 50;
    }
    return height;
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
        
        self.chatImageView = [[UIImageView alloc] init];
        self.chatImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.chatImageView.layer.cornerRadius = 2;
        self.chatImageView.clipsToBounds = YES;
        [self addSubview:self.chatImageView];
        self.chatImageView.hidden = YES;
        
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
    if (chatMessage.isImageMessage) {
        [self configureForImageMessage:chatMessage];
    }
    else {
        [self configureForTextMessage:chatMessage];
    }
    self.nameLabel.text = chatMessage.sender.firstName;
    if (chatMessage.sender.avatarURL) {
        [self.avatarImageView setImageWithURL:chatMessage.sender.avatarURL];
    }
    else {
        self.avatarImageView.image = nil;
    }
}

- (void)configureForTextMessage:(ChatMessage *)chatMessage
{
    self.chatImageView.hidden = YES;
    self.chatBubble.hidden = NO;
    self.chatLabel.text = chatMessage.messageString;
    if (chatMessage.isUserMessage) {
        UIImage *image = [[UIImage imageNamed:@"bubbleRight"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 25, 26)];
        self.chatBubble.image = image;
    }
    else {
        UIImage *image = [[UIImage imageNamed:@"bubbleLeft"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 26, 25, 15)];
        self.chatBubble.image = image;
    }
}

- (void)configureForImageMessage:(ChatMessage *)chatMessage
{
    self.chatImageView.hidden = NO;
    self.chatBubble.hidden = YES;
    if (chatMessage.cachedImage) {
        self.chatImageView.image = chatMessage.cachedImage;
    }
    else if (chatMessage.imageURL) {
        [self.chatImageView setImageWithURL:chatMessage.imageURL];
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
    CGRect avatarFrame = CGRectMake(7, 0, 46, 46);
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
    
    if (self.chatMessage.isImageMessage) {
        CGRect chatImageFrame;
        chatImageFrame.origin.y = 15;
        chatImageFrame.size = kImageMessageSize;
        CGFloat chatImageBufferX = 75;
        if (self.chatMessage.isUserMessage) {
            chatImageFrame.origin.x = self.frame.size.width - chatImageBufferX - chatImageFrame.size.width;
        }
        else {
            chatImageFrame.origin.x = chatImageBufferX;
        }
        self.chatImageView.frame = chatImageFrame;
        avatarFrame.origin.y = CGRectGetMidY(chatImageFrame) - 0.5*avatarFrame.size.height;
        self.avatarImageView.frame = avatarFrame;
    }
    
}

@end
