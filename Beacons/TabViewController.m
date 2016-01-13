//
//  TabViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import "TabViewController.h"
#import "TabTableView.h"

@interface TabViewController ()

@property (strong, nonatomic) TabTableView *tabTableView;
@property (strong, nonatomic) UIScrollView *scrollViewContainer;

@end

@implementation TabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollViewContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollViewContainer.scrollEnabled = YES;
    self.scrollViewContainer.backgroundColor = [UIColor whiteColor];
    self.scrollViewContainer.bounds = self.view.bounds;
    self.scrollViewContainer.contentSize = CGSizeMake(self.view.width, self.view.height);
    [self.view addSubview:self.scrollViewContainer];
    
    UIImageView *headerIcon = [[UIImageView alloc] init];
    headerIcon.height = 18;
    headerIcon.width = 18;
    headerIcon.x = 20;
    headerIcon.y = 15;
    [headerIcon setImage:[UIImage imageNamed:@"paymentIcon"]];
    [self.scrollViewContainer addSubview:headerIcon];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 20;
    headerTitle.width = self.view.width;
    headerTitle.textAlignment = NSTextAlignmentLeft;
    headerTitle.x = 42;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 14;
    headerTitle.text = @"FULL TAB";
    [self.scrollViewContainer addSubview:headerTitle];
    
    UILabel *headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, self.view.width - 45, 50)];
    headerExplanationText.centerX = self.view.width/2;
    headerExplanationText.font = [ThemeManager lightFontOfSize:12];
    headerExplanationText.textAlignment = NSTextAlignmentLeft;
    headerExplanationText.numberOfLines = 1;
    headerExplanationText.text = @"Close out your tab by tapping 'PAY TAB'";
    [self.scrollViewContainer addSubview:headerExplanationText];
    
    self.tabTableView = [[TabTableView alloc] init];
    self.tabTableView.tabSummary = NO;
    self.tabTableView.tab = self.tab;
    self.tabTableView.tableView.y = 55;
    self.tabTableView.tabItems = self.tabItems;
    [self.scrollViewContainer addSubview:self.tabTableView.tableView];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(20, ((self.tabItems.count + 4) * 22) + 70, self.view.width - 40, 0.5)];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
    [self.scrollViewContainer addSubview:topBorder];
    
    UIView *buttonContainer = [[UIView alloc] init];
    buttonContainer.backgroundColor = [UIColor whiteColor];
    buttonContainer.width = self.view.width;
    buttonContainer.height = 60;
    buttonContainer.y = self.view.height - 60;
    buttonContainer.userInteractionEnabled = YES;
    [self.view addSubview:buttonContainer];
    
    UIImageView *topDropShadowBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropShadowTopBorder"]];
    topDropShadowBorder.y = -8;
    [buttonContainer addSubview:topDropShadowBorder];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.size = CGSizeMake(self.view.width - 50, 35);
    button.centerX = self.view.width/2.0;
    button.y = 12.5;
    button.layer.cornerRadius = 4;
    button.backgroundColor = [[ThemeManager sharedTheme] redColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    [buttonContainer addSubview:button];
    
    button.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [button addTarget:self action:@selector(reviewTabButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"PAY TAB" forState:UIControlStateNormal];
    
}

-(void)reviewTabButtonTouched:(id)sender
{
    
}

-(void)setTab:(Tab *)tab
{
    _tab = tab;
}

@end