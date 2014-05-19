//
//  NSURL+InterApp.m
//  HappyHours
//
//  Created by Jeffrey Ames on 5/7/14.
//  Copyright (c) 2014 hotspot. All rights reserved.
//

#import "NSURL+InterApp.h"

@implementation NSURL (InterApp)

+ (id)urlWithAppURLScheme:(NSString *)appURLScheme parameters:(NSDictionary *)parameters
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:appURLScheme];
    [urlString appendString:@"://?"];
    NSArray *keys = parameters.allKeys;
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = parameters[obj];
        if ([value isKindOfClass:[NSString class]]) {
            value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [urlString appendString:[NSString stringWithFormat:@"%@=%@", obj, value]];
        if (idx < keys.count - 1) {
            [urlString appendString:@"&"];
        }
    }];
    return [NSURL URLWithString:urlString];
}

- (NSDictionary *)queryParameters
{
    NSMutableDictionary *queryParamers = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [self.query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        value = [value stringByRemovingPercentEncoding];
        
        [queryParamers setObject:value forKey:key];
    }
    return queryParamers;
}

@end
