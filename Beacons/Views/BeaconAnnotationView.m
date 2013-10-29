//
//  BeaconAnnotationView.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconAnnotationView.h"
#import "Theme.h"


@interface BeaconAnnotationView()
@property (readonly) UIImage *normalImage;
@property (readonly) UIImage *activeImage;
@property (strong, nonatomic) UIView *colorView;
@property (strong, nonatomic) UIView *colorViewLeft;
@property (strong, nonatomic) UIView *colorViewRight;
@property (strong, nonatomic) UIView *colorViewBottom;
@property (strong, nonatomic) UIView *popsicleStickTop;
@property (strong, nonatomic) UIView *popsicleStickBottom;

@end

@implementation BeaconAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.colorView = [[UIView alloc] init];
        self.colorView.backgroundColor = [[ThemeManager sharedTheme] blueColor];
        self.colorView.clipsToBounds = YES;
        self.colorViewLeft = [[UIView alloc] init];
        [self.colorView addSubview:self.colorViewLeft];
        self.colorViewRight = [[UIView alloc] init];
        [self.colorView addSubview:self.colorViewRight];
        self.colorViewBottom = [[UIView alloc] init];
        [self.colorView addSubview:self.colorViewBottom];
        
        
        self.colorView.layer.cornerRadius = 8;
        [self addSubview:self.colorView];
        
        self.popsicleStickTop = [[UIView alloc] init];
        self.popsicleStickTop.backgroundColor = [UIColor colorWithRed:234/255.0 green:196/255.0 blue:149/255.0 alpha:1.0];
        self.popsicleStickTop.layer.cornerRadius = 0;
        [self addSubview:self.popsicleStickTop];
        self.popsicleStickBottom = [[UIView alloc] init];
        self.popsicleStickBottom.backgroundColor = [UIColor colorWithRed:234/255.0 green:196/255.0 blue:149/255.0 alpha:1.0];
        self.popsicleStickBottom.layer.cornerRadius = 5;
        [self addSubview:self.popsicleStickBottom];
        self.frame = CGRectMake(0, 0, 50, 50);
        self.active = NO;
    }
    
    return self;
}

- (void)setPrimaryColor:(UIColor *)primaryColor
{
    _primaryColor = primaryColor;
    self.colorViewRight.backgroundColor = primaryColor;
}

- (void)setSecondaryColor:(UIColor *)secondaryColor
{
    _secondaryColor = secondaryColor;
    self.colorViewLeft.backgroundColor = secondaryColor;
    self.colorViewBottom.backgroundColor = [self darkerColorForColor:secondaryColor];
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    CGRect colorFrame;
    CGRect colorLeftFrame;
    CGRect colorRightFrame;
    CGRect colorBottomFrame;
    CGRect popsicleStickTopFrame;
    CGRect popsicleStickBottomFrame;
    
    if (active) {
        popsicleStickBottomFrame.size = CGSizeMake(10, 9);
        popsicleStickBottomFrame.origin.x = 0.5*(self.frame.size.width - popsicleStickBottomFrame.size.width);
        popsicleStickBottomFrame.origin.y = self.frame.size.height - popsicleStickBottomFrame.size.height;
        popsicleStickTopFrame.size = CGSizeMake(10, 8);
        popsicleStickTopFrame.origin.x = 0.5*(self.frame.size.width - popsicleStickTopFrame.size.width);
        popsicleStickTopFrame.origin.y = self.frame.size.height - popsicleStickTopFrame.size.height - popsicleStickBottomFrame.size.height + 3;
        
        colorFrame.size = CGSizeMake(31, 35);
        colorFrame.origin = CGPointMake(0.5*(self.frame.size.width - colorFrame.size.width), self.frame.size.height - colorFrame.size.height - 12);
        colorLeftFrame.size = CGSizeMake(colorFrame.size.width/2.0, colorFrame.size.height);
        colorLeftFrame.origin = CGPointMake(0, 0);
        colorRightFrame.size = CGSizeMake(colorFrame.size.width/2.0, colorFrame.size.height);
        colorRightFrame.origin = CGPointMake(colorFrame.size.width/2.0, 0);
        colorBottomFrame.size = CGSizeMake(colorFrame.size.width, 4);
        colorBottomFrame.origin = CGPointMake(0, colorFrame.size.height - colorBottomFrame.size.height);
        
    }
    else {
        popsicleStickBottomFrame.size = CGSizeMake(10, 0);
        popsicleStickBottomFrame.origin.x = 0.5*(self.frame.size.width - popsicleStickBottomFrame.size.width);
        popsicleStickBottomFrame.origin.y = self.frame.size.height - popsicleStickBottomFrame.size.height;
        popsicleStickTopFrame.size = CGSizeMake(10, 0);
        popsicleStickTopFrame.origin.x = 0.5*(self.frame.size.width - popsicleStickTopFrame.size.width);
        popsicleStickTopFrame.origin.y = self.frame.size.height - popsicleStickTopFrame.size.height - popsicleStickBottomFrame.size.height;
        
        colorFrame.size = CGSizeMake(31, 31);
        colorFrame.origin = CGPointMake(0.5*(self.frame.size.width - colorFrame.size.width), self.frame.size.height - colorFrame.size.height);
        colorLeftFrame.size = CGSizeMake(colorFrame.size.width/2.0, colorFrame.size.height);
        colorLeftFrame.origin = CGPointMake(0, 0);
        colorRightFrame.size = CGSizeMake(colorFrame.size.width/2.0, colorFrame.size.height);
        colorRightFrame.origin = CGPointMake(colorFrame.size.width/2.0, 0);
        colorBottomFrame.size = CGSizeMake(0, 0);
        colorBottomFrame.origin = CGPointMake(0, colorFrame.size.height - colorBottomFrame.size.height);
    }
    if (active) {
        self.popsicleStickTop.alpha = 1;
        self.popsicleStickBottom.alpha = 1;
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.popsicleStickBottom.frame = popsicleStickBottomFrame;
        self.popsicleStickTop.frame = popsicleStickTopFrame;
        self.colorView.frame = colorFrame;
        self.colorViewLeft.frame = colorLeftFrame;
        self.colorViewRight.frame = colorRightFrame;
        self.colorViewBottom.frame = colorBottomFrame;

        if (!active) {
            self.popsicleStickBottom.alpha = 0;
            self.popsicleStickTop.alpha = 0;
        }
    } completion:^(BOOL finished) {
    }];
    if (active && self.superview) {
        [self.superview bringSubviewToFront:self];
    }
}




@end
