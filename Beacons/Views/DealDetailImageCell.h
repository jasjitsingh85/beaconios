//
//  DealTableViewCell.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"

@interface DealDetailImageCell : UITableViewCell

@property (strong, nonatomic) UIScrollView *photoScroll;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) Venue *venue;

@end
