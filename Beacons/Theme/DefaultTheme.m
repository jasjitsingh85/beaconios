//
//  DefaultTheme.m
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import "DefaultTheme.h"

@implementation DefaultTheme

- (NSString *)regularFontName
{
    return @"Lato-Regular";
}

- (NSString *)boldFontName
{
    return @"Lato-Bold";
}

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    return [UIImage imageNamed:@"navBar"];
}

- (NSDictionary *)navigationBarTitleAndTextAttributes
{
    return @{
             UITextAttributeTextColor: [UIColor whiteColor],
             UITextAttributeTextShadowColor: [UIColor blackColor],
             UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)],
             UITextAttributeFont: [UIFont fontWithName:[self boldFontName] size:20.0f]
             };
}

@end
