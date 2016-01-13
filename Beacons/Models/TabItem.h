//
//  TabItem.h
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tab;

@interface TabItem : NSObject

@property (strong, nonatomic) Tab *tab;
@property (strong, nonatomic) NSString *menuItemID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *price;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end