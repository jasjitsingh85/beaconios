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
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *textMessageButton;
@property (strong, nonatomic) UIButton *directionsButton;
@property (strong, nonatomic) UILabel *directionsButtonLabel;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UILabel *infoButtonLabel;
@property (strong, nonatomic) UILabel *textButtonLabel;
@property (strong, nonatomic) UIButton *inviteMoreButton;
@property (strong, nonatomic) UIButton *createBeaconButton;
@property (strong, nonatomic) UILabel *createBeaconLabel;
@property (strong, nonatomic) UIImageView *beaconImageView;
@property (strong, nonatomic) UILabel *invitedLabel;

@end

@implementation BeaconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beaconCellBackgroundGreen"]];
        self.backgroundImageView.frame = self.contentView.bounds;
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.backgroundImageView];
        UIImage *maskImage = [UIImage imageNamed:@"beaconCellImageMask"];
        CALayer *mask = [CALayer layer];
        mask.contents = (id)maskImage.CGImage;
        mask.frame = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
        self.beaconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maskImage.size.width, maskImage.size.height)];
        self.beaconImageView.backgroundColor = [UIColor clearColor];
        self.beaconImageView.layer.mask = mask;
        [self.backgroundImageView addSubview:self.beaconImageView];
        
        
        
//        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 92, self.contentView.frame.size.width - 36*2, 15)];
//        self.titleLabel.backgroundColor = [UIColor clearColor];
//        self.titleLabel.textColor = [UIColor whiteColor];
//        self.titleLabel.font = [ThemeManager regularFontOfSize:15.0];
//        self.titleLabel.adjustsFontSizeToFitWidth = YES;
//        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 92, self.contentView.frame.size.width - 36*2, 15)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.font = [ThemeManager boldFontOfSize:15.0];
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 123, 130, 11)];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1];
        self.addressLabel.font = [ThemeManager regularFontOfSize:11];
        self.addressLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.addressLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 65, 100, 20)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [ThemeManager regularFontOfSize:20];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.timeLabel];
        
        self.invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 144, 150, 11)];
        self.invitedLabel.backgroundColor = [UIColor clearColor];
        self.invitedLabel.textColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1];
        self.invitedLabel.font = [ThemeManager regularFontOfSize:11];
        [self.contentView addSubview:self.invitedLabel];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect confirmButtonRect;
        confirmButtonRect.size = CGSizeMake(76, 36);
        confirmButtonRect.origin.x = 0.5*(self.contentView.frame.size.width - confirmButtonRect.size.width);
        confirmButtonRect.origin.y = 168;
        self.confirmButton.frame = confirmButtonRect;
        self.confirmButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
        self.confirmButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.confirmButton.titleLabel.font = [ThemeManager regularFontOfSize:15.0];
        self.confirmButton.backgroundColor = [UIColor whiteColor];
        [self.confirmButton setTitleColor:[UIColor colorWithRed:207/255.0 green:176/255.0 blue:171/255.0 alpha:1] forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"I'm out" forState:UIControlStateSelected];
        [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        self.confirmButton.layer.cornerRadius = 4;
        [self.contentView addSubview:self.confirmButton];
        
        
//        UIImage *textButtonImage = [UIImage imageNamed:@"messageButton"];
//        self.textMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.textMessageButton.frame = CGRectMake(self.contentView.frame.size.width - 20 - textButtonImage.size.width, self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
//        self.textMessageButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//        [self.textMessageButton setBackgroundImage:textButtonImage forState:UIControlStateNormal];
//        [self.textMessageButton addTarget:self action:@selector(textMessageButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.textMessageButton];
        
//        self.textButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
//        self.textButtonLabel.center = self.textMessageButton.center;
//        CGRect textButtonLabelFrame = self.textButtonLabel.frame;
//        textButtonLabelFrame.origin.y = CGRectGetMaxY(self.textMessageButton.frame);
//        self.textButtonLabel.frame = textButtonLabelFrame;
//        self.textButtonLabel.autoresizingMask = self.textMessageButton.autoresizingMask;
//        self.textButtonLabel.backgroundColor = [UIColor clearColor];
//        self.textButtonLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
//        self.textButtonLabel.textAlignment = NSTextAlignmentCenter;
//        self.textButtonLabel.font = [ThemeManager regularFontOfSize:10];
//        self.textButtonLabel.text = @"Text";
//        self.textButtonLabel.adjustsFontSizeToFitWidth = YES;
//        [self.contentView addSubview:self.textButtonLabel];
        
//        UIImage *directionsButtonImage = [UIImage imageNamed:@"getDirectionButton"];
//        self.directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.directionsButton.frame = CGRectMake(0.5*(self.contentView.frame.size.width - directionsButtonImage.size.width), self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
//        self.directionsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//        [self.directionsButton setBackgroundImage:directionsButtonImage forState:UIControlStateNormal];
//        [self.directionsButton addTarget:self action:@selector(directionsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.directionsButton];
//        
//        self.directionsButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
//        self.directionsButtonLabel.center = self.directionsButton.center;
//        CGRect directionsButtonLabelFrame = self.directionsButtonLabel.frame;
//        directionsButtonLabelFrame.origin.y = CGRectGetMaxY(self.directionsButton.frame);
//        self.directionsButtonLabel.frame = directionsButtonLabelFrame;
//        self.directionsButtonLabel.autoresizingMask = self.directionsButton.autoresizingMask;
//        self.directionsButtonLabel.backgroundColor = [UIColor clearColor];
//        self.directionsButtonLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
//        self.directionsButtonLabel.textAlignment = NSTextAlignmentCenter;
//        self.directionsButtonLabel.font = [ThemeManager regularFontOfSize:10];
//        self.directionsButtonLabel.text = @"Get Directions";
//        self.directionsButtonLabel.adjustsFontSizeToFitWidth = YES;
//        [self.contentView addSubview:self.directionsButtonLabel];
//        
//        UIImage *infoButtonImage = [UIImage imageNamed:@"infoButton"];
//        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.infoButton.frame = CGRectMake(20, self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
//        self.infoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//        [self.infoButton setBackgroundImage:infoButtonImage forState:UIControlStateNormal];
//        [self.infoButton addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.infoButton];
//        
//        self.infoButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
//        self.infoButtonLabel.center = self.infoButton.center;
//        CGRect infoButtonLabelFrame = self.infoButtonLabel.frame;
//        infoButtonLabelFrame.origin.y = CGRectGetMaxY(self.infoButton.frame);
//        self.infoButtonLabel.frame = infoButtonLabelFrame;
//        self.infoButtonLabel.autoresizingMask = self.infoButton.autoresizingMask;
//        self.infoButtonLabel.backgroundColor = [UIColor clearColor];
//        self.infoButtonLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
//        self.infoButtonLabel.textAlignment = NSTextAlignmentCenter;
//        self.infoButtonLabel.font = [ThemeManager regularFontOfSize:10];
//        self.infoButtonLabel.text = @"More Info";
//        self.infoButtonLabel.adjustsFontSizeToFitWidth = YES;
//        [self.contentView addSubview:self.infoButtonLabel];
        
//        self.inviteMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        CGRect inviteMoreButtonFrame = CGRectZero;
//        inviteMoreButtonFrame.size = CGSizeMake(184, 42);
//        inviteMoreButtonFrame.origin.x = 0.5*(self.contentView.frame.size.width - inviteMoreButtonFrame.size.width);
//        inviteMoreButtonFrame.origin.y = self.contentView.frame.size.height - inviteMoreButtonFrame.size.height - 15;
//        self.inviteMoreButton.frame = inviteMoreButtonFrame;
//        self.inviteMoreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        [self.inviteMoreButton setBackgroundImage:[UIImage imageNamed:@"orangeButton"] forState:UIControlStateNormal];
//        self.inviteMoreButton.titleLabel.font = [ThemeManager boldFontOfSize:13.0];
//        [self.inviteMoreButton setTitle:@"Invite more friends" forState:UIControlStateNormal];
//        [self.inviteMoreButton addTarget:self action:@selector(inviteMoreButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.inviteMoreButton];
//        //invite more button is hidden by default. Only show for user's beacon
//        self.inviteMoreButton.hidden = YES;
        
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

- (void)configureForBeacon:(Beacon *)beacon atIndexPath:(NSIndexPath *)indexPath
{
    if (beacon.isUserBeacon) {
        self.titleLabel.text = @"My Beacon";
        self.inviteMoreButton.hidden = NO;
        self.directionsButtonLabel.hidden = YES;
        self.directionsButton.hidden = YES;
        self.infoButton.hidden = YES;
        self.infoButtonLabel.hidden = YES;
        self.textButtonLabel.hidden = YES;
        self.textMessageButton.hidden = YES;
        self.confirmButton.hidden = YES;
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@'s Beacon", beacon.creator.firstName];
        self.inviteMoreButton.hidden = YES;
        self.directionsButtonLabel.hidden = NO;
        self.directionsButton.hidden = NO;
        self.infoButton.hidden = NO;
        self.infoButtonLabel.hidden = NO;
        self.textButtonLabel.hidden = NO;
        self.textMessageButton.hidden = NO;
        self.confirmButton.hidden = NO;
    }
    self.descriptionLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.addressLabel.hidden = NO;
    self.textButtonLabel.text = [NSString stringWithFormat:@"Text %@", beacon.creator.firstName];
    self.descriptionLabel.text = beacon.beaconDescription;
    self.addressLabel.text = beacon.address;
    self.timeLabel.text = [beacon.time formattedDate];
    
    if (self.beacon.address) {
        CGFloat distance = [[LocationTracker sharedTracker] distanceFromCurrentLocationToCoordinate:self.beacon.coordinate];
        CGFloat distanceMiles = METERS_TO_MILES*distance;
        NSString *distanceString;
        if (distanceMiles < 0.25) {
            distanceString = [NSString stringWithFormat:@"(%0.0f feet)", METERS_TO_FEET*distance];
        }
        else {
            distanceString = [NSString stringWithFormat:@"(%0.3f mi)", METERS_TO_MILES*distance];
        }
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@", self.beacon.address, distanceString];
    }
    
    self.confirmButton.selected = self.beacon.userAttending;
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
    }
    [self updateInvitedLabel];
}

