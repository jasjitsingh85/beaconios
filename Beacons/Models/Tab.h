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
@property (assign, nonatomic) BOOL isClaimed;
@property (assign, nonatomic) NSString *subtotal;
@property (assign, nonatomic) NSString *tax;
@property (assign, nonatomic) NSString *convenienceFee;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end