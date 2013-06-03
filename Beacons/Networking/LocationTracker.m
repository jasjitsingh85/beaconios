//
//  LocationTracker.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "LocationTracker.h"

@implementation LocationTracker

+ (LocationTracker *)sharedTracker
{
    static LocationTracker *_sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTracker = [[LocationTracker alloc] init];
        
    });
    return _sharedTracker;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
    }
    return self;
}

@end
