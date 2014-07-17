//
//  DealExplanationView.h
//  Beacons
//
//  Created by Jeffrey Ames on 7/17/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DismissCompletionBlock)();

@interface DealExplanationView : UIView

@property (strong, nonatomic) DismissCompletionBlock dismissCompletionBlock;

- (void)show;
- (void)dismiss;


@end
