//
//  RandomObjectManager.m
//  Beacons
//
//  Created by Jeff Ames on 10/24/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "RandomObjectManager.h"
#import "RandomObjectPicker.h"

@interface RandomObjectManager()

@property (strong, nonatomic) RandomObjectPicker *inviteFriendsToAppPicker;
@property (strong, nonatomic) RandomObjectPicker *beaconSetAlertPicker;

@end

@implementation RandomObjectManager

+ (RandomObjectManager *)sharedManager
{
    static RandomObjectManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[RandomObjectManager alloc] init];
    });
    return _sharedManager;
}

- (RandomObjectPicker *)inviteFriendsToAppPicker
{
    if (_inviteFriendsToAppPicker) {
        return _inviteFriendsToAppPicker;
    }
    NSArray *options = @[@"the creators of this app are desparate for users and friends. Anything helps.",
                         @"blah1",
                         @"blah2"];
    _inviteFriendsToAppPicker = [[RandomObjectPicker alloc] initWithObjectOptions:options];
    return _inviteFriendsToAppPicker;
}

- (NSString *)randomInviteFriendsToAppString
{
    return [self.inviteFriendsToAppPicker getRandomObject];
}

- (RandomObjectPicker *)beaconSetAlertPicker
{
    if (_beaconSetAlertPicker) {
        return _beaconSetAlertPicker;
    }
    NSArray *options = @[
                         [[UIAlertView alloc] initWithTitle:@"Best. Hotspot. Ever." message:@"What would your friends do without you to lead them?" delegate:nil cancelButtonTitle:@"Nothing, they need me." otherButtonTitles: nil],
                         [[UIAlertView alloc] initWithTitle:@"Your Hotspot looks fun!" message:@"Can I come?" delegate:nil cancelButtonTitle:@"No...God, you're so creepy" otherButtonTitles: nil],
                         [[UIAlertView alloc] initWithTitle:@"Your Hotspot...it's beautiful" message:@"No Hotspot has ever made me feel this way before" delegate:nil cancelButtonTitle:@"You probably say that to all the Hotspots" otherButtonTitles:nil],
                         [[UIAlertView alloc] initWithTitle:@"Quite the Hotspot you got there" message:@"You must be very popular" delegate:nil cancelButtonTitle:@"Thank you" otherButtonTitles:nil]];
    _beaconSetAlertPicker = [[RandomObjectPicker alloc] initWithObjectOptions:options];
    return _beaconSetAlertPicker;
}

- (UIAlertView *)randomBeaconSetAlertView
{
    return [self.beaconSetAlertPicker getRandomObject];
}

@end
