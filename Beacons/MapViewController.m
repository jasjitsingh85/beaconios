//
//  MapViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MapViewController.h"
#import <AHAlertView/AHAlertView.h>
#import "BeaconCell.h"
#import "LineLayout.h"
#import "User.h"
#import "Beacon.h"
#import "BeaconAnnotation.h"
#import "BeaconAnnotationView.h"
#import "CreateBeaconViewController.h"
#import "BeaconDetailViewController.h"
#import "TextMessageManager.h"
#import "APIClient.h"
#import "Utilities.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"
#import "FindFriendsViewController.h"
#import "AppDelegate.h"

@interface MapViewController () <BeaconCellDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *beaconCollectionView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *beacons;
@property (assign, nonatomic) BOOL showCreateBeaconCell;
@property (strong, nonatomic) UIButton *createBeaconButton;
@property (strong, nonatomic) NSMutableDictionary *beaconAnnotationDictionary;

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
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizePinchOrPan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizePinchOrPan:)];
    pan.delegate = self;
    pinch.delegate = self;
    [self.mapView addGestureRecognizer:pan];
    [self.mapView addGestureRecognizer:pinch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconUpdated:) name:kNotificationBeaconUpdated object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Beacons";
    [self hideBeaconCollectionViewAnimated:NO];
    [self requestBeacons];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.createBeaconButton];
}

- (UIButton *)createBeaconButton
{
    if (!_createBeaconButton) {
        _createBeaconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"plus"];
        [_createBeaconButton setImage:buttonImage forState:UIControlStateNormal];
        _createBeaconButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [_createBeaconButton addTarget:self action:@selector(createBeaconTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createBeaconButton;
}

#pragma mark - Notifications
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self hideBeaconCollectionViewAnimated:NO];
    [self requestBeacons];
}

- (void)reloadBeacons
{
    if (self.beacons.count) {
        //add beacon annotations to map
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.beaconAnnotationDictionary = [NSMutableDictionary new];
        for (Beacon *beacon in self.beacons) {
            BeaconAnnotation *beaconAnnotation = [BeaconAnnotation new];
            beaconAnnotation.beacon = beacon;
            [self.mapView addAnnotation:beaconAnnotation];
            [self.beaconAnnotationDictionary setObject:beaconAnnotation forKey:beacon.beaconID];
        }
        self.showCreateBeaconCell = NO;
        [self centerMapOnBeacon:self.beacons[0] animated:YES];
    }
    else {
        self.showCreateBeaconCell = YES;
    }
    [self.beaconCollectionView reloadData];
    [self showBeaconCollectionViewAnimated:YES];
}

