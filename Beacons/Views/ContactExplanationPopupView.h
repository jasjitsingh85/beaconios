//
//  RewardExplanationPopupView.h
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactExplanationViewControllerDelegate <NSObject>

- (void)skipButtonTouchedFromContactModal;
- (void) requestContactPermissions;

@end

@interface ContactExplanationPopupView : UIView

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;
@property (assign) id <ContactExplanationViewControllerDelegate> delegate;

- (void)show;

@end