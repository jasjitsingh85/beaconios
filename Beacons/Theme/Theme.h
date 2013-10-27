//
//  Theme.h
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Theme <NSObject>

- (UIColor *)lightGrayColor;
- (UIColor *)cyanColor;
- (UIColor *)orangeColor;
- (UIColor *)blueColor;
- (UIColor *)greenColor;
- (UIColor *)purpleColor;
- (UIColor *)redColor;
- (UIColor *)yellowColor;
- (UIColor *)pinkColor;
- (UIColor *)darkColor;
- (UIColor *)darkBlueColor;
- (UIColor *)darkGreenColor;
- (UIColor *)darkYellowColor;
- (UIColor *)darkPurpleColor;
- (UIColor *)darkOrangeColor;
- (UIColor *)darkPinkColor;
- (UIImage *)blueCellImage;
- (UIImage *)pinkCellImage;
- (UIImage *)yellowCellImage;
- (UIImage *)greenCellImage;
- (UIImage *)orangeCellImage;
- (UIImage *)purpleCellImage;
- (NSString *)regularFontName;
- (NSString *)lightFontName;
- (NSString *)italicFontName;
- (NSString *)boldFontName;
- (NSString *)titleFontName;
- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;
- (NSDictionary *)navigationBarTitleAndTextAttributes;
@end

@interface ThemeManager : NSObject

+ (id <Theme>)sharedTheme;

+ (void)customizeAppAppearance;
+ (void)customizeViewAndSubviews:(UIView *)view;
+ (void)customizeLabel:(UILabel *)label;
+ (UIFont *)regularFontOfSize:(CGFloat)size;
+ (UIFont *)lightFontOfSize:(CGFloat)size;
+ (UIFont *)boldFontOfSize:(CGFloat)size;
+ (UIFont *)italicFontOfSize:(CGFloat)size;
+ (UIFont *)titleFontOfSize:(CGFloat)size;

@end
