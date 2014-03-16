//
//  Beacon+Time.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "Beacon.h"

@interface Beacon (Time)

- (BOOL)expired;
- (BOOL)inDistantFuture;

@end
