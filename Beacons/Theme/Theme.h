//
//  Theme.h
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Theme <NSObject>

- (NSString *)regularFontName;
- (NSString *)boldFontName;

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;
- (NSDictionary *)navigationBarTitleAndTextAttributes;
@end

@interface ThemeManager : NSObject

+ (id <Theme>)sharedTheme;

+ (void)customizeAppAppearance;
+ (void)customizeViewAndSubviews:(UIView *)view;
+ (void)customizeLabel:(UILabel *)label;
+ (UIFont *)regularFontOfSize:(CGFloat)size;
+ (UIFont *)boldFontOfSize:(CGFloat)size;

@end
