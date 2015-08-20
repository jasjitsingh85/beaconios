//
//  DealInfoView.m
//  Beacons
//
//  Created by Jasjit Singh on 7/3/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DealView.h"
#import "Deal.h"
#import "Beacon.h"
#import "DealStatus.h"
#import "Venue.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DealView()

@property (strong, nonatomic) UIView *backgroundDealView;

@end

@implementation DealView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
    [self addSubview:self.venueView];
    
    self.venueImageView  = [[UIImageView alloc]  initWithFrame:self.venueView.bounds];
    self.venueImageView.height = 103;
    self.venueImageView.width = self.width;
    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.venueImageView.clipsToBounds = YES;
    [self.venueView addSubview:self.venueImageView];
    
    //self.venuePreviewView = [[UIView alloc] initWithFrame:frame];
    self.backgroundDealView = [[UIView alloc] initWithFrame:self.venueView.bounds];
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
    [self.venueImageView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:34];
    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
    //self.venueLabelLineTwo.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineTwo.numberOfLines = 1;
    [self.venueImageView addSubview:self.venueLabelLineTwo];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:16 green:193 blue:255 alpha:255];
    //self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 26;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 90;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:14];
    //self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.venueImageView addSubview:self.descriptionLabel];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager regularFontOfSize:14];
    self.dealTime.textColor = [UIColor whiteColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venueImageView addSubview:self.dealTime];
    
    self.marketPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 90, 40, 26)];
    self.marketPriceLabel.textColor = [UIColor whiteColor];
    self.marketPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.marketPriceLabel.font = [ThemeManager regularFontOfSize:12];
    [self.venueImageView addSubview:self.marketPriceLabel];
    
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager lightFontOfSize:14];
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.venueImageView addSubview:self.distanceLabel];
    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    self.itemPriceLabel = [[UILabel alloc] init];
    self.itemPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.itemPriceLabel.font = [ThemeManager boldFontOfSize:14];
    self.itemPriceLabel.textColor = [UIColor whiteColor];
    self.itemPriceLabel.height = 26;
    self.itemPriceLabel.y = 90;
    [self.venueImageView addSubview:self.itemPriceLabel];
    
    return self;
}

