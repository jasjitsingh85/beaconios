//
//  BeaconStatus.h
//  Beacons
//
//  Created by Jeff Ames on 9/14/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Contact.h"

typedef enum {
    BeaconStatusOptionInvited=0,
    BeaconStatusOptionGoing,
    BeaconStatusOptionHere,
} BeaconStatusOption;

@interface BeaconStatus : NSObject

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Contact *contact;
@property (assign, nonatomic) BeaconStatusOption beaconStatusOption;

- (id)initWithData:(NSDictionary *)data;

@end
