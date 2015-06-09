//
//  HotspotAnnotation.h
//  Beacons
//
//  Created by Jasjit Singh on 6/5/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HotspotAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (assign, nonatomic) BOOL hotspotPin;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
