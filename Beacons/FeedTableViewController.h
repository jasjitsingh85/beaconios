//
//  FeedViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 8/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *feed;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSArray *recommendations;
@property (assign, nonatomic) BOOL isRefreshing;

- (id) initWithLoadingIndicator;

@end

