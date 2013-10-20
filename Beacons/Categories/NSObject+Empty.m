//
//  NSObject+Empty.m
//  Beacons
//
//  Created by Jeff Ames on 10/20/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "NSObject+Empty.h"

@implementation NSObject (Empty)

- (BOOL)isEmpty
{
    return !self || [self isEqual:[NSNull null]];
}

@end
