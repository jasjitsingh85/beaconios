//
//  Theme.m
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import "Theme.h"
#import "DefaultTheme.h"

@implementation ThemeManager

+ (id <Theme>)sharedTheme
{
    static id <Theme> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme:
        sharedTheme = [[DefaultTheme alloc] init];
    });
    
    return sharedTheme;
}

#pragma mark - Fonts
+ (UIFont *)regularFontOfSize:(CGFloat)size
{
    NSString *regularFontName = [[self sharedTheme] regularFontName];
    return [UIFont fontWithName:regularFontName size:size];
}

+ (UIFont *)boldFontOfSize:(CGFloat)size
{
    NSString *boldFontName = [[self sharedTheme] boldFontName];
    return [UIFont fontWithName:boldFontName size:size];
}

@end
