//
//  EditGroupViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface EditGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) UITableView *tableView;

@end
