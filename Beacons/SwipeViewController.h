//
//  VoucherViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 3/16/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@class SponsoredEvent, DatingProfile;
@interface SwipeViewController : UIViewController <MDCSwipeToChooseDelegate>

@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;

@end