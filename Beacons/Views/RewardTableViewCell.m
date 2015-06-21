
//
//  RewardTableViewCell.m
//  Beacons
//
//  Created by Jasjit Singh on 5/12/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "RewardTableViewCell.h"
#import <MapKit/MapKit.h>
#import "RewardManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#include <tgmath.h>
#import "Utilities.h"
#import "UIView+Shadow.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "Venue.h"
#import <QuartzCore/QuartzCore.h>
#import "DealHours.h"
#import "Deal.h"
#import "RewardManager.h"

@interface RewardTableViewCell()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *priceContainer;
@property (strong, nonatomic) UILabel *priceLabel;

@end

@implementation RewardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.venueImageView = [[UIImageView alloc] init];
    self.venueImageView.height = 146;
    self.venueImageView.width = self.width;
    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.venueImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.venueImageView];
    
//    self.backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 140, self.venueImageView.size.width, 60)];
//    UIImage *gradientImage = [UIImage imageNamed:@"backgroundGradient@2x.png"];
//    [self.backgroundGradient setImage:gradientImage];
//    [self.venueImageView addSubview:self.backgroundGradient];
    
    CGFloat originForVenuePreview = 0;
    self.venuePreviewView = [[UIView alloc] initWithFrame:CGRectMake(originForVenuePreview, 0, self.contentView.frame.size.width, 110)];
    //self.backgroundView = [[UIView alloc] initWithFrame:self.venuePreviewView.bounds];
    //self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.venuePreviewView addSubview:self.backgroundView];
    
    UIImageView *backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 87, self.contentView.size.width, 60)];
    UIImage *gradientImage = [UIImage imageNamed:@"backgroundGradient@2x.png"];
    [backgroundGradient setImage:gradientImage];
    [self.venuePreviewView addSubview:backgroundGradient];
    
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
    self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
    self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 25;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 90;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:13];
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager lightFontOfSize:16];
    self.dealTime.textColor = [UIColor blackColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venuePreviewView addSubview:self.dealTime];
    
    self.redeemRewardButton = [[UIButton alloc] init];
    self.redeemRewardButton.frame = CGRectMake(self.venuePreviewView.size.width - 80, 45, 70, 30);
    [self.redeemRewardButton setBackgroundImage:[UIImage imageNamed:@"goldCoinWithBackground"] forState:UIControlStateNormal];
    //self.redeemRewardButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    self.redeemRewardButton.layer.cornerRadius = 4;
    //[self.redeemRewardButton setTitle:@"" forState:UIControlStateNormal];
    [self.redeemRewardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redeemRewardButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10.0)];
    self.redeemRewardButton.titleLabel.font = [ThemeManager mediumFontOfSize:16];
    [self.redeemRewardButton addTarget:self action:@selector(redeemRewardButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.venuePreviewView];

    
//    self.distanceLabel = [[UILabel alloc] init];
//    self.distanceLabel.font = [ThemeManager boldFontOfSize:14];
//    self.distanceLabel.textColor = [UIColor blackColor];
//    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
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
    self.venueLabelLineOne.y = 35;
    
    self.venueLabelLineTwo.width = self.width - 20;
    self.venueLabelLineTwo.x = 4;
    self.venueLabelLineTwo.height = 46;
    self.venueLabelLineTwo.y = 49;
    
//    self.dealTime.width = 200;
//    self.dealTime.height = 20;
//    self.dealTime.x = 8;
//    self.dealTime.y=117;
    
    
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
    self.distanceLabel.centerX = self.venuePreviewView.size.width - 33;
    
}

- (void)setDeal:(Deal *)deal
{
    _deal = deal;
    
    if (deal == nil) {
        [self.venueImageView setImage:[UIImage imageNamed:@"storeIntroCell"]];
        self.venueImageView.height = 110;
    } else {
        //[self.venuePreviewView addSubview:self.redeemRewardButton];
        [self.venuePreviewView addSubview:self.descriptionLabel];
        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.deal.venue.name];
        self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
        self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
        [self.venueImageView sd_setImageWithURL:self.deal.venue.imageURL];
        [self.redeemRewardButton setTitle:[NSString stringWithFormat:@"%@", self.deal.itemPointCost] forState:UIControlStateNormal];
        self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR FREE",[self.deal.itemName uppercaseString]];
        float descriptionLabelWidth = [self.descriptionLabel.text boundingRectWithSize:self.descriptionLabel.frame.size
                                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                                            attributes:@{ NSFontAttributeName:self.descriptionLabel.font }
                                                                               context:nil]
        .size.width;
        
        self.dealTime.x = descriptionLabelWidth + 10;
    
        self.descriptionLabel.width = descriptionLabelWidth + 5;
        //self.dealTime.text = [self stringForDistance:self.deal.venue.distance];
        
        self.priceContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 117, 80, 20)];
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, -5, 50, 30)];
        [self.priceContainer addSubview:self.priceLabel];
        
        self.priceLabel.text = [NSString stringWithFormat: @"x %@", self.deal.itemPointCost];
        self.priceLabel.font = [ThemeManager lightFontOfSize:14];
        self.priceLabel.textColor = [UIColor whiteColor];
    
        UIImageView *goldCoin = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"goldCoin"]];
        goldCoin.x = 8;
        goldCoin.y = 3;
        
        [self.priceContainer addSubview:goldCoin];
        [self.priceContainer addSubview:self.priceLabel];
        [self.venuePreviewView addSubview:self.priceContainer];
        
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
    
    if (deal.locked) {
        UIView *lockedOverlay = [[UIView alloc] initWithFrame:self.venuePreviewView.frame];
        lockedOverlay.height = 104;
        lockedOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.venuePreviewView addSubview:lockedOverlay];
        
        UIImageView *lockButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
        lockButton.size = CGSizeMake(50, 40);
        lockButton.centerX = self.venuePreviewView.size.width/2;
        lockButton.centerY = self.venuePreviewView.size.height/2;
        [self.venuePreviewView addSubview:lockButton];
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
    distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
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
    [actionSheet showInView:self.venuePreviewView];
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

-(void)redeemRewardButtonTouched:(id)sender
{
    if (!self.deal.locked) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Purchase Voucher?" message:@"Would you like to purchase this voucher?"];
        [alertView bk_addButtonWithTitle:@"Yes" handler:^{
            [[RewardManager sharedManager] purchaseRewardItem:self.deal.dealID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRewardsUpdated object:self];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failure");
            }];
        }];
        
        [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alertView show];
        return;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Not Enough Points" message:@"You don't have enough points to purchase this item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
