//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Shadow.h"
#import "Venue.h"

@interface DealTableViewCell()

@end

@implementation DealTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.thumbnailContainerView = [[UIView alloc] init];
    CGRect thumbnailFrame = CGRectZero;
    thumbnailFrame.size = CGSizeMake(64, 64);
    thumbnailFrame.origin.x = 16;
    thumbnailFrame.origin.y = 0.5*(self.contentView.frame.size.height - thumbnailFrame.size.height);
    self.thumbnailContainerView.frame = thumbnailFrame;
    self.thumbnailContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.thumbnailContainerView.layer.cornerRadius = 10;
    self.thumbnailContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailContainerView.layer.borderWidth = 1.5;
    self.thumbnailContainerView.backgroundColor = [UIColor darkGrayColor];
    [self.thumbnailContainerView setShadowWithColor:[UIColor blackColor] opacity:1 radius:2 offset:CGSizeMake(0, 2) shouldDrawPath:YES];
    [self.contentView addSubview:self.thumbnailContainerView];
    
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:self.thumbnailContainerView.bounds];
    self.thumbnailImageView.layer.cornerRadius = self.thumbnailContainerView.layer.cornerRadius;
    self.thumbnailImageView.clipsToBounds = YES;
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.thumbnailContainerView addSubview:self.thumbnailImageView];
    
    CGRect beaconTitleFrame = CGRectZero;
    beaconTitleFrame.size = CGSizeMake(184, 21);
    beaconTitleFrame.origin.x = CGRectGetMaxX(self.thumbnailContainerView.frame) + 13;
    beaconTitleFrame.origin.y = CGRectGetMinY(self.thumbnailContainerView.frame);
    self.beaconTitleLabel = [[UILabel alloc] initWithFrame:beaconTitleFrame];
    self.beaconTitleLabel.font = [ThemeManager boldFontOfSize:1.3*10];
    self.beaconTitleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.beaconTitleLabel];
    
    CGRect timeFrame = CGRectZero;
    timeFrame.size = beaconTitleFrame.size;
    timeFrame.origin.x = beaconTitleFrame.origin.x;
    timeFrame.origin.y = CGRectGetMaxY(beaconTitleFrame);
    self.timeLabel = [[UILabel alloc] initWithFrame:timeFrame];
    self.timeLabel.textColor = [UIColor colorWithWhite:203/255.0 alpha:1.0];
    self.timeLabel.font = [ThemeManager regularFontOfSize:1.3*8.5];
    [self.contentView addSubview:self.timeLabel];
    
    CGRect invitedFrame = CGRectZero;
    invitedFrame.size = beaconTitleFrame.size;
    invitedFrame.origin.x = beaconTitleFrame.origin.x;
    invitedFrame.origin.y = CGRectGetMaxY(timeFrame);
    self.inviteLabel = [[UILabel alloc] initWithFrame:invitedFrame];
    self.inviteLabel.textColor = self.timeLabel.textColor;
    self.inviteLabel.font = self.timeLabel.font;
    [self.contentView addSubview:self.inviteLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleLabelFrame = self.beaconTitleLabel.frame;
    titleLabelFrame.origin.y = CGRectGetMinY(self.thumbnailContainerView.frame);
    self.beaconTitleLabel.frame = titleLabelFrame;
    
    CGRect timeLabelFrame = self.timeLabel.frame;
    timeLabelFrame.origin.y = CGRectGetMaxY(titleLabelFrame);
    self.timeLabel.frame = timeLabelFrame;
    
    CGRect inviteLabelFrame = self.inviteLabel.frame;
    inviteLabelFrame.origin.y = CGRectGetMaxY(timeLabelFrame);
    self.inviteLabel.frame = inviteLabelFrame;
}

- (void)setDeal:(Deal *)deal
{
    _deal = deal;
    
    self.beaconTitleLabel.text = deal.venue.name;
    self.timeLabel.text = deal.dealDescriptionShort;
    self.inviteLabel.text = [NSString stringWithFormat:@"Invite %@ friends", self.deal.inviteRequirement];
    [self.thumbnailImageView setImageWithURL:self.deal.venue.imageURL];
    self.thumbnailImageView.clipsToBounds = YES;
}

@end
