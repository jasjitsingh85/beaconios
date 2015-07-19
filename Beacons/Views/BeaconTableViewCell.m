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
#import "Deal.h"
#import "Venue.h"

@implementation BeaconTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.thumbnailContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
//    CGRect thumbnailFrame = CGRectZero;
//    thumbnailFrame.size = CGSizeMake(64, 64);
//    thumbnailFrame.origin.x = 16;
//    thumbnailFrame.origin.y = 0.5*(self.contentView.frame.size.height - thumbnailFrame.size.height);
//    self.thumbnailContainerView.frame = thumbnailFrame;
//    self.thumbnailContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//    self.thumbnailContainerView.layer.cornerRadius = 10;
//    self.thumbnailContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.thumbnailContainerView.layer.borderWidth = 1.5;
//    self.thumbnailContainerView.backgroundColor = [UIColor darkGrayColor];
//    [self.thumbnailContainerView setShadowWithColor:[UIColor blackColor] opacity:1 radius:2 offset:CGSizeMake(0, 2) shouldDrawPath:YES];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.size.width, 50)];
    backgroundView.backgroundColor = [UIColor unnormalizedColorWithRed:33 green:26 blue:42 alpha:255];
    [self.contentView addSubview:backgroundView];
    [self.contentView addSubview:self.thumbnailContainerView];
    
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:self.thumbnailContainerView.bounds];
    self.thumbnailImageView.clipsToBounds = YES;
    [self.thumbnailContainerView addSubview:self.thumbnailImageView];
    
//    CGRect beaconTitleFrame = CGRectZero;
//    beaconTitleFrame.size = CGSizeMake(184, 21);
//    beaconTitleFrame.origin.x = CGRectGetMaxX(self.thumbnailContainerView.frame) + 13;
//    beaconTitleFrame.origin.y = CGRectGetMinY(self.thumbnailContainerView.frame);
    self.firstLine = [[UILabel alloc] initWithFrame:CGRectMake(73, 6, 194, 21)];
    self.firstLine.text = @"Jeff: Partying @ rooftop";
    self.firstLine.font = [ThemeManager mediumFontOfSize:12];
    self.firstLine.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.firstLine];
    
//    CGRect timeFrame = CGRectZero;
//    timeFrame.size = beaconTitleFrame.size;
//    timeFrame.origin.x = beaconTitleFrame.origin.x;
//    timeFrame.origin.y = CGRectGetMaxY(beaconTitleFrame);
    self.secondLine = [[UILabel alloc] initWithFrame:CGRectMake(73, 24, 194, 21)];
    self.secondLine.textColor = [UIColor whiteColor];
    self.secondLine.font = [ThemeManager mediumFontOfSize:12];
    [self.contentView addSubview:self.secondLine];
    
//    CGRect invitedFrame = CGRectZero;
//    invitedFrame.size = beaconTitleFrame.size;
//    invitedFrame.origin.x = beaconTitleFrame.origin.x;
//    invitedFrame.origin.y = CGRectGetMaxY(timeFrame);
//    self.inviteLabel = [[UILabel alloc] initWithFrame:invitedFrame];
//    self.inviteLabel.textColor = self.timeLabel.textColor;
//    self.inviteLabel.font = self.timeLabel.font;
//    self.inviteLabel.text = @"1 here, 0 invited";
//    [self.contentView addSubview:self.inviteLabel];
    
    UIView *greenBar = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 4, 50)];
    greenBar.backgroundColor = [UIColor unnormalizedColorWithRed:16 green:255 blue:118 alpha:255];
    [self.contentView addSubview:greenBar];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    CGRect titleLabelFrame = self.firstLine.frame;
//    titleLabelFrame.origin.y = CGRectGetMinY(self.thumbnailContainerView.frame);
//    self.firstLine.frame = titleLabelFrame;
//    
//    CGRect timeLabelFrame = self.secondLine.frame;
//    timeLabelFrame.origin.y = CGRectGetMaxY(titleLabelFrame);
//    self.secondLine.frame = timeLabelFrame;
    
//    CGRect inviteLabelFrame = self.inviteLabel.frame;
//    inviteLabelFrame.origin.y = CGRectGetMaxY(timeLabelFrame);
//    self.inviteLabel.frame = inviteLabelFrame;
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
//    Deal *deal = beacon.deal;
    [self.thumbnailImageView sd_setImageWithURL:beacon.deal.venue.imageURL];
//    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
//    CGRect thumbnailFrame = CGRectZero;
//    thumbnailFrame.size = CGSizeMake(39, 39);
//    thumbnailFrame.origin.x = 0.5*(self.thumbnailContainerView.frame.size.width - thumbnailFrame.size.width);
//    thumbnailFrame.origin.y = 0.5*(self.thumbnailContainerView.frame.size.height - thumbnailFrame.size.height);
//    self.thumbnailImageView.frame = thumbnailFrame;
//    self.thumbnailImageView.layer.cornerRadius = 0;
//    if (!beacon.images || !beacon.images.count) {
//
////    }
////    else {
////        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
////        BeaconImage *beaconImage = [beacon.images lastObject];
////        [self.thumbnailImageView setImageWithURL:beaconImage.imageURL];
////        self.thumbnailImageView.frame = self.thumbnailContainerView.bounds;
////        self.thumbnailImageView.layer.cornerRadius = self.thumbnailContainerView.layer.cornerRadius;
////    }
    NSString *firstLine = [NSString stringWithFormat:@"VOUCHER FOR %@", [beacon.deal.itemName uppercaseString]];
//    if (beacon.address && beacon.address.length) {
//        titleText = [titleText stringByAppendingString:[NSString stringWithFormat:@" @ %@", beacon.address]];
//    }
    self.firstLine.text = firstLine;
    [self updateInvitedLabel];
}

- (void)updateInvitedLabel
{
    
    NSInteger invited = 0;
    NSInteger going = 0;
    NSInteger here = 0;
    for (BeaconStatus *beaconStatus in self.beacon.guestStatuses.allValues) {
        invited += (beaconStatus.beaconStatusOption == BeaconStatusOptionInvited) || (beaconStatus.beaconStatusOption == BeaconStatusOptionHere) || (beaconStatus.beaconStatusOption == BeaconStatusOptionGoing);
        going += beaconStatus.beaconStatusOption == BeaconStatusOptionGoing;
        here += beaconStatus.beaconStatusOption == BeaconStatusOptionHere;
    }
    NSString *secondLine = [NSString stringWithFormat:@"%@ @ %@", [self.beacon.time formattedTime].uppercaseString, [self.beacon.deal.venue.name uppercaseString]];
    self.secondLine.text = secondLine;
//    self.inviteLabel.text = [NSString stringWithFormat:@"%d going, %d invited", going + here, invited];
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