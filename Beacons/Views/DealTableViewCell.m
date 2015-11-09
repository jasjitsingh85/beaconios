//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealTableViewCell.h"
#import <MapKit/MapKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#include <tgmath.h>
#import "Utilities.h"
#import "UIView+Shadow.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Venue.h"
#import <QuartzCore/QuartzCore.h>
#import "DealHours.h"
#import "APIClient.h"

@interface DealTableViewCell()

@property (strong, nonatomic) UIView *backgroundDealView;

@end

@implementation DealTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.venueImageView = [[UIImageView alloc] init];
    self.venueImageView.height = 103;
    self.venueImageView.width = self.width;
    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.venueImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.venueImageView];
    
//    self.venueScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 146)];
//    self.venueScroll.pagingEnabled = YES;
//    self.venueScroll.showsHorizontalScrollIndicator = NO;

    self.venuePreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 146)];
    self.backgroundDealView = [[UIView alloc] initWithFrame:self.venuePreviewView.bounds];
    self.backgroundDealView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    //self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.venueImageView addSubview:self.backgroundDealView];
    
    self.backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 87, self.venueImageView.size.width, 60)];
    UIImage *gradientImage = [UIImage imageNamed:@"backgroundGradient@2x.png"];
    [self.backgroundGradient setImage:gradientImage];
    [self.venueImageView addSubview:self.backgroundGradient];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:20];
    self.venueLabelLineOne.textColor = [UIColor whiteColor];
    //self.venueLabelLineOne.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.venuePreviewView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:34];
    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
    //self.venueLabelLineTwo.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineTwo.numberOfLines = 1;
    [self.venuePreviewView addSubview:self.venueLabelLineTwo];
    
    self.descriptionLabel = [[UILabel alloc] init];
    //self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 26;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 90;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:14];
    //self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.venuePreviewView addSubview:self.descriptionLabel];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager regularFontOfSize:11];
    self.dealTime.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venuePreviewView addSubview:self.dealTime];
    
//    self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 89, 40, 26)];
//    self.priceLabel.textColor = [UIColor whiteColor];
//    self.priceLabel.textAlignment = NSTextAlignmentLeft;
//    self.priceLabel.font = [ThemeManager boldFontOfSize:18];
//    [self.venuePreviewView addSubview:self.priceLabel];
    
    self.marketPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 90, 40, 26)];
    self.marketPriceLabel.textColor = [UIColor whiteColor];
    self.marketPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.marketPriceLabel.font = [ThemeManager regularFontOfSize:12];
    [self.venuePreviewView addSubview:self.marketPriceLabel];
    
    self.itemPriceLabel = [[UILabel alloc] init];
    self.itemPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.itemPriceLabel.font = [ThemeManager boldFontOfSize:14];
    self.itemPriceLabel.textColor = [UIColor whiteColor];
    self.itemPriceLabel.height = 26;
    self.itemPriceLabel.y = 90;
    [self.venuePreviewView addSubview:self.itemPriceLabel];
    
    //    self.venueDescriptionBackground = [[UIView alloc] init];
    //    self.venueDescriptionBackground.backgroundColor = [UIColor whiteColor];
    //    [self.contentView addSubview:self.venueDescriptionBackground];
    
//    self.venueDescriptionLabel = [[UILabel alloc] init];
//    self.venueDescriptionLabel.font = [ThemeManager lightFontOfSize:1.3*10];
//    self.venueDescriptionLabel.textAlignment = NSTextAlignmentCenter;
//    self.venueDescriptionLabel.textColor = [UIColor blackColor];
//    self.venueDescriptionLabel.numberOfLines = 0;
//    [self.venueDescriptionBackground addSubview:self.venueDescriptionLabel];
    
    //venuePreviewView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0];
//    [self.venueScroll addSubview:self.venuePreviewView];
    
//    CGFloat originForVenueDetail = self.contentView.frame.size.width;
//    self.venueDetailView = [[UIView alloc] initWithFrame:CGRectMake(originForVenueDetail, 0, self.contentView.frame.size.width, 196)];
//    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    [blurEffectView setFrame:self.venueDetailView.bounds];
//    [self.venueDetailView addSubview:blurEffectView];
    
