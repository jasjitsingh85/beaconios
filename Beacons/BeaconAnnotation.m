//
//  BeaconAnnotation.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconAnnotation.h"
#import "Beacon.h"

@implementation BeaconAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return self.beacon.coordinate;
}

@end
