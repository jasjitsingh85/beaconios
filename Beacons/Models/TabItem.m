//
//  TabItem.m
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabItem.h"

@implementation TabItem

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.menuItemID = @"11111";
    self.name = @"Shot of Jameson";
    self.price = @4;
    
    return self;
}

@end