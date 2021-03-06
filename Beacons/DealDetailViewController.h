//
//  DealDetailViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 6/21/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"
#import "SponsoredEvent.h"

@interface DealDetailViewController : UIViewController

@property (strong, nonatomic) Venue *venue;
@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;

@end
