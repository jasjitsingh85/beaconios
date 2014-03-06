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
    return self == nil
    || (self == [NSNull null])
    || ([self respondsToSelector:@selector(length)]
        && [(NSData *) self length] == 0)
    || ([self respondsToSelector:@selector(count)]
        && [(NSArray *) self count] == 0);
}

@end
