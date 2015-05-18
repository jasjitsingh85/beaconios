//
//  VoucherRedemptionView.h
//  Beacons
//
//  Created by Jasjit Singh on 5/17/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Voucher, Deal;
@interface VoucherRedemptionViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) Voucher *voucher;

- (void)setDeal:(Deal *)deal andVoucher:(Voucher *)voucher;

@end