//
//  HappyHourTableViewCell.m
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//


#import "HappyHourTableViewCell.h"
#import <MapKit/MapKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#include <tgmath.h>
#import "Utilities.h"
#import "UIView+Shadow.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "HappyHourVenue.h"
#import <QuartzCore/QuartzCore.h>
#import "DealHours.h"

@interface HappyHourTableViewCell()

@end

@implementation HappyHourTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
//    self.venueImageView = [[UIImageView alloc] init];
//    self.venueImageView.height = 153;
//    self.venueImageView.width = self.width;
//    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.venueImageView.clipsToBounds = YES;
//    [self.contentView addSubview:self.venueImageView];
    
    self.backgroundCellView = [[UIView alloc] init];
    self.backgroundCellView.height = 106;
//    self.backgroundCellView.backgroundColor = [UIColor colorWithWhite:230/255.0 alpha:.5];
    self.backgroundCellView.width = self.width;
    [self.contentView addSubview:self.backgroundCellView];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.backgroundCellView.frame];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.backgroundCellView addSubview:self.backgroundImageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.backgroundImageView.bounds];
    [self.backgroundImageView addSubview:blurEffectView];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:20];
    self.venueLabelLineOne.textColor = [UIColor whiteColor];
    //self.venueLabelLineOne.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.backgroundCellView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:30];
    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
    //self.venueLabelLineTwo.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineTwo.numberOfLines = 1;
    [self.backgroundCellView addSubview:self.venueLabelLineTwo];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.backgroundColor = [[UIColor unnormalizedColorWithRed:108 green:56 blue:233 alpha:255] colorWithAlphaComponent:0.9];
//    self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] brownColor];
//    self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 30;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 65;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:16];
    //self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.backgroundCellView addSubview:self.descriptionLabel];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager boldFontOfSize:16];
    self.dealTime.textColor = [UIColor whiteColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.backgroundCellView addSubview:self.dealTime];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager boldFontOfSize:14];
    self.distanceLabel.textColor = [UIColor whiteColor];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.venueImageView.height = 196;
//    self.venueImageView.width = self.width;
    
    self.venueLabelLineOne.width = self.width - 20;
    self.venueLabelLineOne.x = 5;
    self.venueLabelLineOne.height = 30;
    self.venueLabelLineOne.y = 32;
    
    self.venueLabelLineTwo.width = self.width - 20;
    self.venueLabelLineTwo.x = 4;
    self.venueLabelLineTwo.height = 46;
    self.venueLabelLineTwo.y = 25;
    
//    self.venueDetailLabel.width = self.venueDetailView.size.width * .60;
//    self.venueDetailLabel.x = 10;
//    self.venueDetailLabel.height = 58;
//    self.venueDetailLabel.y = 20;
    
//    self.venueDescriptionLabel.width = .6 * self.venueDetailView.width;
//    self.venueDescriptionLabel.x = 20;
//    self.venueDescriptionLabel.height = 33;
//    self.venueDescriptionLabel.y = 60;
    
//    self.venueDetailDealHeadingLabel.width = 120;
//    self.venueDetailDealHeadingLabel.x = 0;
//    self.venueDetailDealHeadingLabel.height = 24;
//    self.venueDetailDealHeadingLabel.y = 90;
//    
//    self.venueDetailDealFirstLineLabel.width = self.venueDetailView.width - 20;
//    self.venueDetailDealFirstLineLabel.x = 10;
//    self.venueDetailDealFirstLineLabel.height = 40;
//    self.venueDetailDealFirstLineLabel.y = 120;
//    
//    self.venueDetailDealSecondLineLabel.width = self.venueDetailView.width - 20;
//    self.venueDetailDealSecondLineLabel.x = 10;
//    self.venueDetailDealSecondLineLabel.height = 16;
//    self.venueDetailDealSecondLineLabel.y = 150;
    
    self.dealTime.width = 200;
    self.dealTime.height = 30;
    //self.dealTime.x = self.venuePreviewView.size.width*.62;
    self.dealTime.y=65;
    
    
    //    self.venueDescriptionBackground.width = self.width;
    //    self.venueDescriptionBackground.height = 37;
    //    self.venueDescriptionBackground.y = self.venueImageView.bottom;
    //    self.venueDescriptionLabel.width = self.venueDescriptionBackground.width - 40;
    //    self.venueDescriptionLabel.height = self.venueDescriptionBackground.height;
    //    self.venueDescriptionLabel.centerX = self.venueDescriptionBackground.width/2.0;
    //    [self.venueDescriptionBackground setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    
    self.distanceLabel.size = CGSizeMake(37, 37);
    self.distanceLabel.layer.cornerRadius = self.distanceLabel.width/2.0;
    self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.textAlignment = NSTextAlignmentCenter;
    self.distanceLabel.y = 37;
    self.distanceLabel.centerX = self.venueDetailView.size.width - 33;
    
}

