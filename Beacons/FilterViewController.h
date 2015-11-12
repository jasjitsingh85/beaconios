//
//  FindFriendsViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FilterViewController, Deal;

@interface FilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (assign, nonatomic) BOOL isHotspotToggleOn;
@property (assign, nonatomic) BOOL isHappyHourToggleOn;
@property (assign, nonatomic) BOOL now;
@property (assign, nonatomic) BOOL upcoming;

@end
