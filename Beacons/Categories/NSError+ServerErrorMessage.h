
//
//  NSError+ServerErrorMessage.h
//  Beacons
//
//  Created by Jeffrey Ames on 11/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ServerErrorMessage)

- (NSString *)serverErrorMessage;

@end
