//
//  Tab.h
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tab : NSObject

@property (strong, nonatomic) NSString *tabID;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end