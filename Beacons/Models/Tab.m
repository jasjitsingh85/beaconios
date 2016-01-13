//
//  Tab.m
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tab.h"

@implementation Tab

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.tabID = @"11111";
    
    return self;
}

@end
