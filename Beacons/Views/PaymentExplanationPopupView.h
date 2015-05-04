//
//  ExplanationPopupView.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/12/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeaconProfileViewController;

@interface PaymentExplanationPopupView : UIView {
    BeaconProfileViewController *_beaconProfileViewController;
}

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;
@property (nonatomic, strong) BeaconProfileViewController *beaconProfileViewController;

- (void)show;

@end
