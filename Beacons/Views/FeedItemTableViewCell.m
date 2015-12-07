
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
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "APIClient.h"

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
    self.thumbnail.frame = CGRectMake(25, 12.5, 30, 30);
    [self.cellView addSubview:self.thumbnail];
    
    self.socialImageView = [[UIImageView alloc] init];
    [self.cellView addSubview:self.socialImageView];
    
    self.socialIcon = [[UIImageView alloc] init];
    [self.cellView addSubview:self.socialIcon];
    
    self.unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.unfollowButton.size = CGSizeMake(30, 30);
    [self.unfollowButton setImage:[UIImage imageNamed:@"unfollowButton"] forState:UIControlStateNormal];
    [self.unfollowButton addTarget:self action:@selector(unfollowButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.unfollowButton.hidden = YES;
    [self.cellView addSubview:self.unfollowButton];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cellView.frame = self.contentView.frame;
    self.cellView.backgroundColor = [UIColor whiteColor];
    
    self.unfollowButton.x = self.cellView.width - 45;
    self.unfollowButton.y = -3;
    
    //self.image.size = CGSizeMake(220, 220);
    
}

- (void)setFeedItem:(FeedItem *)feedItem
{
    _feedItem = feedItem;
    
    self.message.x = 65;
    self.message.y = 19;
    self.message.width = 200;
    self.message.textColor = [UIColor blackColor];
    self.message.numberOfLines = 0;
    self.message.textAlignment = NSTextAlignmentLeft;
    self.message.height = 15;
    self.message.font = [ThemeManager lightFontOfSize:11];
    
    self.messageBody.x = 65;
    self.messageBody.y = 35;
    self.messageBody.width = self.contentView.width - 85;
    self.messageBody.textColor = [UIColor blackColor];
    self.messageBody.numberOfLines = 0;
    self.messageBody.textAlignment = NSTextAlignmentLeft;
    self.messageBody.font = [ThemeManager lightFontOfSize:11];
    
    self.date.x = self.contentView.width - 75;
    self.date.width = 50;
    self.date.y = 19;
    self.date.textColor = [UIColor unnormalizedColorWithRed:68 green:68 blue:68 alpha:127];
    self.date.numberOfLines = 1;
    self.date.textAlignment = NSTextAlignmentRight;
    self.date.height = 15;
    self.date.font = [ThemeManager lightFontOfSize:9];
    
    self.date.text = feedItem.dateString;
    
    CGRect messageBodyRect = [self.feedItem.message boundingRectWithSize:CGSizeMake(self.messageBody.width, 0)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:self.messageBody.font}
                                  context:nil];
    
    self.messageBody.height = messageBodyRect.size.height;
//    self.date.y = self.messageBody.height + self.messageBody.y - 3;
    
    [self.thumbnail sd_setImageWithURL:feedItem.thumbnailURL];
    self.thumbnail.layer.cornerRadius = 15;
    self.thumbnail.layer.masksToBounds = YES;
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    [self.contentView addSubview:topBorder];
    
    if ([feedItem.source isEqualToString:@"hotspot"]) {
        
        
        NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:self.feedItem.message];
        NSRange attrStringRange = [self getAttributedTextRange:self.feedItem.message];
        [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
        [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager mediumFontOfSize:11] range:attrStringRange];
        CGRect messageRect = [self.feedItem.message boundingRectWithSize:CGSizeMake(self.message.width, 0)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:self.message.font}
                                                                 context:nil];
        self.message.height = messageRect.size.height + 5;
//        self.date.y = self.message.height + 20;
        self.message.text = feedItem.message;
        self.message.attributedText = attrMessage;
        self.unfollowButton.hidden = YES;
        [self.socialIcon setImage:nil];
        self.messageBody.text = nil;
    } else if ([feedItem.source isEqualToString:@"twitter"]) {
        
        NSString *feedTitleString = [NSString stringWithFormat:@"%@ via ", self.feedItem.name];
        NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:feedTitleString];
        NSRange attrStringRange = [self getAttributedTextRange:feedTitleString];
        [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
        [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager lightFontOfSize:11] range:attrStringRange];
        
        self.socialIcon.y = 25;
        self.socialIcon.x = self.message.x + (self.message.width/2) + ([attrMessage size].width / 2) - 23;
        self.message.x = self.message.x - 23;
        self.socialIcon.height = 10;
        self.socialIcon.width = 42;
        [self.socialIcon setImage:[UIImage imageNamed:@"twitterIcon"]];
        
        self.message.text = feedTitleString;
        self.message.attributedText = attrMessage;
        
        self.messageBody.text = self.feedItem.message;
        self.unfollowButton.hidden = NO;
    } else if ([feedItem.source isEqualToString:@"facebook"]) {
        
        NSString *feedTitleString = [NSString stringWithFormat:@"%@ via ", self.feedItem.name];
        NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:feedTitleString];
        NSRange attrStringRange = [self getAttributedTextRange:feedTitleString];
        [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
        [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager mediumFontOfSize:11] range:attrStringRange];
        
        self.socialIcon.y = 21.5;
        self.socialIcon.x = self.message.x + ([attrMessage size].width) - 3;
//        self.message.x = self.message.x - 23;
        self.socialIcon.height = 10;
        self.socialIcon.width = 42;
        [self.socialIcon setImage:[UIImage imageNamed:@"facebookIcon"]];
        
        self.message.text = feedTitleString;
        self.message.attributedText = attrMessage;
        
        self.messageBody.text = self.feedItem.message;
        
        self.unfollowButton.hidden = NO;
    }
    
    if (feedItem.image) {
        [self.socialImageView setImage:feedItem.image];
        self.socialImageView.width = feedItem.image.size.width;
        self.socialImageView.height = feedItem.image.size.height;
        self.socialImageView.y = self.messageBody.height + 50;
        self.socialImageView.x = 60;
    } else {
        [self.socialImageView setImage:nil];
    }
    
//    self.thumbnail.centerY = (self.messageBody.y + self.messageBody.height + 15) / 2;
//    self.unfollowButton.centerY = (self.messageBody.y + self.messageBody.height + 20) / 2;
    
}

-(void)unfollowButtonTouched:(id)sender
{
    NSString *title = [NSString stringWithFormat:@"Unfollow %@?", self.feedItem.name];
    NSString *body = [NSString stringWithFormat:@"Would you like to unfollow %@?", self.feedItem.name];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:body];
    [alertView bk_addButtonWithTitle:@"Unfollow" handler:^{
        [[APIClient sharedClient] toggleFavorite:self.feedItem.dealPlaceID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unfollow Failed");
        }];
        NSLog(@"DEAL PLACE ID: %@", self.feedItem.dealPlaceID);
    }];
    [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        
    }];
    [alertView show];
}

-(NSRange)getAttributedTextRange: (NSString *)fullString
{
    NSRange range = [fullString rangeOfString:self.feedItem.name];
    return range;
}




@end
