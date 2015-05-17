//
//  VoucherTableViewCell.m
//  Beacons
//
//  Created by Jasjit Singh on 5/14/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "VoucherTableViewCell.h"
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
#import "Voucher.h"

@implementation VoucherTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.thumbnailContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 48)];
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
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.size.width, 48)];
    backgroundView.backgroundColor = [UIColor unnormalizedColorWithRed:0 green:161 blue:157 alpha:255];
    [self.contentView addSubview:backgroundView];
    //self.contentView.backgroundColor = [UIColor unnormalizedColorWithRed:0 green:161 blue:157 alpha:255];
    [self.contentView addSubview:self.thumbnailContainerView];
    
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:self.thumbnailContainerView.bounds];
    self.thumbnailImageView.clipsToBounds = YES;
    [self.thumbnailContainerView addSubview:self.thumbnailImageView];
    
    UIImageView *goldCoin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"singleGoldCoin"]];
    goldCoin.centerX = self.thumbnailContainerView.width/2;
    goldCoin.centerY = self.thumbnailContainerView.height/2;
    [self.thumbnailContainerView addSubview:goldCoin];
    
    //    CGRect beaconTitleFrame = CGRectZero;
    //    beaconTitleFrame.size = CGSizeMake(184, 21);
    //    beaconTitleFrame.origin.x = CGRectGetMaxX(self.thumbnailContainerView.frame) + 13;
    //    beaconTitleFrame.origin.y = CGRectGetMinY(self.thumbnailContainerView.frame);
    self.firstLine = [[UILabel alloc] initWithFrame:CGRectMake(73, 6, 194, 21)];
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

- (void)setVoucher:(Voucher *)voucher
{
    _voucher = voucher;
    //    Deal *deal = beacon.deal;
    [self.thumbnailImageView sd_setImageWithURL:voucher.deal.venue.imageURL];
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
    NSString *firstLine = [NSString stringWithFormat:@"VOUCHER FOR %@", [self.voucher.deal.itemName uppercaseString]];
    NSString *secondLine = [NSString stringWithFormat:@"@%@", [self.voucher.deal.venue.name uppercaseString]];
    //    if (beacon.address && beacon.address.length) {
    //        titleText = [titleText stringByAppendingString:[NSString stringWithFormat:@" @ %@", beacon.address]];
    //    }
    self.firstLine.text = firstLine;
    self.secondLine.text = secondLine;
    //[self updateInvitedLabel];
}

//- (void)updateInvitedLabel
//{
//    
//    NSInteger invited = 0;
//    NSInteger going = 0;
//    NSInteger here = 0;
//    for (BeaconStatus *beaconStatus in self.beacon.guestStatuses.allValues) {
//        invited += (beaconStatus.beaconStatusOption == BeaconStatusOptionInvited) || (beaconStatus.beaconStatusOption == BeaconStatusOptionHere) || (beaconStatus.beaconStatusOption == BeaconStatusOptionGoing);
//        going += beaconStatus.beaconStatusOption == BeaconStatusOptionGoing;
//        here += beaconStatus.beaconStatusOption == BeaconStatusOptionHere;
//    }
//    NSString *secondLine = [NSString stringWithFormat:@"%@, %d GOING / %d INVITED", [self.beacon.time formattedTime].uppercaseString, going + here, invited];
//    self.secondLine.text = secondLine;
//    //    self.inviteLabel.text = [NSString stringWithFormat:@"%d going, %d invited", going + here, invited];
//}

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