//    UIVibrancyEffect *vibrance = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//    UIVisualEffectView *vibranceEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrance];
//    [vibranceEffectView setFrame:self.venueDetailView.bounds];
//    [blurEffectView addSubview:vibranceEffectView];
    
    //self.venueDetailView.backgroundColor = [UIColor colorWithRed:23/255.f green:10/255.f blue:1/255.f alpha:.75];
//    
//    self.venueDetailLabel = [[UILabel alloc] init];
//    self.venueDetailLabel.font = [ThemeManager boldFontOfSize:24];
//    self.venueDetailLabel.textColor = [UIColor whiteColor];
////    self.venueDetailLabel.adjustsFontSizeToFitWidth = YES;
////    [self.venueDetailLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
//    self.venueDetailLabel.textAlignment = NSTextAlignmentLeft;
//    self.venueDetailLabel.numberOfLines = 0;
//    [self.venueDetailView addSubview:self.venueDetailLabel];
    
//    self.venueDescriptionLabel = [[UILabel alloc] init];
//    self.venueDescriptionLabel.font = [ThemeManager regularFontOfSize:13];
//    self.venueDescriptionLabel.textColor = [UIColor whiteColor];
////    self.venueDescriptionLabel.adjustsFontSizeToFitWidth = YES;
//    self.venueDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//    self.venueDescriptionLabel.numberOfLines = 0;
//    [self.venueDetailView addSubview:self.venueDescriptionLabel];
    
//    self.venueDetailDealHeadingLabel = [[UILabel alloc] init];
//    self.venueDetailDealHeadingLabel.font = [ThemeManager boldFontOfSize:13];
//    self.venueDetailDealHeadingLabel.textColor = [UIColor whiteColor];
//    self.venueDetailDealHeadingLabel.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.85];
//    self.venueDetailDealHeadingLabel.text = @"THE DEAL";
//    //self.venueDetailDealHeadingLabel.adjustsFontSizeToFitWidth = YES;
//    self.venueDetailDealHeadingLabel.textAlignment = NSTextAlignmentCenter;
//    self.venueDetailDealHeadingLabel.numberOfLines = 1;
//    [self.venueDetailView addSubview:self.venueDetailDealHeadingLabel];
//    
//    self.venueDetailDealFirstLineLabel = [[UILabel alloc] init];
//    self.venueDetailDealFirstLineLabel.font = [ThemeManager boldFontOfSize:14];
//    self.venueDetailDealFirstLineLabel.textColor = [UIColor whiteColor];
//    //self.venueDetailDealFirstLineLabel.adjustsFontSizeToFitWidth = YES;
//    self.venueDetailDealFirstLineLabel.textAlignment = NSTextAlignmentLeft;
//    self.venueDetailDealFirstLineLabel.numberOfLines = 1;
//    [self.venueDetailView addSubview:self.venueDetailDealFirstLineLabel];
//    
//    self.venueDetailDealSecondLineLabel = [[UILabel alloc] init];
//    self.venueDetailDealSecondLineLabel.font = [ThemeManager regularFontOfSize:12];
//    self.venueDetailDealSecondLineLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
////    self.venueDetailDealSecondLineLabel.adjustsFontSizeToFitWidth = YES;
//    self.venueDetailDealSecondLineLabel.textAlignment = NSTextAlignmentLeft;
//    self.venueDetailDealSecondLineLabel.numberOfLines = 0;
//    [self.venueDetailView addSubview:self.venueDetailDealSecondLineLabel];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager lightFontOfSize:14];
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.venuePreviewView addSubview:self.distanceLabel];
    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    //[self.venueScroll addSubview:self.venueDetailView];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followButton.size = CGSizeMake(65, 25);
    self.followButton.x = self.contentView.width - 85;
    self.followButton.y = 20;
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
    self.followButton.backgroundColor = [UIColor clearColor];
    self.followButton.titleLabel.textColor = [UIColor whiteColor];
    self.followButton.layer.cornerRadius = 4;
    self.followButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.followButton.layer.borderWidth = 1.0;
