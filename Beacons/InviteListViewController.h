//
//  InviteListViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/14/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeaconStatus, InviteListViewController;
@protocol InviteListViewControllerDelegate <NSObject>

- (void)inviteListViewController:(InviteListViewController *)inviteListViewController didSelectBeaconStatus:(BeaconStatus *)beaconStatus;

@end
@interface InviteListViewController : UITableViewController

@property (weak, nonatomic) id<InviteListViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *beaconStatuses;

@end
