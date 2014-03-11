//
//  BeaconMapSnapshotImageView.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/11/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "BeaconMapSnapshotImageView.h"
#import "BeaconAnnotation.h"
#import "BeaconAnnotationView.h"
#import "Theme.h"
#import "Beacon.h"

@implementation BeaconMapSnapshotImageView

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    BeaconAnnotation *annotation = [[BeaconAnnotation alloc] init];
    annotation.beacon = beacon;
    BeaconAnnotationView *beaconAnnotationView = [[BeaconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    beaconAnnotationView.primaryColor = [self primaryColorForBeacon:beacon];
    beaconAnnotationView.secondaryColor = [self secondaryColorForBeacon:beacon];
    beaconAnnotationView.active = YES;
    self.annotationViews = @[beaconAnnotationView];
    [self update];
}

- (UIColor *)primaryColorForBeacon:(Beacon *)beacon
{
    id<Theme> theme = [ThemeManager sharedTheme];
    NSArray *colors = @[[theme blueColor], [theme pinkColor], [theme yellowColor], [theme greenColor], [theme orangeColor], [theme purpleColor]];
    NSInteger idx = beacon.beaconID.integerValue % colors.count;
    UIColor *color = colors[idx];
    return color;
}

- (UIColor *)secondaryColorForBeacon:(Beacon *)beacon
{
    id<Theme> theme = [ThemeManager sharedTheme];
    NSArray *colors = @[[theme darkBlueColor], [theme darkPinkColor], [theme darkYellowColor], [theme darkGreenColor], [theme darkOrangeColor], [theme darkPurpleColor]];
    NSInteger idx =  beacon.beaconID.integerValue % colors.count;
    UIColor *color = colors[idx];
    return color;
}

@end
