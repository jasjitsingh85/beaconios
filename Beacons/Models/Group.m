//
//  Group.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "Group.h"
#import "Contact.h"

@implementation Group

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self updateWithData:data];
    return self;
}

- (void)updateWithData:(NSDictionary *)data
{
    self.groupID = data[@"id"];
    self.name = data[@"name"];
    NSArray *groupMembers = data[@"members"];
    NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:groupMembers.count];
    for (NSDictionary *contactData in groupMembers) {
        Contact *contact = [[Contact alloc] initWithData:contactData[@"contact"]];
        [contacts addObject:contact];
    }
    self.contacts = [NSArray arrayWithArray:contacts];
}

@end
