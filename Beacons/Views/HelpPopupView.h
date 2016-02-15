//
//  RewardExplanationPopupView.h
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon, Deal;
@interface HelpPopupView : UIView

@property (strong, nonatomic) UIButton *doneButton;

- (void)showFeaturedEventExplanationModal;
-(void)showHotspotExplanationModal;
-(void)showFeeExplanationModal;

@end