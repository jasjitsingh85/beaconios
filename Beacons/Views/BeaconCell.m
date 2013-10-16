//
//  BeaconCell.m
//  Beacons
//
//  Created by Jeff Ames on 6/1/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconCell.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIView+Shadow.h"
#import "Beacon.h"
#import "User.h"
#import "Theme.h"
#import "AppDelegate.h"
#import "BeaconImage.h"
#import "LocationTracker.h"

@interface BeaconCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *createBeaconButton;
@property (strong, nonatomic) UILabel *createBeaconLabel;
@property (strong, nonatomic) UIImageView *beaconImageView;
@property (strong, nonatomic) UIImageView *imageViewGradient;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *invitedLabel;

@end

@implementation BeaconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 20;
        [self.contentView setShadowWithColor:[UIColor blackColor] opacity:0.7 radius:2.0 offset:CGSizeMake(0, 2) shouldDrawPath:YES];
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        self.backgroundView.layer.cornerRadius = self.contentView.layer.cornerRadius;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundView.backgroundColor = [UIColor orangeColor];
        self.backgroundView.clipsToBounds = YES;
        [self.contentView addSubview:self.backgroundView];
        
        self.beaconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.frame.size.width, 108)];
        self.beaconImageView.backgroundColor = [UIColor clearColor];
        self.beaconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.beaconImageView.clipsToBounds = YES;
        [self.backgroundView addSubview:self.beaconImageView];
        
        self.imageViewGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundGradient"]];
        CGRect backgroundGradientFrame = self.imageViewGradient.frame;
        backgroundGradientFrame.origin.y = self.beaconImageView.frame.size.height - backgroundGradientFrame.size.height;
        self.imageViewGradient.frame = backgroundGradientFrame;
        [self.backgroundView addSubview:self.imageViewGradient];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 85, self.contentView.frame.size.width - 36*2, 18)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.font = [ThemeManager regularFontOfSize:17.0];
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 117, 200, 15)];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1];
        self.addressLabel.font = [ThemeManager regularFontOfSize:14];
        self.addressLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.addressLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 50, 100, 30)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [ThemeManager lightFontOfSize:28];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.timeLabel];
        
        self.invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 138, 200, 15)];
        self.invitedLabel.backgroundColor = [UIColor clearColor];
        self.invitedLabel.textColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1];
        self.invitedLabel.adjustsFontSizeToFitWidth = YES;
        self.invitedLabel.font = [ThemeManager regularFontOfSize:14];
        [self.contentView addSubview:self.invitedLabel];
        
        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.infoButton setTitle:@"i" forState:UIControlStateNormal];
        [self.infoButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
        self.infoButton.backgroundColor = [UIColor whiteColor];
        CGRect infoButtonFrame;
        infoButtonFrame.size = CGSizeMake(32, 32);
        infoButtonFrame.origin.x = 0.5*(self.contentView.frame.size.width - infoButtonFrame.size.width);
        infoButtonFrame.origin.y = 166;
        self.infoButton.frame = infoButtonFrame;
        self.infoButton.layer.cornerRadius = self.infoButton.frame.size.width/2.0;
        [self.infoButton addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoButton setShadowWithColor:[UIColor blackColor] opacity:0.7 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
        [self.contentView addSubview:self.infoButton];
        
        self.createBeaconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect createBeaconButtonFrame = CGRectZero;
        createBeaconButtonFrame.size = CGSizeMake(184, 42);
        createBeaconButtonFrame.origin.x = 0.5*(self.contentView.frame.size.width - createBeaconButtonFrame.size.width);
        createBeaconButtonFrame.origin.y = self.contentView.frame.size.height - createBeaconButtonFrame.size.height - 15;
        self.createBeaconButton.frame = createBeaconButtonFrame;
        [self.createBeaconButton setBackgroundImage:[UIImage imageNamed:@"orangeButton"] forState:UIControlStateNormal];
        [self.createBeaconButton setTitle:@"Create a Beacon" forState:UIControlStateNormal];
        self.createBeaconButton.titleLabel.font = [ThemeManager boldFontOfSize:13.0];
        self.createBeaconButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.createBeaconButton setTitle:@"Create a Beacon" forState:UIControlStateNormal];
        [self.createBeaconButton addTarget:self action:@selector(createBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.createBeaconButton];
        self.createBeaconButton.hidden = YES;
        
        self.createBeaconLabel = [[UILabel alloc] init];
        self.createBeaconLabel.backgroundColor = [UIColor clearColor];
        CGRect createBeaconLabelFrame = CGRectZero;
        createBeaconLabelFrame.size = CGSizeMake(226, 65);
        createBeaconLabelFrame.origin.x = 0.5*(self.contentView.frame.size.width - createBeaconLabelFrame.size.width);
        createBeaconLabelFrame.origin.y = 50;
        self.createBeaconLabel.frame = createBeaconLabelFrame;
        self.createBeaconLabel.text = @"Instead of sending multiple texts, set a Beacon to invite friends to hang out";
        self.createBeaconLabel.numberOfLines = 4;
        self.createBeaconLabel.textAlignment = NSTextAlignmentCenter;
        self.createBeaconLabel.adjustsFontSizeToFitWidth = YES;
        self.createBeaconLabel.font = [ThemeManager regularFontOfSize:10.0];
        [self.contentView addSubview:self.createBeaconLabel];
        self.createBeaconLabel.hidden = YES;
        
    }
    return self;
}

