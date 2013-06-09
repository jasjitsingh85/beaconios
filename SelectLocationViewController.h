//
//  SelectLocationViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/6/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Venue;
@protocol SelectLocationViewControllerDelegate <NSObject>

- (void)didSelectCurrentLocation;
- (void)didSelectVenue:(Venue *)venue;

@end

@interface SelectLocationViewController : UIViewController

@property (weak, nonatomic) id<SelectLocationViewControllerDelegate> delegate;

@end
