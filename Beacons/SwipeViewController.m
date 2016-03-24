//
//  VoucherViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 3/16/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwipeViewController.h"

@interface SwipeViewController ()

@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *headerExplanationText;

@end

@implementation SwipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.headerTitle = [[UILabel alloc] init];
    self.headerTitle.height = 20;
    self.headerTitle.width = self.view.width;
    self.headerTitle.textAlignment = NSTextAlignmentCenter;
    self.headerTitle.font = [ThemeManager boldFontOfSize:14];
    self.headerTitle.y = 105;
    self.headerTitle.text = @"Coming Soon!";
    [self.view addSubview:self.headerTitle];
    
    self.headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(35, 105, self.view.width - 70, 120)];
    self.headerExplanationText.font = [ThemeManager lightFontOfSize:13];
    self.headerExplanationText.textAlignment = NSTextAlignmentCenter;
    self.headerExplanationText.numberOfLines = 0;
    self.headerExplanationText.text = @"Stay tuned for this feature! It'll be a fun way to meet new people at any of our events. If you want more information, email us at info@gethotspotapp.com";
    [self.view addSubview:self.headerExplanationText];
    
}

@end

