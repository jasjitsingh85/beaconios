//
//  DealTableViewCell.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SponsoredEvent.h"
#import <MapKit/MapKit.h>

@interface SponsoredEventTableViewCell : UITableViewCell

@property (strong, nonatomic) UIScrollView *eventScroll;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *events;

@end
