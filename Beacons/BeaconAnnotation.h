//
//  BeaconAnnotation.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Beacon;
@interface BeaconAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) Beacon *beacon;

@end
