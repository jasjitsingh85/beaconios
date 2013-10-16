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
        UIFont *font = chatMessage.isSystemMessage ? [self fontForSystemMessage] : [self fontForUserMessage];
        height = [chatMessage.messageString boundingRectWithSize:kMaxTextBubbleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size.height + 50;
    }
    return height;
}

+ (UIFont *)fontForUserMessage
{
    return [ThemeManager lightFontOfSize:14];
}

+ (UIFont *)fontForSystemMessage
{
    return [ThemeManager italicFontOfSize:14];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        UIImage *image = [[UIImage imageNamed:@"chatBubbleOrangeLeft"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        self.chatBubble = [[UIImageView alloc] initWithImage:image];
//        self.chatBubble.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.chatBubble];
        
        
        self.chatLabel = [[UILabel alloc] init];
        self.chatLabel.textColor = [UIColor blackColor];
        self.chatLabel.font = [ChatTableViewCell fontForUserMessage];
//        self.chatLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.chatLabel.numberOfLines = 0;
        [self.chatBubble addSubview:self.chatLabel];
        
        self.chatImageView = [[UIImageView alloc] init];
        self.chatImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.chatImageView.layer.cornerRadius = 8;
        self.chatImageView.clipsToBounds = YES;
        [self addSubview:self.chatImageView];
        self.chatImageView.hidden = YES;
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 0, 46, 46)];
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.avatarImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 12)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.textColor = [UIColor blackColor];
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
    
    if (chatMessage.isSystemMessage) {
        self.nameLabel.text = @"Hotbot";
    }
    else {
        self.nameLabel.text = chatMessage.sender.firstName;
    }
    
    NSURL *avatarURL = chatMessage.avatarURL;
    //screwed up API where server doesn't return correct avatar url for users
    if ([chatMessage.messageType isEqualToString:kMessageTypeUserMessage]) {
        avatarURL = chatMessage.sender.avatarURL;
    }
    if (chatMessage.avatarURL) {
        [self.avatarImageView setImageWithURL:avatarURL];
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
    self.chatLabel.font = chatMessage.isSystemMessage ? [ChatTableViewCell fontForSystemMessage] : [ChatTableViewCell fontForUserMessage];
    self.chatBubble.image = [self chatBubbleForMessage:chatMessage];
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

- (UIImage *)chatBubbleForMessage:(ChatMessage *)chatMessage
{
    static NSArray *leftBubbleImages = nil;
    static NSArray *rightBubbleImages = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *leftImages = @[[UIImage imageNamed:@"chatBubbleOrangeLeft"], [UIImage imageNamed:@"chatBubbleYellowLeft"], [UIImage imageNamed:@"chatBubbleBlueLeft"], [UIImage imageNamed:@"chatBubblePinkLeft"], [UIImage imageNamed:@"chatBubblePurpleLeft"], [UIImage imageNamed:@"chatBubbleGreenLeft"], [UIImage imageNamed:@"chatBubbleRedLeft"]];
        NSMutableArray *leftImagesResizable = [[NSMutableArray alloc] init];
        for (UIImage *image in leftImages) {
            [leftImagesResizable addObject:[image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 30, 25, 20)]];
        }
        leftBubbleImages = [NSArray arrayWithArray:leftImagesResizable];
        
        NSArray *rightImages = @[[UIImage imageNamed:@"chatBubbleOrangeRight"], [UIImage imageNamed:@"chatBubbleYellowRight"], [UIImage imageNamed:@"chatBubbleBlueRight"], [UIImage imageNamed:@"chatBubblePinkRight"], [UIImage imageNamed:@"chatBubblePurpleRight"], [UIImage imageNamed:@"chatBubbleGreenRight"], [UIImage imageNamed:@"chatBubbleRedRight"]];
        NSMutableArray *rightImagesResizable = [[NSMutableArray alloc] init];
        for (UIImage *image in rightImages) {
            [rightImagesResizable addObject:[image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 25, 25, 30)]];
        }
        rightBubbleImages = [NSArray arrayWithArray:rightImagesResizable];
    });
    NSInteger idx = chatMessage.sender.userID.integerValue;
    UIImage *bubbleImage;
    if (self.chatMessage.isSystemMessage) {
        bubbleImage = nil;
    }
    else if (self.chatMessage.isLoggedInUserMessage) {
        bubbleImage = rightBubbleImages[idx % rightBubbleImages.count];
    }
    else {
        bubbleImage = leftBubbleImages[idx % leftBubbleImages.count];
    }
    return bubbleImage;
}

- (void)layoutSubviews
{
    CGRect chatLabelFrame;
    UIFont *chatLabelFont = self.chatMessage.isSystemMessage ? [ChatTableViewCell fontForSystemMessage] : [ChatTableViewCell fontForUserMessage];
    chatLabelFrame.size = [self.chatMessage.messageString boundingRectWithSize:kMaxTextBubbleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : chatLabelFont} context:nil].size;
    chatLabelFrame.origin.y = 15;
    chatLabelFrame.origin.x = self.chatMessage.isLoggedInUserMessage ? 18 : 27;
    self.chatLabel.frame = chatLabelFrame;
    ;
    
    CGRect chatBubbleFrame;
    chatBubbleFrame.size.height = chatLabelFrame.size.height + 2*15;
    chatBubbleFrame.size.width = chatLabelFrame.size.width + 3*15;
    CGFloat bubbleBufferX = 50;
    CGFloat avatarBufferX = 7;
    CGRect avatarFrame;
    avatarFrame.size = CGSizeMake(46, 46);
    avatarFrame.origin.y = MAX(CGRectGetMaxY(chatBubbleFrame) - avatarFrame.size.height, 0);
    if (self.chatMessage.isLoggedInUserMessage) {
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
    
    if (self.chatMessage.isImageMessage) {
        CGRect chatImageFrame;
        chatImageFrame.origin.y = 15;
        chatImageFrame.size = kImageMessageSize;
        CGFloat chatImageBufferX = 75;
        if (self.chatMessage.isLoggedInUserMessage) {
            chatImageFrame.origin.x = self.frame.size.width - chatImageBufferX - chatImageFrame.size.width;
        }
        else {
            chatImageFrame.origin.x = chatImageBufferX;
        }
        self.chatImageView.frame = chatImageFrame;
        avatarFrame.origin.y = CGRectGetMidY(chatImageFrame) - 0.5*avatarFrame.size.height;
        self.avatarImageView.frame = avatarFrame;
    }
    
    self.nameLabel.center = self.avatarImageView.center;
    CGRect nameLabelFrame = self.nameLabel.frame;
    nameLabelFrame.origin.y = CGRectGetMaxY(self.avatarImageView.frame);
    self.nameLabel.frame = nameLabelFrame;
    
}

@end