- (void)updateInvitedLabel
{
    NSString *creatorText = [self.beacon.creator fullName];
    NSString *otherText;
    if (self.beacon.invited && self.beacon.invited.count) {
        NSString *other = self.beacon.invited.count == 1 ? @"other" : @"others";
        otherText = [NSString stringWithFormat:@"and %d %@", self.beacon.invited.count, other];
    }
    if (otherText) {
        self.invitedLabel.text = [NSString stringWithFormat:@"%@ %@", creatorText, otherText];
    }
    else {
        self.invitedLabel.text = creatorText;
    }
}

- (void)configureEmptyBeacon
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.titleLabel.text = @"My Beacon";
    [self.avatarImageView setImageWithURL:appDelegate.loggedInUser.avatarURL];
    self.createBeaconButton.hidden = NO;
    self.createBeaconLabel.hidden = NO;
    self.infoButton.hidden = YES;
    self.directionsButtonLabel.hidden = YES;
    self.directionsButton.hidden = YES;
    self.infoButton.hidden = YES;
    self.infoButtonLabel.hidden = YES;
    self.textButtonLabel.hidden = YES;
    self.textMessageButton.hidden = YES;
    self.confirmButton.hidden = YES;
    self.descriptionLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.addressLabel.hidden = YES;
}

- (void)confirmButtonTouched:(id)sender
{
    self.confirmButton.selected = !self.confirmButton.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconCellConfirmButtonTouched:confirmed:)]) {
        [self.delegate beaconCellConfirmButtonTouched:self confirmed:self.confirmButton.selected];
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

- (void)inviteMoreButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(beaconCellInviteMoreButtonTouched:)]) {
        [self.delegate beaconCellInviteMoreButtonTouched:self];
    }
}

- (void)createBeaconButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(beaconCellCreateBeaconButtonTouched:)]) {
        [self.delegate beaconCellCreateBeaconButtonTouched:self];
    }
}


@end
