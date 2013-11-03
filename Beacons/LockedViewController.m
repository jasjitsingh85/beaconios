//
//  LockedViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 11/3/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LockedViewController.h"
#import "Theme.h"

@interface LockedViewController ()

@end

@implementation LockedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"orangeBackground"]];
    
    UILabel *label = [[UILabel alloc] init];
    CGRect labelFrame;
    labelFrame.size = CGSizeMake(280, 60);
    labelFrame.origin.x = 0.5*(self.view.frame.size.width - labelFrame.size.width);
    label.frame = labelFrame;
    label.text = @"Hotspot Requires Access To Your Contacts. Go To Settings > Privacy > Contacts and switch Hotspot to On";
    label.numberOfLines = 0;
    label.font = [ThemeManager lightFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
