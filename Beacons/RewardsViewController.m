//
//  RewardsViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RewardsViewController.h"
#import "APIClient.h"
#import "UIButton+HSNavButton.h"
#import "RewardExplanationPopupView.h"

@interface RewardsViewController()

@property (nonatomic, strong) NSString *rewards_score;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UIButton *rewards_score_nav_item;
@property (nonatomic, strong) RewardExplanationPopupView *rewardExplanationPopupView;

@end

@implementation RewardsViewController

-(id)initWithNavigationItem:(UINavigationItem *)navItem
{
    self = [super init];
    self.navItem = navItem;
    self.rewardExplanationPopupView = [[RewardExplanationPopupView alloc] init];
    if (!self) {
        return nil;
    } else {
        return self;
    }
}

-(void)updateRewardsScore
{
    [[APIClient sharedClient] getRewardsScore:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rewards_score = responseObject[@"total_rewards"];
        self.rewards_score_nav_item = [UIButton navButtonWithTitle:[NSString stringWithFormat:@"%@", rewards_score]];
        [self.rewards_score_nav_item addTarget:self action:@selector(rewardsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rewards_score_nav_item];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //self.rewards_score_nav_item = [UIButton navButtonWithTitle:@"ERROR"];
    }];
}

-(void)rewardsButtonTouched:(id)sender
{
    [self.rewardExplanationPopupView show];
}

@end