- (void) setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    
    self.deal = self.beacon.deal;
    
    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.deal.venue.name];
    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    //self.venueLabelLineOne.text = [deal.itemName uppercaseString];
    //self.venueLabelLineTwo.text = [NSString stringWithFormat:@"FOR $%@", deal.itemPrice];
    
    //    self.venueDetailLabel.text = self.deal.dealDescriptionShort;
    [self.venueImageView sd_setImageWithURL:self.deal.venue.imageURL];
    //NSString *venueName = [NSString stringWithFormat:@"  @%@", [self.deal.venue.name uppercaseString]];
    
    NSString *marketPriceString = [NSString stringWithFormat:@"$%@", self.deal.itemMarketPrice];
    self.marketPriceLabel.text = marketPriceString;
    
    NSDictionary* attributes = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
    
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.marketPriceLabel.text attributes:attributes];
    self.marketPriceLabel.attributedText = attrText;
    
    self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR", [self.deal.itemName uppercaseString]];
    CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
    
    CGFloat descriptionLabelWidth;
    //if (textSize.width < self.contentView.width * .6) {
    descriptionLabelWidth = textSize.width;
    self.marketPriceLabel.x = descriptionLabelWidth + 3;
    CGSize marketLabelTextSize = [self.marketPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager regularFontOfSize:12]}];
    
    if (self.deal.isRewardItem || self.beacon.userDealStatus.isRewardAuthorization) {
        self.itemPriceLabel.text = [NSString stringWithFormat:@"FREE"];
        self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
    } else {
        self.itemPriceLabel.text = [NSString stringWithFormat:@"$%@", self.deal.itemPrice];
        self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:16 green:193 blue:255 alpha:255];
    }
    CGSize itemPriceTextSize = [self.itemPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14.5]}];
    self.itemPriceLabel.width = itemPriceTextSize.width;
    self.itemPriceLabel.x = self.marketPriceLabel.x + marketLabelTextSize.width + 3;
    
    
    //    } else {
    //        descriptionLabelWidth = self.contentView.width * .6;
    //    }
    
    //    float descriptionLabelWidth = [venueName boundingRectWithSize:self.descriptionLabel.frame.size
    //                                                                           options:NSStringDrawingUsesLineFragmentOrigin
    //                                                                        attributes:@{ NSFontAttributeName:[ThemeManager boldFontOfSize:16] }
    //                                                                           context:nil].size.width;
    
    //self.dealTime.x = descriptionLabelWidth + 15;
    
    self.descriptionLabel.width = descriptionLabelWidth + marketLabelTextSize.width + itemPriceTextSize.width + 10;
    
    //    self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR       $%@", [deal.itemName uppercaseString], deal.itemPrice];
    //    CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
    //
    //    CGFloat descriptionLabelWidth;
    //    //if (textSize.width < self.contentView.width * .6) {
    //    descriptionLabelWidth = textSize.width;
    //    } else {
    //        descriptionLabelWidth = self.contentView.width * .6;
    //    }
    
    //    float descriptionLabelWidth = [venueName boundingRectWithSize:self.descriptionLabel.frame.size
    //                                                                           options:NSStringDrawingUsesLineFragmentOrigin
    //                                                                        attributes:@{ NSFontAttributeName:[ThemeManager boldFontOfSize:16] }
    //                                                                           context:nil].size.width;
    
    //self.dealTime.x = descriptionLabelWidth + 15;
    
    //    self.descriptionLabel.width = descriptionLabelWidth + 10;
    //self.venueDescriptionLabel.text = self.deal.venue.placeDescription;
    //self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
    //    self.venueDetailDealFirstLineLabel.text = self.deal.dealDescription;
    //    self.venueDetailDealSecondLineLabel.text = self.deal.additionalInfo;
    //self.venueDetailDealSecondLineLabel.text = @"Well, Beer, and Wine only";
    //    self.venueDescriptionLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.deal.venue.placeDescription, [self stringForDistance:deal.venue.distance]];
    NSString *emDash= [NSString stringWithUTF8String:"\xe2\x80\x94"];
    //    self.priceLabel.text = [NSString stringWithFormat:@"$%@", self.deal.itemPrice];
    self.dealTime.text = [NSString stringWithFormat:@"%@", [self.deal.dealStartString uppercaseString]];
    //    self.marketPriceLabel.text = [NSString stringWithFormat:@"$%@", self.deal.itemMarketPrice];
    //
    //    NSDictionary* attributes = @{
    //                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
    //                                 };
    //
    //    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.marketPriceLabel.text attributes:attributes];
    //    self.marketPriceLabel.attributedText = attrText;
    //
    //    self.marketPriceLabel.x = self.descriptionLabel.width - 60;
    
}

