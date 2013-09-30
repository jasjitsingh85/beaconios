//
//  JAGrandCentralDispatch.m
//  Beacons
//
//  Created by Jeff Ames on 9/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "JAGrandCentralDispatch.h"

void jadispatch_main_qeue(dispatch_block_t block)
{
	if ([NSThread isMainThread])
	{
		block();
	}
	else
	{
		dispatch_sync(dispatch_get_main_queue(), block);
	}
}

void jadispatch_after_delay(NSTimeInterval delay, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, queue, block);
}

@implementation JAGrandCentralDispatch

@end
