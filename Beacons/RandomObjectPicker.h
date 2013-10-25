//
//  RandomObjectPicker.h
//  Beacons
//
//  Created by Jeff Ames on 10/24/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomObjectPicker : NSObject

@property (strong, nonatomic) NSArray *objectOptions;

- (id)getRandomObject;
- (id)initWithObjectOptions:(NSArray *)options;

@end
