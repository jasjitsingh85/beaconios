//
//  ExplanationPopupView.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/12/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExplanationPopupView : UIView

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;

- (void)show;

@end
