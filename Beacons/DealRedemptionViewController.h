//
//  DealRedemptionViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/3/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DealStatus, Deal, Beacon, SponsoredEvent;

@protocol DealRedemptionViewControllerDelegate <NSObject>

- (void)initPaymentsViewControllerAndSetDeal;
- (void) redeemRewardItem;
- (void) inviteMoreFriends;
- (void) checkPaymentsOnFile;
//-(BOOL) isUserCreator;

@end

@interface DealRedemptionViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) Beacon *beacon;
@property (strong, nonatomic) DealStatus *dealStatus;
@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;
@property (assign) id <DealRedemptionViewControllerDelegate> delegate;

- (void)setBeaconDeal:(Beacon *)beacon;
- (void)updateRedeemButtonAppearance;

@end
