//
//  MapViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AHAlertView/AHAlertView.h>
#import "BeaconCell.h"
#import "LineLayout.h"
#import "User.h"
#import "Beacon.h"
#import "BeaconAnnotation.h"
#import "BeaconAnnotationView.h"
#import "SetBeaconViewController.h"
#import "TextMessageManager.h"
#import "APIClient.h"
#import "Utilities.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"
#import "FindFriendsViewController.h"
#import "AppDelegate.h"
#import "LocationTracker.h"
#import "Theme.h"
#import "BeaconManager.h"
#import "BeaconProfileViewController.h"
#import "EmptyBeaconViewController.h"
#import "NavigationBarTitleLabel.h"

@interface MapViewController () <BeaconCellDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *beaconCollectionView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *beacons;
@property (strong, nonatomic) IBOutlet UIButton *createBeaconButton;
@property (strong, nonatomic) NSMutableDictionary *beaconAnnotationDictionary;
@property (readonly, nonatomic) NSArray *beaconAnnotations;
@property (strong, nonatomic) Beacon *highlightedBeacon;
@property (strong, nonatomic) EmptyBeaconViewController *emptyBeaconViewController;
@property (assign, nonatomic) BOOL inEmptyBeaconMode;
@property (strong, nonatomic) NSNumber *colorOffset;

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
    
    self.createBeaconButton.titleLabel.font = [ThemeManager regularFontOfSize:20];
    self.createBeaconButton.backgroundColor = [UIColor colorWithRed:120/255.0 green:183/255.0 blue:200/255.0 alpha:1.0];
    UIImage *createBeaconImage = [UIImage imageNamed:@"plus"];
    [self.createBeaconButton setImage:createBeaconImage forState:UIControlStateNormal];
    CGFloat widthOfTitleAndImage = createBeaconImage.size.width + [self.createBeaconButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.createBeaconButton.titleLabel.font}].width;
    self.createBeaconButton.imageEdgeInsets = UIEdgeInsetsMake(0, -widthOfTitleAndImage/4.0, 0, 0);
    [self.createBeaconButton addTarget:self action:@selector(createBeaconTouched:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self exitEmptyBeaconMode:YES];
    if (![self hasActiveBeacons]) {
        [self hideBeaconCollectionViewAnimated:NO];
        [self requestBeaconsShowLoadingIndicator:YES];
    }
    else {
        [self requestBeaconsShowLoadingIndicator:NO];
    }
    
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:titleImage]];
}

- (NSNumber *)colorOffset
{
    if (!_colorOffset) {
        NSInteger offset = arc4random_uniform(6);
        _colorOffset = [NSNumber numberWithInteger:offset];
    }
    return _colorOffset;
}

- (NSArray *)beaconAnnotations
{
    NSArray *beaconAnnotations = [self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[BeaconAnnotation class]];
    }]];
    return beaconAnnotations;
}

- (BOOL)hasActiveBeacons
{
    BOOL hasActiveBeacons = NO;
    if (self.beacons) {
        NSPredicate *expirePredicate = [NSPredicate predicateWithFormat:@"expirationDate > %@", [NSDate date]];
        NSArray *unexpiredBeacons = [self.beacons filteredArrayUsingPredicate:expirePredicate];
        hasActiveBeacons = unexpiredBeacons.count;
    }
    return hasActiveBeacons;
}

#pragma mark - Empty Beacon
- (void)enterEmptyBeaconMode:(BOOL)animated
{
    if (self.inEmptyBeaconMode) {
        return;
    }
    self.inEmptyBeaconMode = YES;
    self.emptyBeaconViewController = [[EmptyBeaconViewController alloc] init];
    [self addChildViewController:self.emptyBeaconViewController];
    [self.view addSubview:self.emptyBeaconViewController.view];
    self.emptyBeaconViewController.topView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
    self.emptyBeaconViewController.midView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    self.emptyBeaconViewController.bottomView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.emptyBeaconViewController.topView.transform = CGAffineTransformIdentity;
        self.emptyBeaconViewController.bottomView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:duration delay:duration options:0 animations:^{
        self.emptyBeaconViewController.midView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)exitEmptyBeaconMode:(BOOL)animated
{
    if (!self.inEmptyBeaconMode) {
        return;
    }
    self.inEmptyBeaconMode = NO;
    [self.emptyBeaconViewController.view removeFromSuperview];
    [self.emptyBeaconViewController removeFromParentViewController];
    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.emptyBeaconViewController.topView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
        self.emptyBeaconViewController.bottomView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
    }];
    [UIView animateWithDuration:duration delay:duration options:0 animations:^{
        self.emptyBeaconViewController.midView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    } completion:nil];
}

#pragma mark - Notifications
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self hideBeaconCollectionViewAnimated:NO];
    [self requestBeaconsShowLoadingIndicator:YES];
}

