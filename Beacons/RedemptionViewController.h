//
//  DealRedemptionTableViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 1/5/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DealStatus, Deal, Beacon, SponsoredEvent;
@interface RedemptionViewController : UIViewController

@property (strong, nonatomic) Beacon *beacon;
@property (assign, nonatomic) BOOL openToInviteView;
@property (assign, nonatomic) BOOL openToDealView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;
@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) DealStatus *dealStatus;

- (void)refreshBeaconData;
- (void)refreshSponsoredEventData;
//- (void)promptForCheckIn;
- (void)refreshDeal;

@end
