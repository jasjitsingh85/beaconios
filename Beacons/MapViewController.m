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

@interface MapViewController () <BeaconCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *beaconCollectionView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *beacons;
@property (assign, nonatomic) BOOL showCreateBeaconCell;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconUpdated:) name:kNotificationBeaconUpdated object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Beacons";
    [self hideBeaconCollectionViewAnimated:NO];
    [self requestBeacons];
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


- (void)createTestBeacons
{
    NSArray *userFirstNames = @[@"Jeff", @"Jas", @"Kamran"];
    NSArray *userLastNames = @[@"Ames", @"Singh", @"Munshi"];
    NSArray *descriptions = @[@"Smoke weed at my house", @"go to a pool party with bitches", @"college freshman orgy"];
    NSArray *addresses = @[@"14 Washington St.", @"201 E. Columbia", @"69 1st Ave."];
    NSArray *phoneNumbers = @[@"5555555555", @"6176337532", @"6502245573"];
    NSArray *latitudes = @[@47.573283, @47.559384, @47.576526];
    NSArray *longitudes = @[@-122.229424, @-122.288132, @-122.383575];
    NSMutableArray *users = [NSMutableArray new];
    NSMutableArray *beacons = [NSMutableArray new];
    for (NSInteger i=0; i<userFirstNames.count; i++) {
        User *user = [User new];
        user.firstName = userFirstNames[i];
        user.lastName = userLastNames[i];
        user.phoneNumber = phoneNumbers[i];
        [users addObject:user];
        
        Beacon *beacon = [Beacon new];
        beacon.creator = user;
        beacon.coordinate = CLLocationCoordinate2DMake([latitudes[i] floatValue], [longitudes[i] floatValue]);
        beacon.beaconDescription = descriptions[i];
        beacon.address = addresses[i];
        [beacons addObject:beacon];
        
        BeaconAnnotation *beaconAnnotation = [BeaconAnnotation new];
        beaconAnnotation.beacon = beacon;
    }
    self.beacons = [[NSArray alloc] initWithArray:beacons];

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
//        [[APIClient sharedClient] confirmBeacon:beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [[[UIAlertView alloc] initWithTitle:@"Confirmed" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            [[AnalyticsManager sharedManager] acceptInvite:AnalyticsLocationMapView beacon:beacon];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [[[UIAlertView alloc] initWithTitle:@"Fail" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }];
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

@end
