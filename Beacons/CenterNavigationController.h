//
//  CenterNavigationControllerViewController.h
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MSDynamicsDrawerViewController.h>
#import "HSNavigationController.h"

@interface CenterNavigationController : HSNavigationController <UINavigationControllerDelegate>

@property (weak, nonatomic) MSDynamicsDrawerViewController *sideNavigationViewController;
@property (strong, nonatomic) UIViewController *selectedViewController;

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;

@property (strong, nonatomic) UIButton *menuButton;
@property (strong, nonatomic) UIButton *dealsButton;

@end
