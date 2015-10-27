//
//  RewardExplanationPopupView.h
//  Beacons
//
//  Created by Jasjit Singh on 5/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>


//@protocol FreeDrinksExplanationViewControllerDelegate <NSObject>
//
//- (void)launchInviteFriends;
////- (void) inviteMoreFriends;
//////-(BOOL) isUserCreator;
//
//@end
@class Beacon, Deal;
@interface SetupNewsfeedPopupView : UIView

@property (strong, nonatomic) NSAttributedString *attributedInviteText;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) Beacon *beacon;
//@property (assign) id <FreeDrinksExplanationViewControllerDelegate> delegate;

- (void)show;
- (void)dismiss;

@end