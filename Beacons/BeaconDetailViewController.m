//
//  BeaconDetailViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/12/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconDetailViewController.h"
#import "BeaconChatViewController.h"

@interface BeaconDetailViewController ()

@property (strong, nonatomic) BeaconChatViewController *beaconChatViewController;

@end

@implementation BeaconDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.beaconChatViewController = [[BeaconChatViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    CGRect chatFrame = self.beaconChatViewController.view.frame;
//    chatFrame.origin.y = 226;
//    self.beaconChatViewController.view.frame = chatFrame;
//    [self addChildViewController:self.beaconChatViewController];
//    [self.view addSubview:self.beaconChatViewController.view];
}

- (void)setBeacon:(Beacon *)beacon
{
//    _beacon = beacon;
//    self.beaconChatViewController.beacon = beacon;
}

@end
