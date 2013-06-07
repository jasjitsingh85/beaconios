//
//  CenterNavigationControllerViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CenterNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface CenterNavigationController ()

@property (strong, nonatomic) UIButton *menuButton;

@end

@implementation CenterNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *menuButtonImage = [UIImage imageNamed:@"menuButton"];
    CGRect frame;
    frame.size = menuButtonImage.size;
    self.menuButton.frame = frame;
    [self.menuButton setBackgroundImage:menuButtonImage forState:UIControlStateNormal];
    [self.menuButton addTarget:self.sideNavigationViewController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchDown];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
}



#pragma mark - setters
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
    if (!animated) {
        [self setSelectedViewController:selectedViewController];
        return;
    }
    UIGraphicsBeginImageContextWithOptions(self.topViewController.view.bounds.size, YES, 0.0f);
    [self.topViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [selectedViewController.view addSubview:imageView];
    _selectedViewController = selectedViewController;
    self.viewControllers = @[selectedViewController];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.sideNavigationViewController closeLeftViewAnimated:YES];

}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    _selectedViewController = self.selectedViewController;
    self.viewControllers = @[selectedViewController];
}

#pragma mark - UINavigationBarDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        viewController.navigationItem.title = @"Beacons";
    }
}

@end
