//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#include <tgmath.h>
#import "UIView+Shadow.h"
#import "Venue.h"

@interface DealTableViewCell()

@property (strong, nonatomic) UIView *backgroundView;

@end

@implementation DealTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.venueImageView = [[UIImageView alloc] init];
    self.venueImageView.height = 153;
    self.venueImageView.width = self.width;
    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.venueImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.venueImageView];
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.venueImageView.bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.venueImageView addSubview:self.backgroundView];
    
    self.venueLabel = [[UILabel alloc] init];
    self.venueLabel.font = [ThemeManager boldFontOfSize:19*1.3];
    self.venueLabel.textColor = [UIColor whiteColor];
    self.venueLabel.adjustsFontSizeToFitWidth = YES;
    [self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabel.textAlignment = NSTextAlignmentCenter;
    self.venueLabel.numberOfLines = 0;
    [self.contentView addSubview:self.venueLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9];
    self.descriptionLabel.size = CGSizeMake(191, 24);
    self.descriptionLabel.centerX = self.width/2.0;
    self.descriptionLabel.y = 90;
    self.descriptionLabel.font = [ThemeManager regularFontOfSize:1.3*9];
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.descriptionLabel];
    
    self.venueDescriptionBackground = [[UIView alloc] init];
    self.venueDescriptionBackground.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.venueDescriptionBackground];
    
    self.venueDescriptionLabel = [[UILabel alloc] init];
    self.venueDescriptionLabel.font = [ThemeManager lightFontOfSize:1.3*10];
    self.venueDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.venueDescriptionLabel.textColor = [UIColor blackColor];
    self.venueDescriptionLabel.numberOfLines = 2;
    [self.venueDescriptionBackground addSubview:self.venueDescriptionLabel];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager boldFontOfSize:1.3*8];
    self.distanceLabel.textColor = [UIColor blackColor];
    self.distanceLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.distanceLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.venueImageView.height = 153;
    self.venueImageView.width = self.width;
    
    self.venueLabel.width = self.width - 40;
    self.venueLabel.centerX = self.width/2.0;
    self.venueLabel.height = 41;
    self.venueLabel.centerY = 69;
    
    self.venueDescriptionBackground.width = self.width;
    self.venueDescriptionBackground.height = 37;
    self.venueDescriptionBackground.y = self.venueImageView.bottom;
    self.venueDescriptionLabel.width = self.venueDescriptionBackground.width - 40;
    self.venueDescriptionLabel.height = self.venueDescriptionBackground.height;
    self.venueDescriptionLabel.centerX = self.venueDescriptionBackground.width/2.0;
    [self.venueDescriptionBackground setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    
    self.distanceLabel.size = CGSizeMake(35, 35);
    self.distanceLabel.layer.cornerRadius = self.distanceLabel.width/2.0;
    self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.textAlignment = NSTextAlignmentCenter;
    self.distanceLabel.y = 11;
    self.distanceLabel.right = self.contentView.width - 5;
    
}

- (void)setDeal:(Deal *)deal
{
    _deal = deal;
    
    self.venueLabel.text = self.deal.venue.name;
    [self.venueImageView setImageWithURL:self.deal.venue.imageURL];
    self.descriptionLabel.text = self.deal.dealDescriptionShort;
    self.venueDescriptionLabel.text = self.deal.venue.placeDescription;
    self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
}

- (NSString *)stringForDistance:(CLLocationDistance)distance
{
    CGFloat distanceMiles = METERS_TO_MILES*distance;
    NSString *distanceString;
    if (distanceMiles < 0.25) {
        distanceString = [NSString stringWithFormat:@"%0.0fft", (floor((METERS_TO_FEET*distance)/10))*10];
    }
    else {
        distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
    }
    return distanceString;
}

@end