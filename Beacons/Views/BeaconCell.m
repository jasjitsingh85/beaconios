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
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 35, 35)];
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height/2.0;
        self.avatarImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.avatarImageView];
        
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
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, self.contentView.frame.size.width - 15*2, 16)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor colorWithRed:243/255.0 green:114/255.0 blue:59/255.0 alpha:1];
        self.descriptionLabel.font = [ThemeManager boldFontOfSize:15.0];
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 130, 10)];
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
        UIImage *selectedButtonImage = [UIImage imageNamed:@"blueButton"];
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.confirmButton.frame = CGRectMake(185, 9, 68, 32);
        self.confirmButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
        self.confirmButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.confirmButton.titleLabel.font = [ThemeManager regularFontOfSize:15.0];
        [self.confirmButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.confirmButton setBackgroundImage:selectedButtonImage forState:UIControlStateSelected];
        [self.confirmButton setTitle:@"I'm in" forState:UIControlStateNormal];
        [self.confirmButton setTitle:@"I'm out" forState:UIControlStateSelected];
        [self.confirmButton addTarget:self action:@selector(confirmButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.confirmButton];
        
        
        UIImage *textButtonImage = [UIImage imageNamed:@"messageButton"];
        self.textMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.textMessageButton.frame = CGRectMake(self.contentView.frame.size.width - 20 - textButtonImage.size.width, self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
        self.textMessageButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.textMessageButton setBackgroundImage:textButtonImage forState:UIControlStateNormal];
        [self.textMessageButton addTarget:self action:@selector(textMessageButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.textMessageButton];
        
        self.textButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
        self.textButtonLabel.center = self.textMessageButton.center;
        CGRect textButtonLabelFrame = self.textButtonLabel.frame;
        textButtonLabelFrame.origin.y = CGRectGetMaxY(self.textMessageButton.frame);
        self.textButtonLabel.frame = textButtonLabelFrame;
        self.textButtonLabel.autoresizingMask = self.textMessageButton.autoresizingMask;
        self.textButtonLabel.backgroundColor = [UIColor clearColor];
        self.textButtonLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        self.textButtonLabel.textAlignment = NSTextAlignmentCenter;
        self.textButtonLabel.font = [ThemeManager regularFontOfSize:10];
        self.textButtonLabel.text = @"Text";
        self.textButtonLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.textButtonLabel];
        
        UIImage *directionsButtonImage = [UIImage imageNamed:@"getDirectionButton"];
        self.directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.directionsButton.frame = CGRectMake(0.5*(self.contentView.frame.size.width - directionsButtonImage.size.width), self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
        self.directionsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.directionsButton setBackgroundImage:directionsButtonImage forState:UIControlStateNormal];
        [self.directionsButton addTarget:self action:@selector(directionsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.directionsButton];
        
        self.directionsButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
        self.directionsButtonLabel.center = self.directionsButton.center;
        CGRect directionsButtonLabelFrame = self.directionsButtonLabel.frame;
        directionsButtonLabelFrame.origin.y = CGRectGetMaxY(self.directionsButton.frame);
        self.directionsButtonLabel.frame = directionsButtonLabelFrame;
        self.directionsButtonLabel.autoresizingMask = self.directionsButton.autoresizingMask;
        self.directionsButtonLabel.backgroundColor = [UIColor clearColor];
        self.directionsButtonLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        self.directionsButtonLabel.textAlignment = NSTextAlignmentCenter;
        self.directionsButtonLabel.font = [ThemeManager regularFontOfSize:10];
        self.directionsButtonLabel.text = @"Get Directions";
        self.directionsButtonLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.directionsButtonLabel];
        
        UIImage *infoButtonImage = [UIImage imageNamed:@"infoButton"];
        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.infoButton.frame = CGRectMake(20, self.contentView.frame.size.height - 20 - textButtonImage.size.height, textButtonImage.size.width, textButtonImage.size.height);
        self.infoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.infoButton setBackgroundImage:infoButtonImage forState:UIControlStateNormal];
        [self.infoButton addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.infoButton];
        
        self.infoButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
        self.infoButtonLabel.center = self.infoButton.center;
        CGRect infoButtonLabelFrame = self.infoButtonLabel.frame;
        infoButtonLabelFrame.origin.y = CGRectGetMaxY(self.infoButton.frame);
        self.infoButtonLabel.frame = infoButtonLabelFrame;
        self.infoButtonLabel.autoresizingMask = self.infoButton.autoresizingMask;
        self.infoButtonLabel.backgroundColor = [UIColor clearColor];
        self.infoButtonLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        self.infoButtonLabel.textAlignment = NSTextAlignmentCenter;
        self.infoButtonLabel.font = [ThemeManager regularFontOfSize:10];
        self.infoButtonLabel.text = @"More Info";
        self.infoButtonLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.infoButtonLabel];
        
        self.inviteMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect inviteMoreButtonFrame = CGRectZero;
        inviteMoreButtonFrame.size = CGSizeMake(184, 42);
        inviteMoreButtonFrame.origin.x = 0.5*(self.contentView.frame.size.width - inviteMoreButtonFrame.size.width);
        inviteMoreButtonFrame.origin.y = self.contentView.frame.size.height - inviteMoreButtonFrame.size.height - 15;
        self.inviteMoreButton.frame = inviteMoreButtonFrame;
        self.inviteMoreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.inviteMoreButton setBackgroundImage:[UIImage imageNamed:@"orangeButton"] forState:UIControlStateNormal];
        self.inviteMoreButton.titleLabel.font = [ThemeManager boldFontOfSize:13.0];
        [self.inviteMoreButton setTitle:@"Invite more friends" forState:UIControlStateNormal];
        [self.inviteMoreButton addTarget:self action:@selector(inviteMoreButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.inviteMoreButton];
        //invite more button is hidden by default. Only show for user's beacon
        self.inviteMoreButton.hidden = YES;
        
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

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    //set beacon title
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
        self.addressLabel.text = self.beacon.address;
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
