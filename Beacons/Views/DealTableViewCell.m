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
    //self.backgroundDealView = [[UIView alloc] initWithFrame:self.venuePreviewView.bounds];
//    self.backgroundDealView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    //self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //[self.venueImageView addSubview:self.backgroundDealView];
    
    self.backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.venueImageView.size.width, 146)];
    UIImage *gradientImage = [UIImage imageNamed:@"updatedBackgroundGradient@2x.png"];
    [self.backgroundGradient setImage:gradientImage];
    [self.venueImageView addSubview:self.backgroundGradient];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    //self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:20];
    self.venueLabelLineOne.font = [ThemeManager lightFontOfSize:26];
    self.venueLabelLineOne.textColor = [UIColor whiteColor];
    //self.venueLabelLineOne.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.venuePreviewView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    //self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:34];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:26];
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
    self.dealTime.font = [ThemeManager regularFontOfSize:12];
    self.dealTime.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venuePreviewView addSubview:self.dealTime];
    
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
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager lightFontOfSize:14];
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.venuePreviewView addSubview:self.distanceLabel];
    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    //[self.venueScroll addSubview:self.venueDetailView];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followButton.size = CGSizeMake(65, 25);
    self.followButton.x = self.contentView.width - 85;
    self.followButton.y = 10;
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
    self.followButton.backgroundColor = [UIColor clearColor];
    self.followButton.titleLabel.textColor = [UIColor whiteColor];
    self.followButton.layer.cornerRadius = 4;
    self.followButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.followButton.layer.borderWidth = 1.0;
    [self.followButton addTarget:self action:@selector(followButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.venuePreviewView addSubview:self.followButton];
    
    self.placeType = [[UILabel alloc] initWithFrame:CGRectMake(145, 69, self.contentView.width, 20)];
    self.placeType.font = [ThemeManager regularFontOfSize:12];
    self.placeType.textAlignment = NSTextAlignmentLeft;
    self.placeType.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    [self.venuePreviewView addSubview:self.placeType];
    
    [self.contentView addSubview:self.venuePreviewView];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.venueImageView.width = self.width;
    
    self.venueLabelLineOne.width = self.width - 20;
    self.venueLabelLineOne.x = 4;
    self.venueLabelLineOne.height = 30;
    
    self.venueLabelLineTwo.width = self.width - 20;
    self.venueLabelLineTwo.x = 5;
    self.venueLabelLineTwo.height = 46;
    //self.venueLabelLineTwo.height = 30;
    
    self.dealTime.width = self.width;
    self.dealTime.height = 20;
    self.dealTime.x = 8;

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
    
//    CGSize lineTwoTextSize = [self.venueLabelLineTwo.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:34]}];
    
    CGSize lineTwoTextSize = [self.venueLabelLineTwo.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:26]}];
    
    [self.venueImageView sd_setImageWithURL:self.venue.imageURL];
    
    NSString *emDash= [NSString stringWithUTF8String:"\xe2\x80\x94"];
    
    if (self.venue.deal) {
        self.venueImageView.height = 146;
        self.backgroundGradient.height = 146;
        if (self.venue.neighborhood != (NSString *)[NSNull null]) {
            self.dealTime.text = [NSString stringWithFormat:@"%@ %@ %@ | %@", [self.venue.deal.dealStartString uppercaseString], emDash, [self.venue.neighborhood uppercaseString],[self stringForDistance:venue.distance]];
        } else {
            self.dealTime.text = [NSString stringWithFormat:@"%@ %@ %@", [self.venue.deal.dealStartString uppercaseString], emDash, [self stringForDistance:venue.distance]];
        }
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
        
        //self.venueLabelLineOne.y = 35;
        //self.venueLabelLineTwo.y = 49;
        self.venueLabelLineOne.y = 38;
        self.venueLabelLineTwo.y = 52;
        
        self.placeType.y = 70.5;
        self.dealTime.y = 117;
        
    } else {
        self.venuePreviewView.height = 96;
        self.venueImageView.height = 96;
        self.backgroundGradient.height = 96;
        
//        self.venueLabelLineOne.y = 20;
//        self.venueLabelLineTwo.y = 34;
        self.venueLabelLineOne.y = 23;
        self.venueLabelLineTwo.y = 37;
        
        self.placeType.y = 55.5;
        self.dealTime.y = 73;
        
        if (self.venue.neighborhood != (NSString *)[NSNull null]) {
            self.dealTime.text = [NSString stringWithFormat:@"%@ | %@", [self.venue.neighborhood uppercaseString],[self stringForDistance:venue.distance]];
        } else {
            self.dealTime.text = [NSString stringWithFormat:@"%@", [self stringForDistance:venue.distance]];
        }
    }
    if (!isEmpty(venue.placeType)) {
         self.placeType.text = [venue.placeType uppercaseString];   
    }
    
    if (self.venue.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
    
    self.placeType.x = self.venueLabelLineTwo.x + lineTwoTextSize.width + 6;
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAfterToggleFavoriteNotification object:self];
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
    self.followButton.size = CGSizeMake(80, 25);
    self.followButton.x = self.contentView.width - 90;
    //[self.followButton setTitleColor:[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] forState:UIControlStateNormal];
    //[self.followButton setTitleColor:[[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.followButton.backgroundColor = [[ThemeManager sharedTheme] greenColor];
}

- (void) makeFollowButtonInactive
{
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(60, 25);
    self.followButton.x = self.contentView.width - 70;
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