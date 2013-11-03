//
//  NSError+ServerErrorMessage.m
//  Beacons
//
//  Created by Jeffrey Ames on 11/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "NSError+ServerErrorMessage.h"

@implementation NSError (ServerErrorMessage)

- (NSString *)serverErrorMessage
{
    NSString *jsonString = self.userInfo[@"NSLocalizedRecoverySuggestion"];
    NSString *message;
    if (jsonString) {
        NSData *stringData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
        if (dictionary && dictionary.count) {
            message = dictionary[@"message"];
        }
    }
    return message;
}

@end
