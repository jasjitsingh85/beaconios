//
//  BeaconMapSnapshotImageView.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/11/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "MapSnapshotImageView.h"

@class Beacon;
@interface BeaconMapSnapshotImageView : MapSnapshotImageView

@property (strong, nonatomic) Beacon *beacon;

@end
