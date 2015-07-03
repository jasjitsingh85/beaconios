//
//  DealInfoView.h
//  Beacons
//
//  Created by Jasjit Singh on 7/3/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HappyHour;
@interface HappyHourView : UIView

@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UIView *descriptionBackground;
@property (strong, nonatomic) UILabel *descriptionLabel;
//@property (strong, nonatomic) UILabel *priceLabel;
//@property (strong, nonatomic) UILabel *marketPriceLabel;
@property (strong, nonatomic) UIView *venueView;
//@property (strong, nonatomic) UIView *venuePreviewView;
//@property (strong, nonatomic) MKMapView *mapView;
//@property (strong, nonatomic) MKMapSnapshotter *mapSnapshot;
@property (strong, nonatomic) HappyHour *happyHour;

@end
