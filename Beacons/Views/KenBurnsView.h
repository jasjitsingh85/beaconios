//
//  KenBurnsView.h
//  Beacons
//
//  Created by Jeff Ames on 9/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class KenBurnsView;

#pragma - KenBurnsViewDelegate
@protocol KenBurnsViewDelegate <NSObject>
@optional
- (void)didShowImageAtIndex:(NSUInteger)index;
- (void)didFinishAllAnimations;
@end

@interface KenBurnsView : UIView

@property (weak, nonatomic) id<KenBurnsViewDelegate> delegate;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) BOOL isLooping;
@property (assign, nonatomic) BOOL isLandscape;
@property (assign, nonatomic) NSTimeInterval animationDuration;

- (void)addImage:(UIImage *)image;
- (void)addImageWithURL:(NSURL *)url;
- (void) animateWithImagePaths:(NSArray *)imagePaths transitionDuration:(float)time loop:(BOOL)isLoop isLandscape:(BOOL)isLandscape;
- (void) animateWithImages:(NSArray *)images transitionDuration:(float)time loop:(BOOL)isLoop isLandscape:(BOOL)isLandscape;

@end
