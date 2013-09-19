//
//  UIImage+Resize.h
//  Beacons
//
//  Created by Jeff Ames on 9/17/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image fitToSize:(CGSize)targetSize;

- (UIImage *)scaledToSize:(CGSize)size;
- (UIImage *)fitToSize:(CGSize)size;

@end
