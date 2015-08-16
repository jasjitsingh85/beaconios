//
//  FeedViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 8/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedTableViewController.h"
#import "LoadingIndictor.h"
#import "APIClient.h"
#import "FeedItem.h"
#import "FeedItemTableViewCell.h"
#import "NavigationBarTitleLabel.h"

@interface FeedTableViewController () <UITableViewDataSource, UITableViewDelegate>
//<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isViewShowing;
@property (strong, nonatomic) UIView *emptyFeedView;
@property (assign, nonatomic) BOOL pullToRefresh;

@end

@implementation FeedTableViewController

- (id) initWithLoadingIndicator  {
    self = [super init];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = YES;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.pullToRefresh = NO;
    
    self.feed = [[NSMutableArray alloc] init];
    
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
//
//    self.isRefreshing = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingIndicator:) name:kFeedUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedStartedRefreshing:) name:kFeedStartRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedFinishedRefreshing:) name:kFeedFinishRefreshNotification object:nil];
    
    self.isViewShowing = NO;
    
    if (!self) {
        return nil;
    } else {
        return self;
    }
}

-(void)feedStartedRefreshing:(NSNotification *)notification
{
    if (!self.pullToRefresh) {
        [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    }
    self.isRefreshing = YES;
}

-(void)feedFinishedRefreshing:(NSNotification *)notification
{
    [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    [self.refreshControl endRefreshing];
    self.isRefreshing = NO;
    self.pullToRefresh = NO;
    
    if (self.feed.count > 0) {
        self.emptyFeedView.hidden = YES;
    } else {
        self.emptyFeedView.hidden = NO;
    }
}

//-(void) showLoadingIndicator:(id)sender
//{
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    self.emptyFeedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 300)];
    self.emptyFeedView.backgroundColor = [UIColor clearColor];
    self.emptyFeedView.hidden = YES;
    [self.tableView addSubview:self.emptyFeedView];
    
    UIImageView *groupIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigGroupIcon"]];
    groupIcon.width = 35;
    groupIcon.height = 35;
    groupIcon.centerX = self.view.width/2.0;
    groupIcon.y = 100;
    [self.emptyFeedView addSubview:groupIcon];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, self.view.width, 20)];
    header.textAlignment = NSTextAlignmentCenter;
    header.font = [ThemeManager boldFontOfSize:18];
    header.text = @"NOTHING TO REPORT";
    [self.emptyFeedView addSubview:header];
    
    UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(0, 175, self.view.width - 70, 90)];
    body.textAlignment = NSTextAlignmentCenter;
    body.font = [ThemeManager lightFontOfSize:15];
    body.numberOfLines = 0;
    body.centerX = self.view.width/2.0;
    body.text = @"With the Hotspot newsfeed you'll see the latest news, offers, and events at your favorite places. Follow more places to see more!";
    [self.emptyFeedView addSubview:body];
    
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Newsfeed"];
    
//    self.emptyFeedView = [[UIView alloc] initWithFrame:self.view.bounds];
//    self.emptyFeedView.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
//    self.emptyFeedView.hidden = YES;
//    
//    UIImageView *lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
//    lockIcon.width = 40;
//    lockIcon.height = 40;
//    lockIcon.centerX = self.view.width/2.0;
//    lockIcon.y = 100;
//    [self.emptyFeedView addSubview:lockIcon];
//    
//    [self.view addSubview:self.emptyFeedView];
    
}

-(void) setFeed:(NSMutableArray *)feed
{
    _feed = feed;
    
    [self.tableView reloadData];
    
    if (!self.isRefreshing) {
        //[self showProperView];
        [self.tableView reloadData];
//        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    }
    
    if (self.isViewShowing && !self.isRefreshing) {
        [self markViewAsSeen];
    }
}

//-(void)showProperView
//{
//    if (self.feed.count > 0) {
//        self.tableView.hidden = NO;
//        self.emptyFeedView.hidden = YES;
//    } else {
//        self.tableView.hidden = YES;
//        self.emptyFeedView.hidden = NO;
//    }
//}

- (void) viewDidAppear:(BOOL)animated
{
    self.isViewShowing = YES;
    if (!self.isRefreshing) {
        [self markViewAsSeen];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        self.isViewShowing = NO;
    }
    [super viewWillDisappear:animated];
}

-(void)markViewAsSeen
{
    if (self.feed.count > 0) {
        FeedItem *feedItem = self.feed[0];
        [[NSUserDefaults standardUserDefaults] setObject:feedItem.dateCreated forKey:kFeedUpdateNotification];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveNewsfeedNotification object:self userInfo:nil];
    }
}

-(void)pullToRefresh:(id)sender
{
    self.pullToRefresh = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *feedItem = self.feed[indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    FeedItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[FeedItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.feedItem = feedItem;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *feedItem = self.feed[indexPath.row];
    CGFloat cellHeight;
    CGFloat imageHeight;
    
    CGRect messageRect = [feedItem.message boundingRectWithSize:CGSizeMake(190, 0)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:11]}
                                                            context:nil];
    
    CGRect messageBodyRect = [feedItem.message boundingRectWithSize:CGSizeMake(220, 0)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:11]}
                                                                 context:nil];
    
    if (feedItem.image) {
        imageHeight = feedItem.image.size.height;

    } else {
        imageHeight = 0;
    }
    if ([feedItem.source isEqualToString:@"hotspot"]) {
        cellHeight = messageRect.size.height + imageHeight + 60;
    } else {
        cellHeight = messageBodyRect.size.height + imageHeight + 70;
    }
    return cellHeight;
    }

@end
