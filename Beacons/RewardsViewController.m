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
//#import "RewardExplanationPopupView.h"
//#import "RewardsStoreViewController.h"

@interface RewardsViewController()

@property (nonatomic, strong) NSString *rewards_score;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UIView *rewards_score_nav_item;
//@property (nonatomic, strong) RewardExplanationPopupView *rewardExplanationPopupView;
//@property (nonatomic, strong) RewardsStoreViewController *rewardsStoreViewController;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation RewardsViewController

-(id)initWithNavigationItem:(UINavigationItem *)navItem
{
    self = [super init];
    self.navItem = navItem;
//    self.rewardExplanationPopupView = [[RewardExplanationPopupView alloc] init];
//    self.rewardsStoreViewController = [[RewardsStoreViewController alloc] init];
 //   self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rewardsStoreViewController];
    self.rewards_score_nav_item = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    self.rewards_score_nav_item.hidden = YES;
    //        self.rewards_score_nav_item = [UIButton navButtonWithTitle:[NSString stringWithFormat:@"%@", rewards_score]];
    [self.rewards_score_nav_item setFrame:CGRectMake(-50, 0, 58, 20)];
//    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(modalDoneButtonTouched:)];
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
        UIImageView *goldCoin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"largeGoldCoin"]];
        [self.rewards_score_nav_item addSubview:goldCoin];
        UILabel *rewardScore = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, 60, 20)];
        rewardScore.font = [ThemeManager lightFontOfSize:16];
        rewardScore.text = [NSString stringWithFormat:@"x %@", rewards_score];
        [self.rewards_score_nav_item addSubview:rewardScore];
        //[self.rewards_score_nav_item setTitle:[NSString stringWithFormat:@"%@", rewards_score] forState:UIControlStateNormal];
        //[self.rewards_score_nav_item.titleLabel setFont:[ThemeManager boldFontOfSize:15]];
        self.navItem.titleView = self.rewards_score_nav_item;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //self.rewards_score_nav_item = [UIButton navButtonWithTitle:@"ERROR"];
    }];
}

- (void) hideRewardsScore
{
    self.rewards_score_nav_item.hidden = YES;
}

- (void) showRewardsScore
{
    self.rewards_score_nav_item.hidden = NO;
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
