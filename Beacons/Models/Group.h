//
//  Group.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *groupID;
@property (strong, nonatomic) NSArray *contacts;

- (id)initWithData:(NSDictionary *)data;
- (void)updateWithData:(NSDictionary *)data;

@end
