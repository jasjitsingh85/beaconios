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
@property (strong, nonatomic) UIButton *textMessageButton;
@property (strong, nonatomic) UIButton *confirmButton;
@end

@implementation BeaconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 2;
        self.contentView.clipsToBounds = YES;
        
        //add drop shadow. Must be applied to contentView's superview since contentView clips to bounds
        self.layer.cornerRadius = self.contentView.layer.cornerRadius;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, self.contentView.frame.size.width - 55, 15)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithRed:71/255.0 green:197/255.0 blue:203/255.0 alpha:1];
        self.titleLabel.font = [ThemeManager regularFontOfSize:14.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 45, self.contentView.frame.size.width - 55, 16)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor colorWithRed:243/255.0 green:114/255.0 blue:59/255.0 alpha:1];
        self.descriptionLabel.font = [ThemeManager regularFontOfSize:14.0];
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 68, 128, 10)];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textColor = [UIColor blackColor];
        self.addressLabel.font = [ThemeManager regularFontOfSize:10];
        self.addressLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.addressLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(216, 68, 128, 10)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor blackColor];
        self.timeLabel.font = [ThemeManager regularFontOfSize:10];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.timeLabel];
        
        
        UIImage *buttonImage = [UIImage imageNamed:@"orangeButton"];
        self.textMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.textMessageButton.frame = CGRectMake(56, 103, 72, 24);
        self.textMessageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
        self.textMessageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.textMessageButton.titleLabel.font  = [ThemeManager regularFontOfSize:10.0];
        [self.textMessageButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.textMessageButton setTitle:@"Text" forState:UIControlStateNormal];
        [self.textMessageButton addTarget:self action:@selector(textMessageButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.textMessageButton];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.confirmButton.frame = CGRectMake(136, 103, 50, 24);
        self.confirmButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
        self.confirmButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.confirmButton.titleLabel.font = [ThemeManager regularFontOfSize:10.0];
        [self.confirmButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"I'm in" forState:UIControlStateNormal];
        [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.confirmButton];
        
    }
    return self;
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    //set beacon title
    self.titleLabel.text = [NSString stringWithFormat:@"%@'s Beacon", beacon.creator.firstName];
    [self.textMessageButton setTitle:[NSString stringWithFormat:@"Text %@", beacon.creator.firstName] forState:UIControlStateNormal];
    self.descriptionLabel.text = beacon.beaconDescription;
    self.addressLabel.text = beacon.address;
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


@end
