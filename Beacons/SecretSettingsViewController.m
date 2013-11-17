//
//  SecretSettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 11/16/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SecretSettingsViewController.h"
#import "APIClient.h"

@interface SecretSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *serverPathButton;


@end

@implementation SecretSettingsViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateServerPathButtonTitle];
}


- (void)updateServerPathButtonTitle
{
    if ([[APIClient sharedClient].baseURL.absoluteString isEqualToString:kBaseURLStringProduction]) {
        [self.serverPathButton setTitle:@"Prod" forState:UIControlStateNormal];
    }
    else {
        [self.serverPathButton setTitle:@"Stage" forState:UIControlStateNormal];
    }
}

- (IBAction)serverPathButtonTouched:(id)sender
{
    NSString *serverPath = [[APIClient sharedClient].baseURL.absoluteString isEqualToString:kBaseURLStringProduction] ? kBaseURLStringStaging : kBaseURLStringProduction;
    [APIClient changeServerPath:serverPath];
    [self updateServerPathButtonTitle];
}


@end
