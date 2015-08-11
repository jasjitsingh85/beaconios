//
//  HappyHourTableViewCell.h
//  Beacons
//
//  Created by Jasjit Singh on 6/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HappyHour.h"
#import "Venue.h"
#import <MapKit/MapKit.h>

@interface HappyHourTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *venueDetailLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UIView *descriptionBackground;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIView *venueDescriptionBackground;
@property (strong, nonatomic) UILabel *venueDescriptionLabel;
@property (strong, nonatomic) UILabel *venueDetailDealHeadingLabel;
@property (strong, nonatomic) UILabel *venueDetailDealFirstLineLabel;
@property (strong, nonatomic) UILabel *venueDetailDealSecondLineLabel;
@property (strong, nonatomic) UILabel *venueDetailDealDistance;
@property (strong, nonatomic) UIScrollView *venueScroll;
@property (strong, nonatomic) UIView *venuePreviewView;
@property (strong, nonatomic) UIView *venueDetailView;
@property (strong, nonatomic) UIView *backgroundCellView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKMapSnapshotter *mapSnapshot;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (assign, nonatomic) BOOL isFavorited;

@property (strong, nonatomic) HappyHour *happyHour;

@end