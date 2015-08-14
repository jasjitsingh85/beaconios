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

@interface FeedTableViewController () <UITableViewDataSource, UITableViewDelegate>
//<UITableViewDataSource, UITableViewDelegate>

@end

@implementation FeedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
//    [self loadNewsfeed];
    
    
}

-(void) setFeed:(NSMutableArray *)feed
{
    _feed = feed;
    
    [self.tableView reloadData];
    //[LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
}

//-(void)loadNewsfeed
//{
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
//    [[APIClient sharedClient] getFavoriteFeed:^(AFHTTPRequestOperation *operation, id responseObject) {
//        self.feed = [[NSMutableArray alloc] init];
//        for (NSDictionary *feedJSON in responseObject[@"favorite_feed"]) {
//            FeedItem *feedItem = [[FeedItem alloc] initWithDictionary:feedJSON];
//            [self.feed addObject:feedItem];
//        }
//        [self.tableView reloadData];
//        [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Favorite Feed Failed");
//    }];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *feedItem = self.feed[indexPath.row];
    NSLog(@"IMAGE: %@", feedItem.image);
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
    if ([feedItem.source isEqualToString:@"hotspot"]) {
        return 70;
    } else {
        CGFloat cellHeight;
        CGFloat imageHeight;
        CGRect messageBodyRect = [feedItem.message boundingRectWithSize:CGSizeMake(220, 0)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:12]}
                                                                     context:nil];
        
        if (feedItem.image) {
            imageHeight = feedItem.image.size.height;

        } else {
            imageHeight = 0;
        }
        cellHeight = messageBodyRect.size.height + imageHeight + 70;
        return cellHeight;
    }
}

@end
