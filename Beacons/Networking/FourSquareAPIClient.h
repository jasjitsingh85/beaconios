//
//  FourSquareAPIClient.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Foursquare-iOS-API/BZFoursquare.h>
#import <Foursquare-iOS-API/BZFoursquareRequest.h>

@interface FourSquareAPIClient : NSObject

+ (FourSquareAPIClient *)sharedClient;

- (void)searchVenuesNearLocation:(CLLocation *)location query:(NSString *)query radius:(NSNumber *)radius limit:(NSNumber *)limit completion:(void (^)(id result, NSError *error))completion;

@end
