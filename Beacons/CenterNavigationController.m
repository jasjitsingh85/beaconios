//
//  CenterNavigationControllerViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CenterNavigationController.h"
#import "AppDelegate.h"

@interface CenterNavigationController ()

@property (strong, nonatomic) UIButton *menuButton;

@end

@implementation CenterNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.menuButton setTitle:@"ham" forState:UIControlStateNormal];
    CGRect frame = CGRectMake(0, 0, 100, 30);
    self.menuButton.frame = frame;
    [self.menuButton addTarget:self.sideNavigationViewController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchDown];
}



#pragma mark - setters
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
    if (!animated) {
        [self setSelectedViewController:selectedViewController];
        return;
    }
    _selectedViewController = selectedViewController;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    BOOL sideNavClosed = [appDelegate.sideNavigationViewController isSideClosed:IIViewDeckLeftSide];
    CGFloat normalLeftSize = appDelegate.sideNavigationViewController.leftSize;
    if (sideNavClosed) {
        self.viewControllers = @[selectedViewController];
        appDelegate.sideNavigationViewController.leftSize = normalLeftSize;
    }
    else {
        __block IIViewDeckController *sideNav = appDelegate.sideNavigationViewController;
        [sideNav setLeftSize:0 completion:^(BOOL completed) {
            if (selectedViewController != self.topViewController) {
                self.viewControllers = @[selectedViewController];
            }
            [appDelegate.sideNavigationViewController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL completed) {
                appDelegate.sideNavigationViewController.leftSize = normalLeftSize;
            }];
        }];
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    _selectedViewController = self.selectedViewController;
    self.viewControllers = @[selectedViewController];
}

#pragma mark - UINavigationBarDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
}

@end
