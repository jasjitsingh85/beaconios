//
//  RandomObjectPicker.m
//  Beacons
//
//  Created by Jeff Ames on 10/24/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "RandomObjectPicker.h"

@implementation RandomObjectPicker

- (id)initWithObjectOptions:(NSArray *)options
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.objectOptions = options;
    return self;
}

- (id)getRandomObject
{
    if (!self.objectOptions || !self.objectOptions.count) {
        return nil;
    }
    
    NSInteger idx = arc4random_uniform(self.objectOptions.count);
    return self.objectOptions[idx];
}

@end
