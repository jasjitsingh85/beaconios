//
//  RewardExplanationPopupView.h
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnablePushPopupView : UIView

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;

- (void)show;
- (void)dismissSetupModal;

@end