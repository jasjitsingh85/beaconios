//
//  NSURL+InterApp.h
//  HappyHours
//
//  Created by Jeffrey Ames on 5/7/14.
//  Copyright (c) 2014 hotspot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (InterApp)

+ (id)urlWithAppURLScheme:(NSString *)appURLScheme parameters:(NSDictionary *)parameters;
- (NSDictionary *)queryParameters;

@end
