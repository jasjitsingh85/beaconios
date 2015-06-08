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
    
    self.backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 140, self.venueImageView.size.width, 60)];
    UIImage *gradientImage = [UIImage imageNamed:@"backgroundGradient@2x.png"];
    [self.backgroundGradient setImage:gradientImage];
    [self.venueImageView addSubview:self.backgroundGradient];
    
    self.venueScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 196)];
    self.venueScroll.pagingEnabled = YES;
    self.venueScroll.showsHorizontalScrollIndicator = NO;

    CGFloat originForVenuePreview = 0;
    self.venuePreviewView = [[UIView alloc] initWithFrame:CGRectMake(originForVenuePreview, 0, self.contentView.frame.size.width, 196)];
    self.backgroundView = [[UIView alloc] initWithFrame:self.venueImageView.bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.venuePreviewView addSubview:self.backgroundView];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:30];
    self.venueLabelLineOne.textColor = [UIColor whiteColor];
    //self.venueLabelLineOne.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.venuePreviewView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:46];
    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
    //self.venueLabelLineTwo.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineTwo.numberOfLines = 1;
    [self.venuePreviewView addSubview:self.venueLabelLineTwo];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9];
    self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 30;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 145;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:16];
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.venuePreviewView addSubview:self.descriptionLabel];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager boldFontOfSize:16];
    self.dealTime.textColor = [UIColor whiteColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venuePreviewView addSubview:self.dealTime];
    
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
    [self.venueScroll addSubview:self.venuePreviewView];
    
    CGFloat originForVenueDetail = self.contentView.frame.size.width;
    self.venueDetailView = [[UIView alloc] initWithFrame:CGRectMake(originForVenueDetail, 0, self.contentView.frame.size.width, 196)];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.venueDetailView.bounds];
    [self.venueDetailView addSubview:blurEffectView];
    
//    UIVibrancyEffect *vibrance = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//    UIVisualEffectView *vibranceEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrance];
//    [vibranceEffectView setFrame:self.venueDetailView.bounds];
//    [blurEffectView addSubview:vibranceEffectView];
    
    //self.venueDetailView.backgroundColor = [UIColor colorWithRed:23/255.f green:10/255.f blue:1/255.f alpha:.75];
    
    self.venueDetailLabel = [[UILabel alloc] init];
    self.venueDetailLabel.font = [ThemeManager boldFontOfSize:24];
    self.venueDetailLabel.textColor = [UIColor whiteColor];
//    self.venueDetailLabel.adjustsFontSizeToFitWidth = YES;
//    [self.venueDetailLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueDetailLabel.textAlignment = NSTextAlignmentLeft;
    self.venueDetailLabel.numberOfLines = 0;
    [self.venueDetailView addSubview:self.venueDetailLabel];
    
//    self.venueDescriptionLabel = [[UILabel alloc] init];
//    self.venueDescriptionLabel.font = [ThemeManager regularFontOfSize:13];
//    self.venueDescriptionLabel.textColor = [UIColor whiteColor];
////    self.venueDescriptionLabel.adjustsFontSizeToFitWidth = YES;
//    self.venueDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//    self.venueDescriptionLabel.numberOfLines = 0;
//    [self.venueDetailView addSubview:self.venueDescriptionLabel];
    
    self.venueDetailDealHeadingLabel = [[UILabel alloc] init];
    self.venueDetailDealHeadingLabel.font = [ThemeManager boldFontOfSize:13];
    self.venueDetailDealHeadingLabel.textColor = [UIColor whiteColor];
    self.venueDetailDealHeadingLabel.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.85];
    self.venueDetailDealHeadingLabel.text = @"THE DEAL";
    //self.venueDetailDealHeadingLabel.adjustsFontSizeToFitWidth = YES;
    self.venueDetailDealHeadingLabel.textAlignment = NSTextAlignmentCenter;
    self.venueDetailDealHeadingLabel.numberOfLines = 1;
    [self.venueDetailView addSubview:self.venueDetailDealHeadingLabel];
    
    self.venueDetailDealFirstLineLabel = [[UILabel alloc] init];
    self.venueDetailDealFirstLineLabel.font = [ThemeManager boldFontOfSize:14];
    self.venueDetailDealFirstLineLabel.textColor = [UIColor whiteColor];
    //self.venueDetailDealFirstLineLabel.adjustsFontSizeToFitWidth = YES;
    self.venueDetailDealFirstLineLabel.textAlignment = NSTextAlignmentLeft;
    self.venueDetailDealFirstLineLabel.numberOfLines = 1;
    [self.venueDetailView addSubview:self.venueDetailDealFirstLineLabel];
    
    self.venueDetailDealSecondLineLabel = [[UILabel alloc] init];
    self.venueDetailDealSecondLineLabel.font = [ThemeManager regularFontOfSize:12];
    self.venueDetailDealSecondLineLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
