//
//  MapViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MapViewController.h"
#import "BeaconCell.h"
#import "LineLayout.h"
#import "User.h"
#import "Beacon.h"
#import "BeaconAnnotation.h"
#import "BeaconAnnotationView.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *beaconCollectionView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *beacons;

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.beaconCollectionView.delegate = self;
    self.beaconCollectionView.dataSource = self;
    [self.beaconCollectionView registerClass:[BeaconCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    //initially hide beacon collection view
    self.beaconCollectionView.alpha = 0;
    self.beaconCollectionView.backgroundColor = [UIColor clearColor];
    self.beaconCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.beaconCollectionView.collectionViewLayout invalidateLayout];
    self.beaconCollectionView.collectionViewLayout = [LineLayout new];
    
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    
    [self createTestBeacons];
    [self.beaconCollectionView reloadData];
    [self showBeaconCollectionViewAnimated:YES];
    [self centerMapOnBeacon:self.beacons[0] animated:YES];
}

- (void)createTestBeacons
{
    NSArray *userFirstNames = @[@"Jeff", @"Jas", @"Kamran"];
    NSArray *userLastNames = @[@"Ames", @"Singh", @"Munshi"];
    NSArray *latitudes = @[@47.573283, @47.559384, @47.576526];
    NSArray *longitudes = @[@-122.229424, @-122.288132, @-122.383575];
    NSMutableArray *users = [NSMutableArray new];
    NSMutableArray *beacons = [NSMutableArray new];
    for (NSInteger i=0; i<userFirstNames.count; i++) {
        User *user = [User new];
        user.firstName = userFirstNames[i];
        user.lastName = userLastNames[i];
        [users addObject:user];
        
        Beacon *beacon = [Beacon new];
        beacon.creator = user;
        beacon.coordinate = CLLocationCoordinate2DMake([latitudes[i] floatValue], [longitudes[i] floatValue]);
        [beacons addObject:beacon];
        
        BeaconAnnotation *beaconAnnotation = [BeaconAnnotation new];
        beaconAnnotation.beacon = beacon;
    }
    self.beacons = [[NSArray alloc] initWithArray:beacons];

}

- (void)showBeaconCollectionViewAnimated:(BOOL)animated
{
    if (animated) {
        self.beaconCollectionView.alpha = 0;
        self.beaconCollectionView.transform = CGAffineTransformMakeTranslation(0, -self.beaconCollectionView.frame.size.height);
    }
    NSTimeInterval duration = animated ? 0.5 : 0.0;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.beaconCollectionView.alpha = 1;
                         self.beaconCollectionView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.beacons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    Beacon *beacon = self.beacons[indexPath.row];
    cell.beacon = beacon;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath = [self.beaconCollectionView indexPathForItemAtPoint:CGPointMake(self.beaconCollectionView.center.x + self.beaconCollectionView.contentOffset.x, self.beaconCollectionView.center.y)];
    Beacon *beacon = self.beacons[indexPath.row];
    [self centerMapOnBeacon:beacon animated:YES];
}

- (void)centerMapOnBeacon:(Beacon *)beacon animated:(BOOL)animated
{
    CLLocationDistance distance = 1000 + (arc4random() % 10000);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(beacon.coordinate, distance, distance);
    [self.mapView setRegion:region animated:animated];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    BeaconAnnotation *beaconAnnotation = [BeaconAnnotation new];
    beaconAnnotation.beacon = beacon;
    [self.mapView addAnnotation:beaconAnnotation];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // handle our three custom annotations
    //
    if ([annotation isKindOfClass:[BeaconAnnotation class]]) // for Golden Gate Bridge
    {
        // try to dequeue an existing pin view first
        static NSString *BeaconAnnotationIdentifier = @"beaconAnnotationIdentifier";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:BeaconAnnotationIdentifier];
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            BeaconAnnotationView *customPinView = [[BeaconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:BeaconAnnotationIdentifier];
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = NO;
            
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
 
    
    return nil;
}

@end
