//
//  Theme.m
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import "Theme.h"
#import "DefaultTheme.h"
#import "CenterNavigationController.h"

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

#pragma mark - Costumize Appearance
+ (void)customizeAppAppearance
{
    id <Theme> theme = [self sharedTheme];
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[CenterNavigationController class], nil];
    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setShadowImage:[[UIImage alloc] init]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    navigationBarAppearance.titleTextAttributes = [theme navigationBarTitleAndTextAttributes];
}

+ (void)customizeViewAndSubviews:(UIView *)view
{
    if ([view isKindOfClass:[UILabel class]]) {
        [ThemeManager customizeLabel:(UILabel *)view];
    }
    for (UIView *subview in view.subviews) {
        [ThemeManager customizeViewAndSubviews:subview];
    }
}

+ (void)customizeLabel:(UILabel *)label
{
    id <Theme> theme = [self sharedTheme];
    label.font = [UIFont fontWithName:[theme regularFontName] size:label.font.pointSize];
}

#pragma mark - Fonts
+ (UIFont *)regularFontOfSize:(CGFloat)size
{
    NSString *regularFontName = [[self sharedTheme] regularFontName];
    return [UIFont fontWithName:regularFontName size:size];
}

+ (UIFont *)lightFontOfSize:(CGFloat)size
{
    NSString *lightFontName = [[self sharedTheme] lightFontName];
    return [UIFont fontWithName:lightFontName size:size];
}

+ (UIFont *)italicFontOfSize:(CGFloat)size
{
    NSString *italicFontName = [[self sharedTheme] italicFontName];
    return [UIFont fontWithName:italicFontName size:size];
}

+ (UIFont *)boldFontOfSize:(CGFloat)size
{
    NSString *boldFontName = [[self sharedTheme] boldFontName];
    return [UIFont fontWithName:boldFontName size:size];
}

@end
