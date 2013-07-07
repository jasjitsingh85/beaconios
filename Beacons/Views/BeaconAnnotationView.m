//
//  BeaconAnnotationView.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconAnnotationView.h"

@interface BeaconAnnotationView()
@property (readonly) UIImage *normalImage;
@property (readonly) UIImage *activeImage;

@end

@implementation BeaconAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.image = [UIImage imageNamed:@"beaconAnnotation"];
    }
    
    return self;
}

- (UIImage *)normalImage
{
    return [UIImage imageNamed:@"beaconAnnotation"];
}

- (UIImage *)activeImage
{
    return [UIImage imageNamed:@"beaconAnnotationActive"];
}

- (void)setActive:(BOOL)active
{
    _active = active;
    self.image = active ? [self activeImage] : [self normalImage];
}




@end
