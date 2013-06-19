//
//  BeaconCell.m
//  Beacons
//
//  Created by Jeff Ames on 6/1/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Beacon.h"
#import "User.h"
#import "Theme.h"

@interface BeaconCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *textMessageButton;
@property (strong, nonatomic) UIButton *directionsButton;
@property (strong, nonatomic) UIButton *infoButton;

@end

@implementation BeaconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        self.contentView.layer.cornerRadius = 2;
        self.contentView.clipsToBounds = YES;
        
        //add drop shadow. Must be applied to contentView's superview since contentView clips to bounds
        self.layer.cornerRadius = self.contentView.layer.cornerRadius;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
        
        CGRect dividerFrame;
        dividerFrame.size = CGSizeMake(246, 1);
        dividerFrame.origin.x = 0.5*(self.contentView.frame.size.width - dividerFrame.size.width);
        dividerFrame.origin.y = 51;
        UIView *dividerView = [[UIView alloc] initWithFrame:dividerFrame];
        dividerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        dividerView.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1];
        [self.contentView addSubview:dividerView];
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, self.contentView.frame.size.width - 55, 15)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        self.titleLabel.font = [ThemeManager regularFontOfSize:14.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, self.contentView.frame.size.width - 15, 16)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor colorWithRed:243/255.0 green:114/255.0 blue:59/255.0 alpha:1];
        self.descriptionLabel.font = [ThemeManager boldFontOfSize:15.0];
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 100, 130, 10)];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        self.addressLabel.font = [ThemeManager regularFontOfSize:11];
        self.addressLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.addressLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(197, 100, 50, 12)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        self.timeLabel.font = [ThemeManager regularFontOfSize:11];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.timeLabel];
        
        UIImage *buttonImage = [UIImage imageNamed:@"orangeButton"];
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.confirmButton.frame = CGRectMake(185, 9, 68, 32);
        self.confirmButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
        self.confirmButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.confirmButton.titleLabel.font = [ThemeManager regularFontOfSize:15.0];
        [self.confirmButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"I'm in" forState:UIControlStateNormal];
        [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.confirmButton];
        
        
        UIImage *textButtonImage = [UIImage imageNamed:@"messageButton"];
        self.textMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.textMessageButton.frame = CGRectMake(self.contentView.frame.size.width - 20 - textButtonImage.size.width, self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
        self.textMessageButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.textMessageButton setBackgroundImage:textButtonImage forState:UIControlStateNormal];
        [self.textMessageButton addTarget:self action:@selector(textMessageButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.textMessageButton];
        
        UIImage *directionsButtonImage = [UIImage imageNamed:@"getDirectionButton"];
        self.directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.directionsButton.frame = CGRectMake(0.5*(self.contentView.frame.size.width - directionsButtonImage.size.width), self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
        self.directionsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.directionsButton setBackgroundImage:directionsButtonImage forState:UIControlStateNormal];
        [self.directionsButton addTarget:self action:@selector(directionsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.directionsButton];
        
        UIImage *infoButtonImage = [UIImage imageNamed:@"infoButton"];
        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.infoButton.frame = CGRectMake(20, self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
        self.infoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.infoButton setBackgroundImage:infoButtonImage forState:UIControlStateNormal];
        [self.infoButton addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.infoButton];
        
        
    }
    return self;
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    //set beacon title
    if (beacon.isUserBeacon) {
        self.titleLabel.text = @"My Beacon";
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@'s Beacon", beacon.creator.firstName];
    }
    self.descriptionLabel.text = beacon.beaconDescription;
    self.addressLabel.text = beacon.address;
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"hh:mm a";
    self.timeLabel.text = [timeFormatter stringFromDate:self.beacon.time];
    
    if (self.beacon.address) {
        self.addressLabel.text = self.beacon.address;
    }
}

- (void)confirmButtonTouched:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconCellConfirmButtonTouched:)]) {
        [self.delegate beaconCellConfirmButtonTouched:self];
    }
}

- (void)textMessageButtonTouched:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconCellTextButtonTouched:)]) {
        [self.delegate beaconCellTextButtonTouched:self];
    }
}

- (void)infoButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(beaconCellInfoButtonTouched:)]) {
        [self.delegate beaconCellInfoButtonTouched:self];
    }
}

- (void)directionsButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(beaconCellDirectionsButtonTouched:)]) {
        [self.delegate beaconCellDirectionsButtonTouched:self];
    }
}


@end
