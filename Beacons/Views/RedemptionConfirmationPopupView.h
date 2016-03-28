//
//  RewardExplanationPopupView.h
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SponsoredEvent;
@interface RedemptionConfirmationPopupView : UIView

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) SponsoredEvent *sponsoredEvent;


- (void)show;

@end