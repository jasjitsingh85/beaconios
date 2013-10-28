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
    NSArray *options = @[@"The creators of Hotspot app are desparate for users and friends. Anything helps.",
                         @"This Hotspot app sucks I wouldn't recommend it to anyone",
                         @"Rahul fill this template out. We aren't paying you 20 rupees an hour for nothing.",
                         @"I hear this Hotspot app can increase your stamina in bed by 30%!",
                         @"This Hotspot app has changed my life. Honestly it's the only thing that saved my marriage",
                         @"You know that feeling when a really cute guy holds the door for you? This Hotspot app gives me that feeling every day.",
                         @"If I had to decide between world peace and this Hotspot app I'd probably pick the app. Then I'd immediately regret the decision.",
                         @"I love and miss you very much. If you love and miss me, you would download this Hotspot app.",
                         @"This Hotspot app is crack. Like you shouldn't use it if your pregnant",
                         @"Meet hot single moms in your area. Download the Hotspot app today!",
                         @"You gotta check out Hotspot. It's an app that prefills embarrassing, and frankly stupid invitation texts to your closest friends."
                         ];
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
    NSArray *options = @[@"Microwaving burritos at mi casa. ¡me gusta!",
                         @"Twerking my bum at Roxy",
                         @"Feeling an animal at the zoo!",
                         @"Searching for love in all the wrong places",
                         @"Finding distractions from things that make us sad :)",
                         @"Shopping for penny loafers at Macy's",
                         @"Shabbat dinner at Hillel. Manischewitz to the face",
                         @"Body painting with the boys",
                         @"Helping Dawson discover himself",
                         @"Heated vinyasa yoga. So sweaty but purifying",
                         @"Stop telling me what to do with my body.",
                         @"Drinking. Joey just broke up with me. Honestly it's her loss",
                         @"I just want to have a quiet night. Maybe read a little",
                         @"Had a rough day. Can someone please give me a backrub?",
                         @"Help! I'm lonely",
                         @"Eating out Chinese food. Actually Japanese. Whatever it all tastes the same",
                         @"Taking Pacey to the hospital. I'm really scared",
                         @"Feeling one with the universe. Come join!",
                         @"Bonfire under the bridge!!!",
                         @"Party at Delta Chi. Bring friends. No dudes plz",
                         @"Gettin punk in drublic",
                         @"Shaking our money makers",
                         @"Crying at a good film",
                         @"Going to the same old shitty bar we always go to",
                         @"Girls night out. Yeaaaah betches",
                         @"Searching for meaning in a big pile of meaninglessness",
                         @"Getting intoxicated enough to dance!",
                         @"Making seriously poor life decisions",
                         @"Monkeying around with papa",
                         @"Slipping into something more comfortable",
                         @"I want to experiment with my body. Anyone interested?",
                         @"Playing the roofie game!!",
                         @"Handing out candy to kids",
                         @"Binging and purging",
                         @"Remember to fill out this template. This isn't amateur night, you outsourced morons",
                         @"Russian roulette. Hurry this guest list is starting to dwindle!",
                         @"Meeting people by kicking open random bathroom stalls",
                         @"Catcalling construction workers",
                         @"Modern art museum. But like how is a cross in a jar of doo-doo considered art?",
                         @"Grammy's funeral and I have literally nothing to wear",
                         @"Hugging trees. Trying to steal third with this tree I've been hugging a lot lately",
                         @"Strip poker. I've already lost everything and now Pacey wants to remove skin",
                         @"Snorting cat nip with Mittens",
                         @"Double fisting. And I don't mean holding a container of alcohol in each hand",
                         @"Disrespecting authority. Shamefully apologizing",
                         @"Winning the big game. Getting the girl. Discovering we are incompatible",
                         @"Feeding the children bread at the park",
                         @"Doing things that make terrorists want to destroy our culture",
                         @"Saving puppies from a burning building. Leaving the kittens behind",
                         @"Working out at the playground. Shirt optional.",
                         @"Snake charming"
                         ];
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
    NSArray *options = @[@"Ghandi used Hotspot to lead India to independence. What will you do with it?",
                         @"1 in 3 Hotspots result in orgasm. I prefer a cigarette after setting one.",
                         @"Your friends are lonely and they need your help!",
                         @"Your Hotspot is a precious thing. Be gentle with it.",
                         @"Setting a Hotspot raises dopamine levels, an effect many find arousing.",
                         ];
    _emptyBeaconSubtitlePicker = [[RandomObjectPicker alloc] initWithObjectOptions:options];
    return _emptyBeaconSubtitlePicker;
}

- (NSString *)randomEmptyBeaconSubtitle
{
    return [self.emptyBeaconSubtitlePicker getRandomObject];
}

@end
