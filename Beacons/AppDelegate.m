//
//  AppDelegate.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "MapViewController.h"
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "APIClient.h"

@implementation AppDelegate

- (CenterNavigationController *)centerNavigationController
{
    if (!_centerNavigationController) {
        _centerNavigationController = [[CenterNavigationController alloc] init];
    }
    return _centerNavigationController;
}

- (IIViewDeckController *)sideNavigationViewController
{
    if (!_sideNavigationViewController) {
        _sideNavigationViewController = [[IIViewDeckController alloc] init];
        _sideNavigationViewController.openSlideAnimationDuration = 0.2;
        _sideNavigationViewController.closeSlideAnimationDuration = 0.2;
        _sideNavigationViewController.panningMode = IIViewDeckFullViewPanning;
        _sideNavigationViewController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
        _sideNavigationViewController.leftSize = 235;
    }
    return _sideNavigationViewController;
}

- (MapViewController *)mapViewController
{
    if (!_mapViewController) {
        _mapViewController = [MapViewController new];
    }
    return _mapViewController;
}

- (MenuViewController *)menuViewController
{
    if (!_menuViewController) {
        _menuViewController = [MenuViewController new];
    }
    return _menuViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.centerNavigationController.selectedViewController = self.mapViewController;
    self.sideNavigationViewController.centerController = self.centerNavigationController;
    self.sideNavigationViewController.leftController = self.menuViewController;
    self.window.rootViewController = self.sideNavigationViewController;

    [self.window makeKeyAndVisible];
    self.loginViewController = [LoginViewController new];
    [self.window.rootViewController presentViewController:self.loginViewController animated:NO completion:nil];
    return YES;
}

- (void)createAccount
{
    NSDictionary *parameters = @{@"username" : @"jeff",
                                 @"password" : @"fuck",
                                 @"email" : @"j@j.com",
                                 @"phone_number" : @"6176337532"};
    [[APIClient sharedClient] postPath:@"user/me/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   //if the user already has a valid authorization token then the server retuns an empty response
                                   if (operation.response.statusCode != kHTTPStatusCodeNoContent) {
                                       id response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                                       NSString *authorizationToken = response[@"token"];
                                       [[APIClient sharedClient] setAuthorizationHeaderWithToken:authorizationToken];
                                   }
                                   self.window.rootViewController.presentedViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                                   [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                                   [self getAccount];
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [self getAccount];
                               }];
}

- (void)getAccount
{
    [[APIClient sharedClient] getPath:@"user/me/" parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self login];
        
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error){}];
}

- (void)login
{
    NSDictionary *parameters = @{@"username" : @"jeff",
                                 @"password" : @"fuck",
                                 @"email" : @"j@j.com",
                                 @"phone_number" : @"6176337532"};
    [[APIClient sharedClient] postPath:@"login/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
                                   }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   
                               }];
}

@end
