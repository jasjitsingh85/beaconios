
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

@interface FeedItemTableViewCell()

@property (strong, nonatomic) UIView *cellView;
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UILabel *date;
@property (strong, nonatomic) UIImageView *thumbnail;

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
    
    self.date = [[UILabel alloc] init];
    [self.cellView addSubview:self.date];
    
    self.thumbnail = [[UIImageView alloc] init];
    self.thumbnail.frame = CGRectMake(15, 15, 30, 30);
    [self.cellView addSubview:self.thumbnail];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cellView.frame = CGRectMake(10, 10, self.width - 20, self.height - 10);
    self.cellView.backgroundColor = [UIColor whiteColor];
    
}

- (void)setFeedItem:(FeedItem *)feedItem
{
    self.message.x = 60;
    self.message.centerY = (self.height)/2.0;
    self.message.width = self.width - 70;
    self.message.numberOfLines = 1;
    self.message.textAlignment = NSTextAlignmentLeft;
    self.message.height = 13;
    self.message.font = [ThemeManager lightFontOfSize:13];
    
    self.message.text = feedItem.message;
    
    self.date.x = self.width - 80;
    self.date.centerY = (self.height)/2.0;
    self.date.width = 50;
    self.date.numberOfLines = 1;
    self.date.textAlignment = NSTextAlignmentRight;
    self.date.height = 15;
    self.date.font = [ThemeManager lightFontOfSize:9];
    
    self.date.text = feedItem.dateString;
    
    
    [self.thumbnail sd_setImageWithURL:feedItem.thumbnailURL];
    self.thumbnail.layer.cornerRadius = 15;
    self.thumbnail.layer.masksToBounds = YES;
    
}

-(NSRange *)getAttributedTextRange
{
    NSRange range = [self.message rangeOfString:@"how are you doing"];
    
    NSUInteger firstCharacterPosition = range.location;
    NSUInteger lastCharacterPosition = range.location + range.length;
}

@end