- (void)setSecondaryColor:(UIColor *)secondaryColor
{
    _secondaryColor = secondaryColor;
    self.beaconImageView.backgroundColor = secondaryColor;
}

- (void)setPrimaryColor:(UIColor *)primaryColor
{
    _primaryColor = primaryColor;
    self.backgroundView.backgroundColor = primaryColor;
}

- (void)configureForBeacon:(Beacon *)beacon atIndexPath:(NSIndexPath *)indexPath
{
    if (beacon.isUserBeacon) {
        self.titleLabel.text = @"My Beacon";
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@'s Beacon", beacon.creator.firstName];
    }
    self.descriptionLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.addressLabel.hidden = NO;
    self.descriptionLabel.text = beacon.beaconDescription;
    self.timeLabel.text = [beacon.time formattedDate].lowercaseString;
    
    if (beacon.creator.avatarURL) {
        self.avatarImageView.alpha = 1;
        [self.avatarImageView setImageWithURL:beacon.creator.avatarURL placeholderImage:nil];
    }
    else {
        self.avatarImageView.alpha = 0;
    }
    self.createBeaconButton.hidden = YES;
    self.createBeaconLabel.hidden = YES;
    
    if (beacon.images && beacon.images.count) {
        BeaconImage *beaconImage = [beacon.images lastObject];
        [self.beaconImageView setImageWithURL:beaconImage.imageURL];
        self.imageViewGradient.hidden = NO;
    }
    else {
        self.beaconImageView.image = nil;
        self.imageViewGradient.hidden = YES;
    }
    [self updateInvitedLabel];
    [self updateAddressLabel];
}

- (void)updateAddressLabel
{
    if (self.beacon.address) {
        CGFloat distance = [[LocationTracker sharedTracker] distanceFromCurrentLocationToCoordinate:self.beacon.coordinate];
        CGFloat distanceMiles = METERS_TO_MILES*distance;
        NSString *distanceString;
        if (distanceMiles < 0.25) {
            distanceString = [NSString stringWithFormat:@"(%0.0f feet)", METERS_TO_FEET*distance];
        }
        else {
            distanceString = [NSString stringWithFormat:@"(%0.1f mi)", METERS_TO_MILES*distance];
        }
        NSString *string = [NSString stringWithFormat:@"%@ %@", self.beacon.address, distanceString];
        NSRange range = [string rangeOfString:distanceString];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
        self.addressLabel.attributedText = attributedText;
    }
}

- (void)updateInvitedLabel
{
    NSString *creatorText = [self.beacon.creator fullName];
    NSString *otherText;
    if (self.beacon.guestStatuses && self.beacon.guestStatuses.count > 1) {
        NSInteger otherCount = self.beacon.guestStatuses.count - 1;
        NSString *other = otherCount == 1 ? @"other..." : @"others...";
        otherText = [NSString stringWithFormat:@"and %d %@", otherCount, other];
    }
    NSMutableAttributedString *attributedText;
    if (otherText) {
        NSString *string = [NSString stringWithFormat:@"%@ %@", creatorText, otherText];
        NSRange range = [string rangeOfString:otherText];
        attributedText = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
    }
    else {
        attributedText = [[NSMutableAttributedString alloc] initWithString:creatorText];
    }
    self.invitedLabel.attributedText = attributedText;
}

- (void)infoButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(beaconCellInfoButtonTouched:)]) {
        [self.delegate beaconCellInfoButtonTouched:self];
    }
}


@end
