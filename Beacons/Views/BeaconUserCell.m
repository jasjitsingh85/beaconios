//
//  BeaconConfirmedCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconUserCell.h"
#import "Theme.h"
#import "User.h"
#import "Beacon.h"

@interface BeaconUserCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *addFriendButton;

@end

@implementation BeaconUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] init];
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(100, 20);
        frame.origin.x = 13;
        frame.origin.y = 0.5*(self.frame.size.height - frame.size.height);
        self.nameLabel.frame = frame;
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor darkGrayColor];
        self.nameLabel.font = [ThemeManager boldFontOfSize:10];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.nameLabel];
        
        self.addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *addFriendImage = [UIImage imageNamed:@"addFriendButton"];
        [self.addFriendButton setImage:addFriendImage forState:UIControlStateNormal];
        frame = CGRectZero;
        frame.size = addFriendImage.size;
        frame.origin.x = 207;
        frame.origin.y = 0.5*(self.frame.size.height - frame.size.height);
        self.addFriendButton.frame = frame;
        self.addFriendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.addFriendButton];
    }
    return self;
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
}

- (void)setUser:(User *)user
{
    _user = user;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
}

@end
