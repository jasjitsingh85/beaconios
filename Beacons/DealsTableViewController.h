//
//  DealsTableViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface DealsTableViewController : UIViewController <MKMapViewDelegate> {
    MKMapView *_mapView;
}

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) NSArray *deals;
@property (strong, nonatomic) NSArray *happyHours;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MKMapView *mapView;

@end
