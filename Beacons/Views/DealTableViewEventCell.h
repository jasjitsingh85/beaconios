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

@interface DealTableViewEventCell : UITableViewCell

//@property (strong, nonatomic) UIImageView *eventImageView;
//@property (strong, nonatomic) UILabel *venueLabel;
//@property (strong, nonatomic) UILabel *venueDetailLabel;
//@property (strong, nonatomic) UILabel *distanceLabel;
//@property (strong, nonatomic) UIView *descriptionBackground;
//@property (strong, nonatomic) UILabel *descriptionLabel;
//@property (strong, nonatomic) UIView *venueDescriptionBackground;
//@property (strong, nonatomic) UILabel *venueDescriptionLabel;
//@property (strong, nonatomic) UILabel *venueDetailDealHeadingLabel;
//@property (strong, nonatomic) UILabel *venueDetailDealFirstLineLabel;
//@property (strong, nonatomic) UILabel *venueDetailDealSecondLineLabel;
//@property (strong, nonatomic) UILabel *venueDetailDealDistance;
@property (strong, nonatomic) UIScrollView *eventScroll;
@property (strong, nonatomic) UIPageControl *pageControl;
//@property (strong, nonatomic) UIView *venuePreviewView;
//@property (strong, nonatomic) UIView *venueDetailView;
//@property (strong, nonatomic) MKMapView *mapView;
//@property (strong, nonatomic) MKMapSnapshotter *mapSnapshot;

@property (strong, nonatomic) NSArray *events;
//@property (strong, nonatomic) Deal *deal;

@end
