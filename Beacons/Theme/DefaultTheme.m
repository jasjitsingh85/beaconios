//
//  DefaultTheme.m
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import "DefaultTheme.h"

@implementation DefaultTheme

- (UIColor *)cyanColor
{
    return [UIColor unnormalizedColorWithRed:92 green:206 blue:211 alpha:255];
}

- (UIColor *)orangeColor
{
    return [UIColor unnormalizedColorWithRed:254 green:216 blue:209 alpha:255];
}

- (UIColor *)darkOrangeColor
{
    return [UIColor unnormalizedColorWithRed:241 green:199 blue:172 alpha:255];
}

- (UIColor *)lightGrayColor
{
    return [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:244/255.0];
}

- (UIColor *)darkBlueColor
{
    return [UIColor unnormalizedColorWithRed:173 green:214 blue:227 alpha:255];
}

- (UIColor *)blueColor
{
    return [UIColor unnormalizedColorWithRed:219 green:237 blue:240 alpha:255];
}

- (UIColor *)darkColor
{
    return [UIColor unnormalizedColorWithRed:54 green:54 blue:57 alpha:255];
}

- (UIColor *)pinkColor
{
    return [UIColor unnormalizedColorWithRed:244 green:216 blue:209 alpha:255];
}

- (UIColor *)darkPinkColor
{
    return [UIColor unnormalizedColorWithRed:249 green:192 blue:182 alpha:255];
}

- (UIColor *)greenColor
{
    return [UIColor unnormalizedColorWithRed:227 green:335 blue:209 alpha:255];
}

- (UIColor *)darkGreenColor
{
    return [UIColor unnormalizedColorWithRed:202 green:220 blue:187 alpha:255];
}

- (UIColor *)yellowColor
{
    return [UIColor unnormalizedColorWithRed:247 green:238 blue:200 alpha:255];
}

- (UIColor *)darkYellowColor
{
    return [UIColor unnormalizedColorWithRed:236 green:217 blue:143 alpha:255];
}

- (UIColor *)redColor
{
    return [UIColor colorWithRed:234/255.0 green:109/255.0 blue:90/255.0 alpha:1.0];
}


- (UIColor *)purpleColor
{
    return [UIColor unnormalizedColorWithRed:237 green:236 blue:243 alpha:255];
}

- (UIColor *)darkPurpleColor
{
    return [UIColor unnormalizedColorWithRed:209 green:203 blue:223 alpha:255];
}

- (UIImage *)blueCellImage
{
    return [UIImage imageNamed:@"beaconCellBackgroundBlue"];
}

- (UIImage *)pinkCellImage
{
    return [UIImage imageNamed:@"beaconCellBackgroundPink"];
}

- (UIImage *)yellowCellImage
{
    return [UIImage imageNamed:@"beaconCellBackgroundYellow"];
}

- (UIImage *)greenCellImage
{
    return [UIImage imageNamed:@"beaconCellBackgroundGreen"];
}

- (UIImage *)orangeCellImage
{
    return [UIImage imageNamed:@"beaconCellBackgroundOrange"];
}

- (UIImage *)purpleCellImage
{
    return [UIImage imageNamed:@"beaconCellBackgroundPurple"];
}

- (NSString *)regularFontName
{
    return @"HelveticaNeue";
}

- (NSString *)lightFontName
{
    return @"HelveticaNeue-Light";
}

- (NSString *)boldFontName
{
    return @"HelveticaNeue-Bold";
}

- (NSString *)italicFontName
{
    return @"HelveticaNeue-LightItalic";
}

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    return [UIImage imageNamed:@"navBar"];
}

- (NSDictionary *)navigationBarTitleAndTextAttributes
{
    return @{
             UITextAttributeTextColor: [UIColor whiteColor],
             UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)],
             UITextAttributeFont: [UIFont fontWithName:[self boldFontName] size:18.0f]
             };
}

@end
