//
//  FindFriendsPopupView.h
//  Beacons
//
//  Created by Jasjit Singh on 1/14/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Beacon, Deal;
@interface FindFriendsPopupView : UIView

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) Beacon *beacon;

- (void)show;
- (void)dismissSetupModal;

@end