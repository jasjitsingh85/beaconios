
//
//  RewardTableViewCell.m
//  Beacons
//
//  Created by Jasjit Singh on 5/12/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "FeedItemTableViewCell.h"
#import "Venue.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@interface FeedItemTableViewCell() <SDWebImageManagerDelegate>

@property (strong, nonatomic) UIView *cellView;
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UILabel *messageBody;
@property (strong, nonatomic) UILabel *date;
@property (strong, nonatomic) UIImageView *thumbnail;
@property (strong, nonatomic) UIImageView *socialIcon;
@property (strong, nonatomic) UIImageView *socialImageView;
@property (strong, nonatomic) UIButton *unfollowButton;

@end

@implementation FeedItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.cellView = [[UIView alloc] init];
    [self.contentView addSubview:self.cellView];
    
    self.message = [[UILabel alloc] init];
    [self.cellView addSubview:self.message];
    
    self.messageBody = [[UILabel alloc] init];
    [self.cellView addSubview:self.messageBody];
    
    self.date = [[UILabel alloc] init];
    [self.cellView addSubview:self.date];
    
    self.thumbnail = [[UIImageView alloc] init];
    self.thumbnail.frame = CGRectMake(15, 15, 30, 30);
    [self.cellView addSubview:self.thumbnail];
    
    self.socialImageView = [[UIImageView alloc] init];
    [self.cellView addSubview:self.socialImageView];
    
    self.socialIcon = [[UIImageView alloc] init];
    [self.cellView addSubview:self.socialIcon];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cellView.frame = CGRectMake(10, 10, self.width - 20, self.height - 10);
    self.cellView.backgroundColor = [UIColor whiteColor];
    
    self.unfollowButton.x = self.cellView.width - 25;
    self.unfollowButton.y = 0;
    
    //self.image.size = CGSizeMake(220, 220);
    
}

- (void)setFeedItem:(FeedItem *)feedItem
{
    _feedItem = feedItem;
    
    self.message.x = 60;
    self.message.y = 22;
    self.message.width = 190;
    self.message.numberOfLines = 0;
    self.message.textAlignment = NSTextAlignmentLeft;
    self.message.height = 15;
    self.message.font = [ThemeManager lightFontOfSize:12];
    
    self.messageBody.x = 60;
    self.messageBody.y = 35;
    self.messageBody.width = 220;
    self.messageBody.numberOfLines = 0;
    self.messageBody.textAlignment = NSTextAlignmentLeft;
    self.messageBody.font = [ThemeManager lightFontOfSize:12];
    
    self.date.x = self.width - 80;
    self.date.y = (self.height)/2.0;
    self.date.width = 50;
    self.date.y = 24;
    self.date.numberOfLines = 1;
    self.date.textAlignment = NSTextAlignmentRight;
    self.date.height = 15;
    self.date.font = [ThemeManager lightFontOfSize:9];
    
    self.date.text = feedItem.dateString;
    
    CGRect messageBodyRect = [self.feedItem.message boundingRectWithSize:CGSizeMake(self.messageBody.width, 0)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:self.messageBody.font}
                                  context:nil];
    
    self.messageBody.height = messageBodyRect.size.height + 10;
    
    [self.thumbnail sd_setImageWithURL:feedItem.thumbnailURL];
    self.thumbnail.layer.cornerRadius = 15;
    self.thumbnail.layer.masksToBounds = YES;
    
    if ([feedItem.source isEqualToString:@"hotspot"]) {
        
        NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:self.feedItem.message];
        NSRange attrStringRange = [self getAttributedTextRange:self.feedItem.message];
        [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
        [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:attrStringRange];
        
        self.message.text = feedItem.message;
        self.message.attributedText = attrMessage;
    } else if ([feedItem.source isEqualToString:@"twitter"]) {
        
        NSString *feedTitleString = [NSString stringWithFormat:@"%@ via ", self.feedItem.name];
        NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:feedTitleString];
        NSRange attrStringRange = [self getAttributedTextRange:feedTitleString];
        [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
        [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:attrStringRange];
        
        self.socialIcon.y = 24;
        self.socialIcon.x = self.message.x + [attrMessage size].width - 1;
        self.socialIcon.height = 12;
        self.socialIcon.width = 50;
        [self.socialIcon setImage:[UIImage imageNamed:@"twitterIcon"]];
        
        self.message.text = feedTitleString;
        self.message.attributedText = attrMessage;
        
        self.messageBody.text = self.feedItem.message;

        self.unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.unfollowButton.size = CGSizeMake(25, 25);
        [self.unfollowButton setImage:[UIImage imageNamed:@"crossOutButton"] forState:UIControlStateNormal];
        [self.cellView addSubview:self.unfollowButton];
        
    } else if ([feedItem.source isEqualToString:@"facebook"]) {
        
        NSString *feedTitleString = [NSString stringWithFormat:@"%@ via ", self.feedItem.name];
        NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:feedTitleString];
        NSRange attrStringRange = [self getAttributedTextRange:feedTitleString];
        [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
        [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:attrStringRange];
        
        self.socialIcon.y = 24;
        self.socialIcon.x = self.message.x + [attrMessage size].width - 1;
        self.socialIcon.height = 12;
        self.socialIcon.width = 50;
        [self.socialIcon setImage:[UIImage imageNamed:@"facebookIcon"]];
        
        self.message.text = feedTitleString;
        self.message.attributedText = attrMessage;
        
        self.messageBody.text = self.feedItem.message;
        
        self.unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.unfollowButton.size = CGSizeMake(25, 25);
        [self.unfollowButton setImage:[UIImage imageNamed:@"crossOutButton"] forState:UIControlStateNormal];
        [self.cellView addSubview:self.unfollowButton];
    }
    
    if (feedItem.image) {

        [self.socialImageView setImage:feedItem.image];
        self.socialImageView.width = feedItem.image.size.width;
        self.socialImageView.height = feedItem.image.size.height;
        self.socialImageView.y = self.messageBody.height + 40;
        self.socialImageView.centerX = (self.width - 20)/2.0;
    }
    
}

-(NSRange)getAttributedTextRange: (NSString *)fullString
{
    NSRange range = [fullString rangeOfString:self.feedItem.name];
    
    return range;
//    NSUInteger firstCharacterPosition = range.location;
//    NSUInteger lastCharacterPosition = range.location + range.length;
}




@end
