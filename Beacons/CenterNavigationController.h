//
//  CenterNavigationControllerViewController.h
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IIViewDeckController.h>

@interface CenterNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (weak, nonatomic) IIViewDeckController *sideNavigationViewController;
@property (strong, nonatomic) UIViewController *selectedViewController;

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;

@end
