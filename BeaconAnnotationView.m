//
//  BeaconAnnotationView.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconAnnotationView.h"

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


@end
