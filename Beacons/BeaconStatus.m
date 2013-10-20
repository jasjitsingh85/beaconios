//
//  BeaconStatus.m
//  Beacons
//
//  Created by Jeff Ames on 9/14/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconStatus.h"
#import "User.h"
#import "Contact.h"

@implementation BeaconStatus

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSString *status = data[@"status"];
    if ([status isEqualToString:@"invited"]) {
        self.beaconStatusOption = BeaconStatusOptionInvited;
    }
    else if ([status isEqualToString:@"going"]) {
        self.beaconStatusOption = BeaconStatusOptionGoing;
    }
    else if ([status isEqualToString:@"here"]) {
        self.beaconStatusOption = BeaconStatusOptionHere;
    }
    
    if (![data[@"profile"] isEmpty]) {
        self.user = [[User alloc] initWithData:data[@"profile"]];
    }
    if (![data[@"contact"] isEmpty]) {
        self.contact = [[Contact alloc] initWithData:data[@"contact"]];
    }
        
    return self;
}

@end