- (void)setHappyHour:(HappyHour *)happyHour
{
    
    _happyHour = happyHour;
    
//    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:@"HAPPY HOUR"];
//    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
//    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    
    self.venueLabelLineTwo.text = @"HAPPY HOUR";
    
    NSLog(@"%@", self.happyHour.happyHourDescription);
    self.venueDetailLabel.text = self.happyHour.happyHourDescription;
    //[self.venueImageView sd_setImageWithURL:self.happyHour.venue.imageURL];
    NSLog(@"%@", self.happyHour.venue.name);
    self.descriptionLabel.text = [NSString stringWithFormat:@"  @%@", [self.happyHour.venue.name uppercaseString]];
//    float descriptionLabelWidth = [self.descriptionLabel.text boundingRectWithSize:self.descriptionLabel.frame.size
//                                                                           options:NSStringDrawingUsesLineFragmentOrigin
//                                                                        attributes:@{ NSFontAttributeName:self.descriptionLabel.font }
//                                                                           context:nil]
//    .size.width;
    
    CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:16]}];
    
    CGFloat descriptionLabelWidth;
    if (textSize.width < self.contentView.width * .60) {
        descriptionLabelWidth = textSize.width;
    } else {
        descriptionLabelWidth = self.contentView.width * .60;
    }
    
    [self.backgroundImageView sd_setImageWithURL:self.happyHour.venue.imageURL];
    
    self.dealTime.x = descriptionLabelWidth + 10;
    
    self.descriptionLabel.width = descriptionLabelWidth + 5;
    //self.venueDescriptionLabel.text = self.deal.venue.placeDescription;
    //self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
    self.venueDetailDealFirstLineLabel.text = self.happyHour.happyHourDescription;
    //self.venueDetailDealSecondLineLabel.text = self.deal.additionalInfo;
    //self.venueDetailDealSecondLineLabel.text = @"Well, Beer, and Wine only";
    //self.venueDescriptionLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.deal.venue.placeDescription, [self stringForDistance:deal.venue.distance]];
    NSLog(@"DEAL TIME: %@", [self.happyHour.happyHourStartString uppercaseString]);
    self.dealTime.text = [self.happyHour.happyHourStartString uppercaseString];
//    if ([self.dealTime.text isEqualToString:@"NOW"]) {
//        self.dealTime.textColor = [UIColor unnormalizedColorWithRed:57 green:190 blue:111 alpha:255];
//    }
    
    //self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,80,80)];
    
    
    //    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    //    //    MKCoordinateSpan span;
    //    //    //You can set span for how much Zoom to be display
    //    //    span.latitudeDelta=.15;
    //    //    span.longitudeDelta=.15;
    //
    //    options.region = MKCoordinateRegionMakeWithDistance(self.deal.venue.coordinate, 700, 700);
    //    options.scale = [UIScreen mainScreen].scale;
    //    options.size = CGSizeMake(120, 120);
    
    //self.mapSnapshot = [[MKMapSnapshotter alloc] initWithOptions:options];
    //[self.mapSnapshot startWithCompletionHandler:^(MKMapSnapshot *mapSnap, NSError *error) {
    //self.mapSnapshotImage = mapSnap.image;
    //UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(self.venueDetailView.width - 55, 25, 120, 120)];
    //UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.venuePreviewView.width - 45, 15, 22, 30)];
    //[mapImageView setImage:mapSnap.image];
    //[mapImageView setImage:[UIImage imageNamed:@"mapMarker"]];
    //CALayer *imageLayer = mapImageView.layer;
    //[imageLayer setCornerRadius:mapView.size.width/2];
    //[imageLayer setBorderWidth:3];
    //[imageLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    //[imageLayer setBorderColor:[[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9] CGColor]];
    //[imageLayer setMasksToBounds:YES];
    
    //UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((mapImageView.frame.size.width/2) - 15, (mapImageView.frame.size.height/2) - 15, 30, 30)];
    //UIImage *markerImage = [UIImage imageNamed:@"marker"];
    //[markerImageView setImage:markerImage];
    //[mapImageView addSubview:markerImageView];
    
    //[mapImageView setUserInteractionEnabled:YES];
    //UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon:)];
    //[singleTap setNumberOfTapsRequired:1];
    //[mapImageView addGestureRecognizer:singleTap];
    
    //[mapView addSubview:mapImageView];
    //[self.venuePreviewView addSubview:mapImageView];
    //[self.venuePreviewView addSubview:self.distanceLabel];
    // }];
    
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

//- (void)getDirectionsToBeacon:(UIGestureRecognizer *)recognizer
//{
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Get Directions"];
//    [actionSheet bk_addButtonWithTitle:@"Google Maps" handler:^{
//        [Utilities launchGoogleMapsDirectionsToCoordinate:self.deal.venue.coordinate addressDictionary:nil destinationName:self.deal.venue.name];
//    }];
//    [actionSheet bk_addButtonWithTitle:@"Apple Maps" handler:^{
//        [Utilities launchAppleMapsDirectionsToCoordinate:self.deal.venue.coordinate addressDictionary:nil destinationName:self.deal.venue.name];
//    }];
//    [actionSheet bk_setCancelButtonWithTitle:@"Nevermind" handler:nil];
//    [actionSheet showInView:self.venueDetailView];
//}

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

@end
