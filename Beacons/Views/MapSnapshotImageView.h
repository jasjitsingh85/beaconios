//
//  MapSnapshotImageView.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/11/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapSnapshotImageView : UIImageView

@property (assign, nonatomic) MKCoordinateRegion region;
@property (strong, nonatomic) NSArray *annotationViews;
@property (strong, nonatomic) UIImage *placeholder;

- (void)update;

@end
