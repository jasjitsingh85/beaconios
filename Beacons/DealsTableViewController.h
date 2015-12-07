//
//  DealsTableViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FilterViewController.h"

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

static const double HOTSPOT_HEIGHT = 80;
static const double NON_HOTSPOT_HEIGHT = 42;

@interface DealsTableViewController : UIViewController <MKMapViewDelegate> {
    MKMapView *_mapView;
}

//@property (strong, nonatomic) NSArray *events;
//@property (strong, nonatomic) NSArray *selectedDeals;
//@property (strong, nonatomic) NSArray *hotspots;
//@property (strong, nonatomic) NSArray *happyHours;
@property (strong, nonatomic) NSArray *allVenues;
@property (strong, nonatomic) NSArray *selectedVenues;
//@property (strong, nonatomic) NSArray *rewards;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MKMapView *mapView;

@end