- (void)beaconUpdated:(NSNotification *)notification
{
    NSIndexPath *indexPath = [self indexPathForBeacon:notification.object];
    [self.beaconCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)hideBeaconCollectionViewAnimated:(BOOL)animated
{
    if (!self.beaconCollectionView.alpha) {
        return;
    }
    
    NSTimeInterval duration = animated ? 0.5 : 0.0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.beaconCollectionView.alpha = 0;
        self.beaconCollectionView.transform = CGAffineTransformMakeTranslation(0, -self.beaconCollectionView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)showBeaconCollectionViewAnimated:(BOOL)animated
{
    if (self.beaconCollectionView.alpha) {
        return;
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

- (void)deactivateAllBeaconAnnotationViews
{
    for (BeaconAnnotation *annotation in self.mapView.annotations) {
        BeaconAnnotationView *view = (BeaconAnnotationView *)[self.mapView viewForAnnotation:annotation];
        view.active = NO;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numItems = self.beacons.count + self.showCreateBeaconCell;
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    cell.delegate = self;
    if (!self.showCreateBeaconCell) {
        cell.beacon = [self beaconForIndexPath:indexPath];
    }
    else {
        [cell configureEmptyBeacon];
    }
    
    return cell;
}

- (Beacon *)beaconForIndexPath:(NSIndexPath *)indexPath
{
    return self.beacons[indexPath.row];
}

- (NSIndexPath *)indexPathForBeacon:(Beacon *)beacon
{
    NSInteger row = [self.beacons indexOfObject:beacon];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    return indexPath;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Beacon *beacon = [self beaconForIndexPath:indexPath];
    BeaconDetailViewController *beaconDetailViewController = [BeaconDetailViewController new];
    beaconDetailViewController.beacon = beacon;
    [self.navigationController pushViewController:beaconDetailViewController animated:YES];
}

#pragma mark - BeaconCellDelegate
- (void)beaconCellTextButtonTouched:(BeaconCell *)beaconCell
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self messageRecipients:@[beacon.creator.phoneNumber]];
}

- (void)beaconCellDirectionsButtonTouched:(BeaconCell *)beaconCell
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    [Utilities launchMapDirectionsToCoordinate:beacon.coordinate addressDictionary:nil destinationName:beacon.beaconDescription];
    [[AnalyticsManager sharedManager] getDirections:AnalyticsLocationMapView];
}

- (void)beaconCellInfoButtonTouched:(BeaconCell *)beaconCell
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    BeaconDetailViewController *beaconDetailViewController = [BeaconDetailViewController new];
    beaconDetailViewController.beacon = beacon;
    [self.navigationController pushViewController:beaconDetailViewController animated:YES];
}

- (void)beaconCellConfirmButtonTouched:(BeaconCell *)beaconCell confirmed:(BOOL)confirmed
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    if (confirmed) {
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Joined Beacon" message:@"Would you like to notify friends?"];
        [alert setCancelButtonTitle:@"Not Now" block:^{
            [self confirmBeacon:beacon notifyFriends:NO];
        }];
        [alert addButtonWithTitle:@"OK" block:^{
            [self confirmBeacon:beacon notifyFriends:YES];
        }];
        [alert show];
        [[APIClient sharedClient] confirmBeacon:beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[AnalyticsManager sharedManager] acceptInvite:AnalyticsLocationMapView beacon:beacon];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
    else {
        if (beacon.isUserBeacon) {
            [self.beaconCollectionView reloadItemsAtIndexPaths:@[[self indexPathForBeacon:beacon]]];
            [[[UIAlertView alloc] initWithTitle:@"This is your own beacon" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else {
            beacon.userAttending = NO;
            [[APIClient sharedClient] cancelBeacon:beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[[UIAlertView alloc] initWithTitle:@"You have left this beacon" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Fail" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
    }
}

- (void)beaconCellInviteMoreButtonTouched:(BeaconCell *)beaconCell
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    FindFriendsViewController *findFriendsViewController = [FindFriendsViewController new];
    findFriendsViewController.selectedContacts = beacon.invited;
    findFriendsViewController.inactiveContacts = beacon.invited;
    findFriendsViewController.delegate = self;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (void)beaconCellCreateBeaconButtonTouched:(BeaconCell *)beaconCell
{
    CreateBeaconViewController *createBeaconViewController = [CreateBeaconViewController new];
    [self.navigationController pushViewController:createBeaconViewController animated:YES];
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
    //we want to center the map a little above the beacon. If we center on the beacon
    //the beacon collection view occludes the beacon annotation
    MKMapView *tmpMapView = [[MKMapView alloc] initWithFrame:self.mapView.frame];
    CLLocationDistance distance = 500 + (arc4random() % 2000);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(beacon.coordinate, distance, distance);
    [tmpMapView setRegion:region];
    
    CGPoint adjustedCenter = CGPointMake(tmpMapView.center.x, tmpMapView.center.y - 75);
    CLLocationCoordinate2D adjustedCenterCoordinate = [tmpMapView convertPoint:adjustedCenter toCoordinateFromView:tmpMapView];
    MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance(adjustedCenterCoordinate, distance, distance);
    [self.mapView setRegion:adjustedRegion animated:animated];
    
    [self deactivateAllBeaconAnnotationViews];
    BeaconAnnotationView *view = (BeaconAnnotationView *)[self.mapView viewForAnnotation:[self annotationForBeacon:beacon]];
    if (view) {
        view.active = YES;
    }
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
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beaconAnnotationViewTapped:)];
            tapGesture.numberOfTapsRequired = 1;
            [customPinView addGestureRecognizer:tapGesture];
            
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

- (void)beaconAnnotationViewTapped:(id)sender
{
    BeaconAnnotationView *beaconAnnotationView = (BeaconAnnotationView *)[sender view];
    //deactivate other annotions
    [self deactivateAllBeaconAnnotationViews];
    beaconAnnotationView.active = YES;
    
    [self showBeaconCollectionViewAnimated:YES];
    BeaconAnnotation *beaconAnnotation = beaconAnnotationView.annotation;
    NSIndexPath *indexPath = [self indexPathForBeacon:beaconAnnotation.beacon];
    [self.beaconCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self centerMapOnBeacon:beaconAnnotation.beacon animated:YES];
}

- (BeaconAnnotation *)annotationForBeacon:(Beacon *)beacon
{
    return self.beaconAnnotationDictionary[beacon.beaconID];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)didRecognizePinchOrPan:(id)sender
{
    [self hideBeaconCollectionViewAnimated:YES];
    for (BeaconAnnotation *annotation in self.mapView.annotations) {
        BeaconAnnotationView *view = (BeaconAnnotationView *)[self.mapView viewForAnnotation:annotation];
        view.active  = NO;
    }
}

#pragma mark - FindFriendsViewControllerDelegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
{
    [findFriendsViewController.navigationController popToViewController:self animated:YES];
    [[APIClient sharedClient] inviteMoreContacts:contacts toBeacon:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[[UIAlertView alloc] initWithTitle:@"Invited more contacts" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Fail" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)confirmBeacon:(Beacon *)beacon notifyFriends:(BOOL)notify
{
    if (notify) {
        CreateBeaconViewController *createBeaconViewController = [CreateBeaconViewController new];
        createBeaconViewController.beacon = beacon;
        [self.navigationController pushViewController:createBeaconViewController animated:YES];
    }
    else {
        //set invited list to empty
        beacon.invited = @[];
        [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
        [[APIClient sharedClient] postBeacon:beacon success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
            [self requestBeacons];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"to create beacon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

#pragma mark - Networking
- (void)requestBeacons
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getPath:@"beacon/follow/" parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                                  NSMutableArray *beacons = [NSMutableArray new];
                                  for (NSDictionary *beaconData in responseObject) {
                                      Beacon *beacon = [[Beacon alloc] initWithData:beaconData];
                                      [beacons addObject:beacon];
                                  }
                                  self.beacons = [NSArray arrayWithArray:beacons];
                                  [self performSelectorOnMainThread:@selector(reloadBeacons) withObject:nil waitUntilDone:NO];
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                              }];
}

#pragma mark - Button Events
- (void)createBeaconTouched:(id)sender
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [self.navigationController pushViewController:appDelegate.createBeaconViewController animated:YES];
}

@end
