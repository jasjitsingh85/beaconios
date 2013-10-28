//
//  RandomObjectManager.h
//  Beacons
//
//  Created by Jeff Ames on 10/24/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomObjectManager : NSObject

+ (RandomObjectManager *)sharedManager;

- (NSString *)randomInviteFriendsToAppString;
- (NSString *)randomSetBeaconPlaceholder;
- (NSString *)randomEmptyBeaconSubtitle;
- (UIAlertView *)randomBeaconSetAlertView;

@end
