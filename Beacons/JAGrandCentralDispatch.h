//
//  JAGrandCentralDispatch.h
//  Beacons
//
//  Created by Jeff Ames on 9/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void jadispatch_main_qeue(void (^block)(void));
extern void jadispatch_after_delay(NSTimeInterval delay, dispatch_queue_t queue, dispatch_block_t block);
@interface JAGrandCentralDispatch : NSObject

@end
