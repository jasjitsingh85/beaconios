//
//  Beacon.h
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class User;
@interface Beacon : NSObject

@property (nonatomic, strong) User *creator;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *time;

@end
