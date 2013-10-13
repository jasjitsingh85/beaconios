//
//  EmptyBeaconViewController.m
//  Beacons
//
//  Created by Jeff Ames on 10/10/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "EmptyBeaconViewController.h"
#import "SetBeaconViewController.h"
#import "Theme.h"

@interface EmptyBeaconViewController ()

@property (strong, nonatomic) UIButton *addFriendsButton;
@property (strong, nonatomic) UIButton *setBeaconButton;

@end

@implementation EmptyBeaconViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat viewHight = ([UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height)/3.0;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewHight)];
    self.topView.backgroundColor = [UIColor colorWithRed:234/255.0 green:109/255.0 blue:90/255.0 alpha:1.0];
    [self.view addSubview:self.topView];
    
    self.midView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHight, self.view.frame.size.width, viewHight)];
    self.midView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.midView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 2*viewHight, self.view.frame.size.width, viewHight)];
    self.bottomView.backgroundColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    [self.view addSubview:self.bottomView];
    
    self.addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addFriendsButton.frame = self.midView.bounds;
    [self.addFriendsButton setTitle:@"Add more friends" forState:UIControlStateNormal];
    [self.addFriendsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.addFriendsButton.titleLabel.font = [ThemeManager lightFontOfSize:18];
    [self.midView addSubview:self.addFriendsButton];
    
    self.setBeaconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.setBeaconButton.frame = self.bottomView.bounds;
    [self.setBeaconButton setTitle:@"Set a new Hotspot" forState:UIControlStateNormal];
    self.setBeaconButton.titleLabel.font = [ThemeManager lightFontOfSize:18];
    [self.setBeaconButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setBeaconButton addTarget:self action:@selector(setBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.setBeaconButton];
    
    UIImageView *addFriendsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriendDark"]];
    CGRect addFriendsImageViewFrame = addFriendsImageView.frame;
    addFriendsImageViewFrame.origin.x = 65;
    addFriendsImageViewFrame.origin.y = 0.5*(self.midView.frame.size.height - addFriendsImageViewFrame.size.height);
    addFriendsImageView.frame = addFriendsImageViewFrame;
    [self.midView addSubview:addFriendsImageView];
    
    UIImageView *setBeaconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus"]];
    CGRect setBeaconImageViewFrame = setBeaconImageView.frame;
    setBeaconImageViewFrame.origin.x = 65;
    setBeaconImageViewFrame.origin.y = 0.5*(self.bottomView.frame.size.height - setBeaconImageViewFrame.size.height);
    setBeaconImageView.frame = setBeaconImageViewFrame;
    [self.bottomView addSubview:setBeaconImageView];
}

- (void)setBeaconButtonTouched:(id)sender
{
    SetBeaconViewController *setBeaconViewController = [[SetBeaconViewController alloc] init];
    [self.navigationController pushViewController:setBeaconViewController animated:YES];
}

@end