//    self.followButton.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
//    self.followButton.layer.borderWidth = 2;
//    self.followButton.layer.cornerRadius = 4;
//    [self.favoriteButton setImage:[UIImage imageNamed:@"unselectedFavorite"] forState:UIControlStateNormal];
    //self.redoSearchButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    //[self.redoSearchButton setTitle:@"REDO SEARCH IN AREA" forState:UIControlStateNormal];
    //self.inviteFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteFriendsButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    //self.inviteFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., chevronImage.size.width);
    //    self.redoSearchButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
    //    [self.redoSearchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [self.redoSearchButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.followButton addTarget:self action:@selector(followButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.venuePreviewView addSubview:self.followButton];
    
    
//    self.venueScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * 1, self.contentView.frame.size.height);
    [self.contentView addSubview:self.venuePreviewView];
    
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
//    [recognizer setNumberOfTapsRequired:1];
//    self.venueScroll.userInteractionEnabled = YES;
//    [self.venueScroll addGestureRecognizer:recognizer];
    //[self.venueScroll setUserInteractionEnabled:NO];
    //[self.contentView addGestureRecognizer:self.venueScroll.panGestureRecognizer];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.venueImageView.height = 146;
    self.venueImageView.width = self.width;
    
    self.venueLabelLineOne.width = self.width - 20;
    self.venueLabelLineOne.x = 5;
    self.venueLabelLineOne.height = 30;
    self.venueLabelLineOne.y = 35;
    
    self.venueLabelLineTwo.width = self.width - 20;
    self.venueLabelLineTwo.x = 4;
    self.venueLabelLineTwo.height = 46;
    self.venueLabelLineTwo.y = 49;
    
    self.dealTime.width = 200;
    self.dealTime.height = 20;
    self.dealTime.x = 8;
    self.dealTime.y=117;

    self.distanceLabel.size = CGSizeMake(67, 20);
    //self.distanceLabel.layer.cornerRadius = self.distanceLabel.width/2.0;
    //self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.textAlignment = NSTextAlignmentRight;
    self.distanceLabel.y = 117;
    self.distanceLabel.x = self.venuePreviewView.width - 77;
    //self.distanceLabel.centerX = self.venueDetailView.size.width - 33;
    
}

- (void)setVenue:(Venue *)venue
{
    _venue = venue;
    
    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.venue.name];
    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];

    [self.venueImageView sd_setImageWithURL:self.venue.imageURL];
    
    if (self.venue.deal) {
        NSString *emDash= [NSString stringWithUTF8String:"\xe2\x80\x94"];
        self.dealTime.text = [NSString stringWithFormat:@"%@ %@ %@", [self.venue.deal.dealStartString uppercaseString], emDash, [self stringForDistance:venue.distance]];
        NSString *marketPriceString = [NSString stringWithFormat:@"$%@", self.venue.deal.itemMarketPrice];
        self.marketPriceLabel.text = marketPriceString;
        NSDictionary* attributes = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.marketPriceLabel.text attributes:attributes];
        self.marketPriceLabel.attributedText = attrText;
        self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR", [venue.deal.itemName uppercaseString]];
        CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
        
        CGFloat descriptionLabelWidth;
        //if (textSize.width < self.contentView.width * .6) {
        descriptionLabelWidth = textSize.width;
        self.marketPriceLabel.x = descriptionLabelWidth + 3;
        CGSize marketLabelTextSize = [self.marketPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager regularFontOfSize:12]}];
    
        if (self.venue.deal.isRewardItem) {
            self.itemPriceLabel.text = [NSString stringWithFormat:@"FREE"];
            //self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
            self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] greenColor];
        } else {
            self.itemPriceLabel.text = [NSString stringWithFormat:@"$%@", venue.deal.itemPrice];
            self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
        }
        CGSize itemPriceTextSize = [self.itemPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14.5]}];
        self.itemPriceLabel.width = itemPriceTextSize.width;
        self.itemPriceLabel.x = self.marketPriceLabel.x + marketLabelTextSize.width + 3;
        
        self.descriptionLabel.width = descriptionLabelWidth + marketLabelTextSize.width + itemPriceTextSize.width + 10;
    }
    
    if (self.venue.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
    
}

