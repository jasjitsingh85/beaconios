//
//  DealRedemptionViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DealStatus, Deal;
@interface DealRedemptionViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) DealStatus *dealStatus;

- (void)setDeal:(Deal *)deal andDealStatus:(DealStatus *)dealStatus;

@end
