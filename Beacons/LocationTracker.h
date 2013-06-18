//
//  LocationTracker.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

+ (LocationTracker *)sharedTracker;
- (CLLocation *)currentLocation;
- (void)requestLocationPermission;


@end
