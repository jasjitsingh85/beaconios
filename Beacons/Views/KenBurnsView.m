//
//  KenBurnsView.m
//  Beacons
//
//  Created by Jeff Ames on 9/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <SDWebImage/SDWebImageDownloader.h>

#import "KenBurnsView.h"
#include <stdlib.h>

#define enlargeRatio 1.1
#define imageBufer 3

enum JBSourceMode {
    JBSourceModeImages,
    //    JBSourceModeURLs,
    JBSourceModePaths
};

// Private interface
@interface KenBurnsView (){
    NSMutableArray *_imagesArray;
    CGFloat _showImageDuration;
    NSInteger _currentIndex;
    BOOL _shouldLoop;
    BOOL _isLandscape;
    
    NSTimer *_nextImageTimer;
    enum JBSourceMode _sourceMode;
}

@property (nonatomic) int currentImage;

@end


@implementation KenBurnsView

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
}

- (void) animateWithImagePaths:(NSArray *)imagePaths transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape
{
    _sourceMode = JBSourceModePaths;
    [self _startAnimationsWithData:imagePaths transitionDuration:duration loop:shouldLoop isLandscape:isLandscape];
}

- (void) animateWithImages:(NSArray *)images transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape {
    _sourceMode = JBSourceModeImages;
    [self _startAnimationsWithData:images transitionDuration:duration loop:shouldLoop isLandscape:isLandscape];
}

- (void)_startAnimationsWithData:(NSArray *)data transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape
{
    _imagesArray        = [data mutableCopy];
    _showImageDuration  = duration;
    _shouldLoop         = shouldLoop;
    _isLandscape        = isLandscape;
    
    // start at 0
    _currentIndex       = -1;
    
    self.isAnimating = YES;
    _nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [_nextImageTimer fire];
}

- (void)nextImage {
    _currentIndex++;
    
    UIImage *image = nil;
    switch (_sourceMode) {
        case JBSourceModeImages:
            image = _imagesArray[_currentIndex];
            break;
            
        case JBSourceModePaths:
            image = [UIImage imageWithContentsOfFile:_imagesArray[_currentIndex]];
            break;
    }
    
    UIImageView *imageView = nil;
    
    float originX       = -1;
    float originY       = -1;
    float zoomInX       = -1;
    float zoomInY       = -1;
    float moveX         = -1;
    float moveY         = -1;
    float frameWidth    = self.bounds.size.width;
    float frameHeight   = self.bounds.size.height;
    
    float imageWidth = image.scale/[UIScreen mainScreen].scale*image.size.width;
    float imageHeight = image.scale/[UIScreen mainScreen].scale*image.size.height;

    CGFloat fillWidth = frameWidth;
    CGFloat fillHeight = imageHeight*(frameWidth/imageWidth);
    if (fillHeight < frameHeight) {
        fillHeight = frameHeight;
        fillWidth = imageWidth*(frameHeight/imageHeight);
    }
    float optimusWidth = fillWidth*enlargeRatio;
    float optimusHeight = fillHeight*enlargeRatio;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, optimusWidth, optimusHeight)];
    imageView.backgroundColor = [UIColor blackColor];
    
    // Calcule the maximum move allowed.
    float maxMoveX = (optimusWidth - frameWidth)/2.0;
    float maxMoveY = (optimusHeight - frameHeight)/2.0;
    
    float rotation = (arc4random() % 9) / 100;
    
    switch (arc4random() % 7) {
        case 0:
            originX = 0;
            originY = 0;
            zoomInX = 1.25;
            zoomInY = 1.25;
            moveX   = -maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 1:
            originX = 0;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.10;
            zoomInY = 1.10;
            moveX   = -maxMoveX;
            moveY   = maxMoveY;
            break;
        
        case 2:
            originX = 0;
            originY = (frameHeight - optimusHeight)/2.0;
            zoomInX = 1.10;
            zoomInY = 1.10;
            moveX   = -maxMoveX;
            moveY   = maxMoveY/2.0;
            break;
            
        case 3:
            originX = frameWidth - optimusWidth;
            originY = 0;
            zoomInX = 1.30;
            zoomInY = 1.30;
            moveX   = maxMoveX;
            moveY   = -maxMoveY;
            break;
        
        case 4:
            originX = (frameWidth - optimusWidth)/2.0;
            originY = 0;
            zoomInX = 1.30;
            zoomInY = 1.30;
            moveX   = maxMoveX/2.0;
            moveY   = -maxMoveY;
            break;
            
        case 5:
            originX = frameWidth - optimusWidth;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.20;
            zoomInY = 1.20;
            moveX   = maxMoveX;
            moveY   = maxMoveY;
            break;
            
        case 6:
            originX = (frameWidth - optimusWidth)/2.0;
            originY = frameHeight - optimusHeight/2.0;
            zoomInX = 1.20;
            zoomInY = 1.20;
            moveX   = maxMoveX/2.0;
            moveY   = maxMoveY/2.0;
            break;
            
        default:
            NSLog(@"Unknown random number found in JBKenBurnsView _animate");
            break;
    }
    
    CALayer *picLayer    = [CALayer layer];
    picLayer.contents    = (id)image.CGImage;
    picLayer.anchorPoint = CGPointMake(0, 0);
    picLayer.bounds      = CGRectMake(0, 0, optimusWidth, optimusHeight);
    picLayer.position    = CGPointMake(originX, originY);
    
    [imageView.layer addSublayer:picLayer];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setType:kCATransitionFade];
    [[self layer] addAnimation:animation forKey:nil];
    
    // Remove the previous view
    if ([[self subviews] count] > 0){
        UIView *oldImageView = [[self subviews] objectAtIndex:0];
        [oldImageView removeFromSuperview];
        oldImageView = nil;
    }
    
    [self addSubview:imageView];
    
    // Generates the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_showImageDuration + 2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    CGAffineTransform rotate    = CGAffineTransformMakeRotation(rotation);
    CGAffineTransform moveRight = CGAffineTransformMakeTranslation(moveX, moveY);
    CGAffineTransform combo1    = CGAffineTransformConcat(rotate, moveRight);
    CGAffineTransform zoomIn    = CGAffineTransformMakeScale(zoomInX, zoomInY);
    CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
    imageView.transform = transform;
    [UIView commitAnimations];
    
    [self _notifyDelegate];
    
    if (_currentIndex == _imagesArray.count - 1) {
        if (_shouldLoop) {
                _currentIndex = -1;
        }else {
            [_nextImageTimer invalidate];
        }
    }
}

- (void)dealloc
{
    [_nextImageTimer invalidate];
    _nextImageTimer = nil;
}

- (void) _notifyDelegate
{
    if (_delegate) {
        if([_delegate respondsToSelector:@selector(didShowImageAtIndex:)])
        {
            [_delegate didShowImageAtIndex:_currentIndex];
        }
        
        if (_currentIndex == ([_imagesArray count] - 1) && !_shouldLoop && [_delegate respondsToSelector:@selector(didFinishAllAnimations)]) {
            [_delegate didFinishAllAnimations];
            self.isAnimating = NO;
        } 
    }
    
}

- (void)addImage:(UIImage *)image
{
    [_imagesArray addObject:image];
}

- (void)addImageWithURL:(NSURL *)url
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image) {
            [_imagesArray addObject:image];
        }
    }];
}



@end
