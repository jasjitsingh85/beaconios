//
//  VoucherViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 5/17/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Voucher;
@interface VoucherViewController : UIViewController

@property (strong, nonatomic) Voucher *voucher;
@property (assign, nonatomic) BOOL openToInviteView;
@property (assign, nonatomic) BOOL openToDealView;

- (void)refreshVoucherData;
- (void)refreshDeal;

@end
