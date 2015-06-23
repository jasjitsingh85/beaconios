//
//  BeaconProfileViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/12/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon;
@interface BeaconProfileViewController : UIViewController

@property (strong, nonatomic) Beacon *beacon;
@property (assign, nonatomic) BOOL openToInviteView;
@property (assign, nonatomic) BOOL openToDealView;

- (void)refreshBeaconData;
- (void)promptForCheckIn;
- (void)initPaymentsViewControllerAndSetDeal;
- (void) inviteMoreFriends;
- (void)refreshDeal;

@end
