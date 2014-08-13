//
//  SetDealViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 8/7/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"

@interface SetDealViewController : UITableViewController

@property (strong, nonatomic) Deal *deal;
- (void)preloadWithDealID:(NSNumber *)dealID;

@end