//    self.venueDetailDealSecondLineLabel.adjustsFontSizeToFitWidth = YES;
    self.venueDetailDealSecondLineLabel.textAlignment = NSTextAlignmentLeft;
    self.venueDetailDealSecondLineLabel.numberOfLines = 0;
    [self.venueDetailView addSubview:self.venueDetailDealSecondLineLabel];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager boldFontOfSize:14];
    self.distanceLabel.textColor = [UIColor whiteColor];
    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    //[self.venueScroll addSubview:self.venueDetailView];
    
    
    self.venueScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * 1, self.contentView.frame.size.height);
    [self.contentView addSubview:self.venueScroll];
    
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
    
    self.venueImageView.height = 196;
    self.venueImageView.width = self.width;
    
    self.venueLabelLineOne.width = self.width - 20;
    self.venueLabelLineOne.x = 5;
    self.venueLabelLineOne.height = 30;
    self.venueLabelLineOne.y = 75;
    
    self.venueLabelLineTwo.width = self.width - 20;
    self.venueLabelLineTwo.x = 4;
    self.venueLabelLineTwo.height = 46;
    self.venueLabelLineTwo.y = 98;
    
    self.venueDetailLabel.width = self.venueDetailView.size.width * .65;
    self.venueDetailLabel.x = 10;
    self.venueDetailLabel.height = 58;
    self.venueDetailLabel.y = 20;
    
    self.venueDescriptionLabel.width = .6 * self.venueDetailView.width;
    self.venueDescriptionLabel.x = 20;
    self.venueDescriptionLabel.height = 33;
    self.venueDescriptionLabel.y = 60;
    
    self.venueDetailDealHeadingLabel.width = 120;
    self.venueDetailDealHeadingLabel.x = 0;
    self.venueDetailDealHeadingLabel.height = 24;
    self.venueDetailDealHeadingLabel.y = 90;
    
    self.venueDetailDealFirstLineLabel.width = self.venueDetailView.width - 20;
    self.venueDetailDealFirstLineLabel.x = 10;
    self.venueDetailDealFirstLineLabel.height = 40;
    self.venueDetailDealFirstLineLabel.y = 120;
    
    self.venueDetailDealSecondLineLabel.width = self.venueDetailView.width - 20;
    self.venueDetailDealSecondLineLabel.x = 10;
    self.venueDetailDealSecondLineLabel.height = 16;
    self.venueDetailDealSecondLineLabel.y = 150;
    
    self.dealTime.width = 200;
    self.dealTime.height = 30;
    //self.dealTime.x = self.venuePreviewView.size.width*.62;
    self.dealTime.y=145;
    
    
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

- (void)setDeal:(Deal *)deal
{
    _deal = deal;
    
    if (deal.inAppPayment) {
        self.venueLabelLineOne.text = [deal.itemName uppercaseString];
        self.venueLabelLineTwo.text = [NSString stringWithFormat:@"FOR $%@", deal.itemPrice];
    } else {
        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.deal.dealDescriptionShort];
        self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
        self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    }
    
    self.venueDetailLabel.text = self.deal.dealDescriptionShort;
    [self.venueImageView sd_setImageWithURL:self.deal.venue.imageURL];
    self.descriptionLabel.text = [NSString stringWithFormat:@"  @%@", [self.deal.venue.name uppercaseString]];
    float descriptionLabelWidth = [self.descriptionLabel.text boundingRectWithSize:self.descriptionLabel.frame.size
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{ NSFontAttributeName:self.descriptionLabel.font }
                                                                           context:nil]
    .size.width;

    self.dealTime.x = descriptionLabelWidth + 10;
    
    self.descriptionLabel.width = descriptionLabelWidth + 5;
    //self.venueDescriptionLabel.text = self.deal.venue.placeDescription;
    //self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
    self.venueDetailDealFirstLineLabel.text = self.deal.dealDescription;
    self.venueDetailDealSecondLineLabel.text = self.deal.additionalInfo;
    //self.venueDetailDealSecondLineLabel.text = @"Well, Beer, and Wine only";
    self.venueDescriptionLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.deal.venue.placeDescription, [self stringForDistance:deal.venue.distance]];
    self.dealTime.text = [self.deal.dealStartString uppercaseString];
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

- (void)getDirectionsToBeacon:(UIGestureRecognizer *)recognizer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Get Directions"];
    [actionSheet bk_addButtonWithTitle:@"Google Maps" handler:^{
        [Utilities launchGoogleMapsDirectionsToCoordinate:self.deal.venue.coordinate addressDictionary:nil destinationName:self.deal.venue.name];
    }];
    [actionSheet bk_addButtonWithTitle:@"Apple Maps" handler:^{
        [Utilities launchAppleMapsDirectionsToCoordinate:self.deal.venue.coordinate addressDictionary:nil destinationName:self.deal.venue.name];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Nevermind" handler:nil];
    [actionSheet showInView:self.venueDetailView];
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

@end