//
//  DealTableViewCell.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"
#import <MapKit/MapKit.h>

@interface DealTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UIView *descriptionBackground;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *placeType;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *marketPriceLabel;
@property (strong, nonatomic) UILabel *itemPriceLabel;
@property (strong, nonatomic) UIView *venuePreviewView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKMapSnapshotter *mapSnapshot;
@property (assign, nonatomic) BOOL isFollowed;
@property (strong, nonatomic) UIButton *followButton;
@property (strong, nonatomic) Venue *venue;
@property (strong, nonatomic) UIImageView *payFullTab;

@end
