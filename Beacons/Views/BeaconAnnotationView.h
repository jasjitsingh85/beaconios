//
//  BeaconAnnotationView.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BeaconAnnotationView : MKAnnotationView

@property (assign, nonatomic) BOOL animatesDrop;
@property (assign, nonatomic) BOOL active;

@end
