//
//  TabViewController.h
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tab, Venue;
@interface TabViewController : UIViewController

@property (strong, nonatomic) NSArray *tabItems;
@property (strong, nonatomic) Tab *tab;
@property (strong, nonatomic) Venue *venue;

@end