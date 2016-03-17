//
//  VoucherViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 3/16/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SponsoredEvent;
@interface VoucherViewController : UIViewController

@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;

//- (void)refreshBeaconData;
//- (void)refreshSponsoredEventData;
//- (void)promptForCheckIn;
//- (void)refreshDeal;

@end