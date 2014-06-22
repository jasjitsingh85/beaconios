//
//  CommonMacros.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "CommonMacros.h"

BOOL isEmpty(id thing) {
    return thing == nil
    || thing == [NSNull null]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}