- (void) setDeal:(Deal *)deal
{
    _deal = deal;
    
    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.deal.venue.name];
    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    //self.venueLabelLineOne.text = [deal.itemName uppercaseString];
    //self.venueLabelLineTwo.text = [NSString stringWithFormat:@"FOR $%@", deal.itemPrice];
    
    //    self.venueDetailLabel.text = self.deal.dealDescriptionShort;
    [self.venueImageView sd_setImageWithURL:self.deal.venue.imageURL];
    //NSString *venueName = [NSString stringWithFormat:@"  @%@", [self.deal.venue.name uppercaseString]];
    
    NSString *marketPriceString = [NSString stringWithFormat:@"$%@", self.deal.itemMarketPrice];
    self.marketPriceLabel.text = marketPriceString;
    
    NSDictionary* attributes = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
    
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.marketPriceLabel.text attributes:attributes];
    self.marketPriceLabel.attributedText = attrText;
    
    self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR", [deal.itemName uppercaseString]];
    CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
    
    CGFloat descriptionLabelWidth;
    //if (textSize.width < self.contentView.width * .6) {
    descriptionLabelWidth = textSize.width;
    self.marketPriceLabel.x = descriptionLabelWidth + 3;
    CGSize marketLabelTextSize = [self.marketPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager regularFontOfSize:12]}];
    
    if (deal.isRewardItem) {
        self.itemPriceLabel.text = [NSString stringWithFormat:@"FREE"];
        self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
    } else {
        self.itemPriceLabel.text = [NSString stringWithFormat:@"$%@", deal.itemPrice];
        self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:16 green:193 blue:255 alpha:255];
    }
    CGSize itemPriceTextSize = [self.itemPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14.5]}];
    self.itemPriceLabel.width = itemPriceTextSize.width;
    self.itemPriceLabel.x = self.marketPriceLabel.x + marketLabelTextSize.width + 3;
    
    
    //    } else {
    //        descriptionLabelWidth = self.contentView.width * .6;
    //    }
    
    //    float descriptionLabelWidth = [venueName boundingRectWithSize:self.descriptionLabel.frame.size
    //                                                                           options:NSStringDrawingUsesLineFragmentOrigin
    //                                                                        attributes:@{ NSFontAttributeName:[ThemeManager boldFontOfSize:16] }
    //                                                                           context:nil].size.width;
    
    //self.dealTime.x = descriptionLabelWidth + 15;
    
    self.descriptionLabel.width = descriptionLabelWidth + marketLabelTextSize.width + itemPriceTextSize.width + 10;
    
//    self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR       $%@", [deal.itemName uppercaseString], deal.itemPrice];
//    CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
//    
//    CGFloat descriptionLabelWidth;
//    //if (textSize.width < self.contentView.width * .6) {
//    descriptionLabelWidth = textSize.width;
    //    } else {
    //        descriptionLabelWidth = self.contentView.width * .6;
    //    }
    
    //    float descriptionLabelWidth = [venueName boundingRectWithSize:self.descriptionLabel.frame.size
    //                                                                           options:NSStringDrawingUsesLineFragmentOrigin
    //                                                                        attributes:@{ NSFontAttributeName:[ThemeManager boldFontOfSize:16] }
    //                                                                           context:nil].size.width;
    
    //self.dealTime.x = descriptionLabelWidth + 15;
    
//    self.descriptionLabel.width = descriptionLabelWidth + 10;
    //self.venueDescriptionLabel.text = self.deal.venue.placeDescription;
    //self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
    //    self.venueDetailDealFirstLineLabel.text = self.deal.dealDescription;
    //    self.venueDetailDealSecondLineLabel.text = self.deal.additionalInfo;
    //self.venueDetailDealSecondLineLabel.text = @"Well, Beer, and Wine only";
    //    self.venueDescriptionLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.deal.venue.placeDescription, [self stringForDistance:deal.venue.distance]];
    NSString *emDash= [NSString stringWithUTF8String:"\xe2\x80\x94"];
    //    self.priceLabel.text = [NSString stringWithFormat:@"$%@", self.deal.itemPrice];
    self.dealTime.text = [NSString stringWithFormat:@"%@", [self.deal.dealStartString uppercaseString]];
//    self.marketPriceLabel.text = [NSString stringWithFormat:@"$%@", self.deal.itemMarketPrice];
//    
//    NSDictionary* attributes = @{
//                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
//                                 };
//    
//    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.marketPriceLabel.text attributes:attributes];
//    self.marketPriceLabel.attributedText = attrText;
//    
//    self.marketPriceLabel.x = self.descriptionLabel.width - 60;
    
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
    self.distanceLabel.x = self.venueImageView.width - 77;
    //self.distanceLabel.centerX = self.venueDetailView.size.width - 33;
    
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

@end