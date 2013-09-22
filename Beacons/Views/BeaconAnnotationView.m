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
@property (strong, nonatomic) UIView *popsicleStick;

@end

@implementation BeaconAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.colorView = [[UIView alloc] init];
        self.colorView.backgroundColor = [[ThemeManager sharedTheme] blueColor];
        self.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.colorView.layer.shadowOpacity = 0.5;
        self.colorView.layer.shadowRadius = 2.0;
        self.colorView.layer.shadowOffset = CGSizeMake(0, 2);
        
        self.colorView.layer.cornerRadius = 6;
        [self addSubview:self.colorView];
        
        self.popsicleStick = [[UIView alloc] init];
        self.popsicleStick.backgroundColor = [UIColor colorWithRed:234/255.0 green:196/255.0 blue:149/255.0 alpha:1.0];
        self.popsicleStick.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.popsicleStick.layer.shadowOpacity = 0.5;
        self.popsicleStick.layer.shadowRadius = 2.0;
        self.popsicleStick.layer.shadowOffset = CGSizeMake(0, 2);
        self.popsicleStick.layer.cornerRadius = 5;
        [self insertSubview:self.popsicleStick belowSubview:self.colorView];
        self.frame = CGRectMake(0, 0, 50, 50);
        self.active = NO;
    }
    
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.colorView.backgroundColor = color;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    CGRect colorFrame;
    CGRect popsicleStickFrame;
    popsicleStickFrame.size = CGSizeMake(10, 36);
    popsicleStickFrame.origin.x = 0.5*(self.frame.size.width - popsicleStickFrame.size.width);
    popsicleStickFrame.origin.y = self.frame.size.height - popsicleStickFrame.size.height;
    self.popsicleStick.frame = popsicleStickFrame;
    self.popsicleStick.layer.shadowRadius = active ? 2.0 : 0.0;
    CGSize shadowOffset = active ? CGSizeMake(-0, -10) : CGSizeMake(0, 0);
    if (active) {
        colorFrame.size = CGSizeMake(36, 50);
        colorFrame.origin = CGPointMake(0.5*(self.frame.size.width - colorFrame.size.width), self.frame.size.height - colorFrame.size.height - 12);
        
    }
    else {
        colorFrame.size = CGSizeMake(36, 36);
        colorFrame.origin = CGPointMake(0.5*(self.frame.size.width - colorFrame.size.width), self.frame.size.height - colorFrame.size.height);
    }
    if (active) {
        self.popsicleStick.alpha = 1;
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.colorView.frame = colorFrame;
        self.colorView.layer.shadowOffset = shadowOffset;
        if (!active) {
            self.popsicleStick.alpha = 0;
        }
    } completion:^(BOOL finished) {
    }];
    if (active && self.superview) {
        [self.superview bringSubviewToFront:self];
    }
}




@end
