//
//  RandomObjectManager.m
//  Beacons
//
//  Created by Jeff Ames on 10/24/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "RandomObjectManager.h"
#import "RandomObjectPicker.h"
#import "APIClient.h"

#define kRandomObjectOptionInviteFriends @"IU"
#define kRandomObjectOptionEmptyHotSpot @"SN"
#define kRandomObjectOptionHotSpotPlaceholder @"SP"

@interface RandomObjectManager()

@property (strong, nonatomic) RandomObjectPicker *inviteFriendsToAppPicker;
@property (strong, nonatomic) RandomObjectPicker *setBeaconPlaceholderPicker;
@property (strong, nonatomic) RandomObjectPicker *beaconSetAlertPicker;
@property (strong, nonatomic) RandomObjectPicker *emptyBeaconSubtitlePicker;

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
    NSArray *options = @[@"Checkout this app Hotspot. It's the best"];
    _inviteFriendsToAppPicker = [[RandomObjectPicker alloc] initWithObjectOptions:options];
    return _inviteFriendsToAppPicker;
}

- (NSString *)randomInviteFriendsToAppString
{
    return [self.inviteFriendsToAppPicker getRandomObject];
}

- (RandomObjectPicker *)setBeaconPlaceholderPicker
{
    if (_setBeaconPlaceholderPicker) {
        return _setBeaconPlaceholderPicker;
    }
    NSArray *options = @[@"Getting this party started at Von Trapps!"];
    _setBeaconPlaceholderPicker = [[RandomObjectPicker alloc] initWithObjectOptions:options];
    return _setBeaconPlaceholderPicker;
}

- (NSString *)randomSetBeaconPlaceholder
{
    return [self.setBeaconPlaceholderPicker getRandomObject];
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

- (RandomObjectPicker *)emptyBeaconSubtitlePicker
{
    if (_emptyBeaconSubtitlePicker) {
        return _emptyBeaconSubtitlePicker;
    }
    NSArray *options = @[@"Set a Hotspot and get the party started!"];
    _emptyBeaconSubtitlePicker = [[RandomObjectPicker alloc] initWithObjectOptions:options];
    return _emptyBeaconSubtitlePicker;
}

- (NSString *)randomEmptyBeaconSubtitle
{
    return [self.emptyBeaconSubtitlePicker getRandomObject];
}

- (void)updateStringsFromServer
{
    [[APIClient sharedClient] getPath:@"content/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *options = responseObject[@"content"];
        if (options && options.count) {
            self.emptyBeaconSubtitlePicker.objectOptions = [self optionsForDisplayLocation:kRandomObjectOptionEmptyHotSpot givenResponseOptions:options];
            self.inviteFriendsToAppPicker.objectOptions = [self optionsForDisplayLocation:kRandomObjectOptionInviteFriends givenResponseOptions:options];
            self.setBeaconPlaceholderPicker.objectOptions = [self optionsForDisplayLocation:kRandomObjectOptionHotSpotPlaceholder givenResponseOptions:options];
            self.hasUpdatedFromServer = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRandomStringsUpdated object:nil];
        }
    } failure:nil];
}

- (NSArray *)optionsForDisplayLocation:(NSString *)displayLocation givenResponseOptions:(NSArray *)options
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"display_location = %@", displayLocation];
    return [[options filteredArrayUsingPredicate:predicate] valueForKey:@"content_option"];
}

@end
