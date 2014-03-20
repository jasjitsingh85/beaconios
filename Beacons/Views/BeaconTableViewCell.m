//
//  BeaconTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 2/25/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "BeaconTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Shadow.h"
#import "NSDate+FormattedDate.h"
#import "Theme.h"
#import "Beacon.h"
#import "BeaconStatus.h"
#import "BeaconImage.h"
#import "User.h"

@implementation BeaconTableViewCell

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
    self.thumbnailImageView.clipsToBounds = YES;
    [self.thumbnailContainerView addSubview:self.thumbnailImageView];
    
    CGRect beaconTitleFrame = CGRectZero;
    beaconTitleFrame.size = CGSizeMake(184, 21);
    beaconTitleFrame.origin.x = CGRectGetMaxX(self.thumbnailContainerView.frame) + 13;
    beaconTitleFrame.origin.y = CGRectGetMinY(self.thumbnailContainerView.frame);
    self.beaconTitleLabel = [[UILabel alloc] initWithFrame:beaconTitleFrame];
    self.beaconTitleLabel.text = @"Jeff: Partying @ rooftop";
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
    self.inviteLabel.text = @"1 here, 0 invited";
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

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    if (!beacon.images || !beacon.images.count) {
        [self.thumbnailImageView setImageWithURL:beacon.creator.avatarURL];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        CGRect thumbnailFrame = CGRectZero;
        thumbnailFrame.size = CGSizeMake(39, 39);
        thumbnailFrame.origin.x = 0.5*(self.thumbnailContainerView.frame.size.width - thumbnailFrame.size.width);
        thumbnailFrame.origin.y = 0.5*(self.thumbnailContainerView.frame.size.height - thumbnailFrame.size.height);
        self.thumbnailImageView.frame = thumbnailFrame;
        self.thumbnailImageView.layer.cornerRadius = 0;
    }
    else {
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        BeaconImage *beaconImage = [beacon.images lastObject];
        [self.thumbnailImageView setImageWithURL:beaconImage.imageURL];
        self.thumbnailImageView.frame = self.thumbnailContainerView.bounds;
        self.thumbnailImageView.layer.cornerRadius = self.thumbnailContainerView.layer.cornerRadius;
    }
    NSString *titleText = [NSString stringWithFormat:@"%@: %@", beacon.creator.firstName, beacon.beaconDescription];
    if (beacon.address && beacon.address.length) {
        titleText = [titleText stringByAppendingString:[NSString stringWithFormat:@" @ %@", beacon.address]];
    }
    self.beaconTitleLabel.text = titleText;
    self.timeLabel.text = [beacon.time formattedDate].lowercaseString;
    [self updateInvitedLabel];
}

- (void)updateInvitedLabel
{
    
    NSInteger invited = 0;
    NSInteger here = 0;
    for (BeaconStatus *beaconStatus in self.beacon.guestStatuses.allValues) {
        invited += (beaconStatus.beaconStatusOption == BeaconStatusOptionInvited) || (beaconStatus.beaconStatusOption == BeaconStatusOptionHere) || (beaconStatus.beaconStatusOption == BeaconStatusOptionGoing);
        here += beaconStatus.beaconStatusOption == BeaconStatusOptionHere;
    }
    self.inviteLabel.text = [NSString stringWithFormat:@"%d here, %d invited",here, invited];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *backgroundColor = self.thumbnailContainerView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.thumbnailContainerView.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *backgroundColor = self.thumbnailContainerView.backgroundColor;
    [super setSelected:selected animated:animated];
    self.thumbnailContainerView.backgroundColor = backgroundColor;
}

@end
