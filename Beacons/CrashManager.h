//
//  CrashManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 7/23/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashManager : NSObject

+ (CrashManager *)sharedManager;

+ (void)enableCrittercism;
+ (void)setupForUser;

@end