- (NSString *)stringForDistance:(CLLocationDistance)distance
{
 //   CGFloat distanceMiles = METERS_TO_MILES*distance;
    NSString *distanceString;
//    if (distanceMiles < 0.25) {
//        distanceString = [NSString stringWithFormat:@"%0.0fft", (floor((METERS_TO_FEET*distance)/10))*10];
//    }
//    else {
        //distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
//    }
    distanceString = [NSString stringWithFormat:@"%0.1f mi", METERS_TO_MILES*distance];
    return distanceString;
}

- (void)getDirectionsToBeacon:(UIGestureRecognizer *)recognizer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Get Directions"];
    [actionSheet bk_addButtonWithTitle:@"Google Maps" handler:^{
        [Utilities launchGoogleMapsDirectionsToCoordinate:self.venue.coordinate addressDictionary:nil destinationName:self.venue.name];
    }];
    [actionSheet bk_addButtonWithTitle:@"Apple Maps" handler:^{
        [Utilities launchAppleMapsDirectionsToCoordinate:self.venue.coordinate addressDictionary:nil destinationName:self.venue.name];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Nevermind" handler:nil];
//    [actionSheet showInView:self.venueDetailView];
}

-(NSMutableDictionary *)parseStringIntoTwoLines:(NSString *)originalString
{
    NSMutableDictionary *firstAndSecondLine = [[NSMutableDictionary alloc] init];
    NSArray *arrayOfStrings = [originalString componentsSeparatedByString:@" "];
    if ([arrayOfStrings count] == 1) {
        [firstAndSecondLine setObject:@"" forKey:@"firstLine"];
        [firstAndSecondLine setObject:originalString forKey:@"secondLine"];
    } else {
        NSMutableString *firstLine = [[NSMutableString alloc] init];
        NSMutableString *secondLine = [[NSMutableString alloc] init];
        NSInteger firstLineCharCount = 0;
        for (int i = 0; i < [arrayOfStrings count]; i++) {
            if ((firstLineCharCount + [arrayOfStrings[i] length] < 12 && i + 1 != [arrayOfStrings count]) || i == 0) {
                if ([firstLine  length] == 0) {
                    [firstLine appendString:arrayOfStrings[i]];
                } else {
                    [firstLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
                firstLineCharCount = firstLineCharCount + [arrayOfStrings[i] length];
            } else {
                if ([secondLine length] == 0) {
                    [secondLine appendString:arrayOfStrings[i]];
                } else {
                    [secondLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
            }
        }
        [firstAndSecondLine setObject:firstLine forKey:@"firstLine"];
        [firstAndSecondLine setObject:secondLine forKey:@"secondLine"];
    }
    
    return firstAndSecondLine;
}

- (void)followButtonTouched:(id)sender
{
    
//    self.isFollowed = !self.isFollowed;
//    [self updateFavoriteButton];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];
    self.isFollowed = !self.isFollowed;
    [self updateFavoriteButton];
    
    [[APIClient sharedClient] toggleFavorite:self.venue.venueID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isFollowed = [responseObject[@"is_favorited"] boolValue];
        [self updateFavoriteButton];
    } failure:nil];
}

- (void) makeFollowButtonActive
{
    [self.followButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(85, 25);
    self.followButton.x = self.contentView.width - 95;
    //[self.followButton setTitleColor:[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] forState:UIControlStateNormal];
    //[self.followButton setTitleColor:[[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.layer.borderColor =[[ThemeManager sharedTheme] greenColor].CGColor;
    self.followButton.backgroundColor = [[ThemeManager sharedTheme] greenColor];
}

- (void) makeFollowButtonInactive
{
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(65, 25);
    self.followButton.x = self.contentView.width - 85;
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.followButton.layer.borderColor = [UIColor whiteColor].CGColor;
}


- (void) updateFavoriteButton
{
    if (self.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
}

@end