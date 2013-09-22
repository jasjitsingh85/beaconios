//
//  SoundPlayer.m
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SoundPlayer.h"

@interface SoundPlayer ()

@end

@implementation SoundPlayer

+ (SoundPlayer *)sharedPlayer
{
    static SoundPlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [SoundPlayer new];
    });
    return _sharedPlayer;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


@end
