//
//  BeaconImage.h
//  Beacons
//
//  Created by Jeff Ames on 9/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface BeaconImage : NSObject

@property (strong, nonatomic) User *uploader;
@property (strong, nonatomic) NSURL *imageURL;

@end
