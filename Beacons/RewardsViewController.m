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
#import "RewardsStoreViewController.h"

@interface RewardsViewController()

@property (nonatomic, strong) NSString *rewards_score;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UIButton *rewards_score_nav_item;
@property (nonatomic, strong) RewardExplanationPopupView *rewardExplanationPopupView;
@property (nonatomic, strong) RewardsStoreViewController *rewardsStoreViewController;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation RewardsViewController

-(id)initWithNavigationItem:(UINavigationItem *)navItem
{
    self = [super init];
    self.navItem = navItem;
    self.rewardExplanationPopupView = [[RewardExplanationPopupView alloc] init];
    self.rewardsStoreViewController = [[RewardsStoreViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rewardsStoreViewController];
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(modalDoneButtonTouched:)];
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
//        self.rewards_score_nav_item = [UIButton navButtonWithTitle:[NSString stringWithFormat:@"%@", rewards_score]];
        self.rewards_score_nav_item = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rewards_score_nav_item setFrame:CGRectMake(0, 0, 58, 20)];
        [self.rewards_score_nav_item setBackgroundImage:[UIImage imageNamed:@"goldCoin"] forState:UIControlStateNormal];
        [self.rewards_score_nav_item setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0, 15.0, 0.0)];
        [self.rewards_score_nav_item setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0.0)];
        [self.rewards_score_nav_item setTitle:[NSString stringWithFormat:@"%@", rewards_score] forState:UIControlStateNormal];
        [self.rewards_score_nav_item setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rewards_score_nav_item addTarget:self action:@selector(rewardsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.rewards_score_nav_item.titleLabel setFont:[ThemeManager boldFontOfSize:15]];
        self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rewards_score_nav_item];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //self.rewards_score_nav_item = [UIButton navButtonWithTitle:@"ERROR"];
    }];
}

-(void)rewardsButtonTouched:(id)sender
{
    [self updateRewardsScore];
    //[self.rewardExplanationPopupView show];
    
    //navigationController.navigationBar.topItem.title = @"ONE TIME SETUP";
    //navigationController.navigationBar.barTintColor = [[ThemeManager sharedTheme] redColor];
    //navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [ThemeManager lightFontOfSize:18]};
    //navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:    [[ThemeManager sharedTheme] navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    //self.navItem.leftBarButtonItem = self.cancelButtonItem;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    //self.navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:self.navigationController
                       animated:YES
                     completion:nil];
}

@end