- (void)reloadBeacons
{
    if (self.beacons.count) {
        [self exitEmptyBeaconMode:YES];
        //add beacon annotations to map
        [self.mapView removeAnnotations:self.beaconAnnotations];
        self.beaconAnnotationDictionary = [NSMutableDictionary new];
        for (Beacon *beacon in self.beacons) {
            BeaconAnnotation *beaconAnnotation = [BeaconAnnotation new];
            beaconAnnotation.beacon = beacon;
            [self.mapView addAnnotation:beaconAnnotation];
            [self.beaconAnnotationDictionary setObject:beaconAnnotation forKey:beacon.beaconID];
        }
        [self centerMapOnBeacon:self.beacons[0] animated:YES];
        BeaconAnnotation *beaconAnnotation = [self annotationForBeacon:self.beacons[0]];
        BeaconAnnotationView *annotationView = (BeaconAnnotationView *)[self mapView:self.mapView viewForAnnotation:beaconAnnotation];
        annotationView.active = YES;
        NSLog(@"anno view %@", annotationView);
    }
    else {
        [self enterEmptyBeaconMode:YES];
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
    for (BeaconAnnotation *annotation in self.beaconAnnotations) {
        BeaconAnnotationView *view = (BeaconAnnotationView *)[self.mapView viewForAnnotation:annotation];
        view.active = NO;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numItems = self.beacons.count;
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    cell.delegate = self;
    cell.beacon = [self beaconForIndexPath:indexPath];
    [cell configureForBeacon:cell.beacon atIndexPath:indexPath];
    cell.primaryColor = [self primaryColorForIndexPath:indexPath];
    cell.secondaryColor = [self secondaryColorForIndexPath:indexPath];
    
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
    if (!self.beacons.count) {
        return;
    }
    Beacon *beacon = [self beaconForIndexPath:indexPath];
    BeaconProfileViewController *beaconProfileViewController = [[BeaconProfileViewController alloc] init];
    beaconProfileViewController.beacon = beacon;
    [self.navigationController pushViewController:beaconProfileViewController animated:YES];
}

#pragma mark - BeaconCellDelegate
- (void)beaconCellTextButtonTouched:(BeaconCell *)beaconCell
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self messageRecipients:@[beacon.creator.phoneNumber]];
}

- (void)beaconCellInfoButtonTouched:(BeaconCell *)beaconCell
{
    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
    BeaconProfileViewController *beaconProfileViewController = [[BeaconProfileViewController alloc] init];
    beaconProfileViewController.beacon = beacon;
    [self.navigationController pushViewController:beaconProfileViewController animated:YES];
}

- (void)beaconCellInviteMoreButtonTouched:(BeaconCell *)beaconCell
{
//    Beacon *beacon = [self beaconForIndexPath:[self.beaconCollectionView indexPathForCell:beaconCell]];
//    FindFriendsViewController *findFriendsViewController = [FindFriendsViewController new];
//    findFriendsViewController.selectedContacts = beacon.invited;
//    findFriendsViewController.inactiveContacts = beacon.invited;
//    findFriendsViewController.delegate = self;
//    [self.navigationController pushViewController:findFriendsViewController animated:YES];
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
    self.highlightedBeacon = beacon;
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
        BeaconAnnotation *beaconAnnotation = (BeaconAnnotation *)annotation;
        // try to dequeue an existing pin view first
        static NSString *BeaconAnnotationIdentifier = @"beaconAnnotationIdentifier";
        
        BeaconAnnotationView *pinView =
        (BeaconAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:BeaconAnnotationIdentifier];
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            pinView = [[BeaconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:BeaconAnnotationIdentifier];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = NO;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beaconAnnotationViewTapped:)];
            tapGesture.numberOfTapsRequired = 1;
            [pinView addGestureRecognizer:tapGesture];
            pinView.active = [beaconAnnotation.beacon isEqual:self.highlightedBeacon];
        }
        pinView.annotation = beaconAnnotation;
        pinView.primaryColor = [self primaryColorForIndexPath:[self indexPathForBeacon:beaconAnnotation.beacon]];
        pinView.secondaryColor = [self secondaryColorForIndexPath:[self indexPathForBeacon:beaconAnnotation.beacon]];
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
    for (BeaconAnnotation *annotation in self.beaconAnnotations) {
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
        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Something went wrong when inviting your friends" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - Networking
- (void)requestBeaconsShowLoadingIndicator:(BOOL)showLoadingIndicator
{
    if (showLoadingIndicator) {
        [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    }
    [[BeaconManager sharedManager] updateBeacons:^(NSArray *beacons) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        self.beacons = [NSArray arrayWithArray:beacons];
        [self performSelectorOnMainThread:@selector(reloadBeacons) withObject:nil waitUntilDone:NO];
    } failure:^(NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

#pragma mark - Button Events
- (void)createBeaconTouched:(id)sender
{
    SetBeaconViewController *setBeaconViewController = [[SetBeaconViewController alloc] init];
    [self.navigationController pushViewController:setBeaconViewController animated:YES];
}

#pragma mark - UI
- (UIColor *)primaryColorForIndexPath:(NSIndexPath *)indexPath
{
    id<Theme> theme = [ThemeManager sharedTheme];
    NSArray *colors = @[[theme blueColor], [theme pinkColor], [theme yellowColor], [theme greenColor], [theme orangeColor], [theme purpleColor]];
    NSInteger idx = (self.colorOffset.integerValue + indexPath.row) % colors.count;
    UIColor *color = colors[idx];
    return color;
}

- (UIColor *)secondaryColorForIndexPath:(NSIndexPath *)indexPath
{
    id<Theme> theme = [ThemeManager sharedTheme];
    NSArray *colors = @[[theme darkBlueColor], [theme darkPinkColor], [theme darkYellowColor], [theme darkGreenColor], [theme darkOrangeColor], [theme darkPurpleColor]];
    NSInteger idx = (self.colorOffset.integerValue + indexPath.row) % colors.count;
    UIColor *color = colors[idx];
    return color;
}

@end
