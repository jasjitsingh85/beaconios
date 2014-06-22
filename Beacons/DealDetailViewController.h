//
//  DealDetailViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"

@interface DealDetailViewController : UIViewController

@property (strong, nonatomic) Deal *deal;

- (void)preloadWithDealID:(NSNumber *)dealID;

@end
