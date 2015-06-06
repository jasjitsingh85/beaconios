//
//  HotspotAnnotation.m
//  Beacons
//
//  Created by Jasjit Singh on 6/5/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HotspotAnnotation.h"

@implementation HotspotAnnotation
@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    return self;
}

@end
