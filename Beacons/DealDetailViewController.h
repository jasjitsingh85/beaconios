//
//  DealDetailViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 6/21/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"
#import "HappyHour.h"

@interface DealDetailViewController : UIViewController

@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) HappyHour *happyHour;

@end
