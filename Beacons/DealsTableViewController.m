//
//  DealsTableViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealsTableViewController.h"
#import "UIView+BounceAnimation.h"
//#import <FacebookSDK.h>
#import "UIView+Shadow.h"
#import "SetDealViewController.h"
#import "CenterNavigationController.h"
#import "AppDelegate.h"
#import "DealTableViewCell.h"
#import "HappyHourTableViewCell.h"
//#import "DealTableViewEventCell.h"
//#import "BounceButton.h"
#import "APIClient.h"
#import "LocationTracker.h"
#import "Deal.h"
#import "Venue.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"
#import "RewardsViewController.h"
#import "UIButton+HSNavButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MaveSDK.h>
#import <MapKit/MapKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Utilities.h"
#import "HotspotAnnotation.h"
#import "HappyHour.h"
#import "HappyHourVenue.h"

@interface DealsTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

//@property (strong, nonatomic) DealTableViewEventCell *currentEventCell;
@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) UIView *enableLocationView;
@property (strong, nonatomic) UIView *dealTypeToggle;
@property (strong, nonatomic) NSDate *lastUpdatedDeals;
@property (strong, nonatomic) UIButton *enableLocationButton;
//@property (strong, nonatomic) UIButton *textOneFriend;
//@property (strong, nonatomic) UIButton *textManyFriends;
@property (strong, nonatomic) UILabel *enableLocationLabel;
@property (strong, nonatomic) UILabel *mapLabel;
//@property (assign, nonatomic) BOOL hasEvents;
@property (assign, nonatomic) BOOL loadingDeals;
@property (assign, nonatomic) BOOL locationEnabled;
@property (assign, nonatomic) BOOL mapViewFullScreen;
//@property (assign, nonatomic) BOOL groupDeal;
//@property (strong, nonatomic) NSArray *allDeals;
@property (strong, nonatomic) Deal *dealInView;
@property (strong, nonatomic) RewardsViewController *rewardsViewController;
@property (assign, nonatomic) NSInteger *currentTopRow;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) UIView *redoSearchContainer;
@property (nonatomic, strong) UIButton *redoSearchButton;


@end

@implementation DealsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
    [self addChildViewController:self.rewardsViewController];
    [self.rewardsViewController updateRewardsScore];
    
//    CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 124, [[UIScreen mainScreen] bounds].size.width, 60);
//    self.dealTypeToggle = [[UIView alloc] initWithFrame:frame];
//    self.dealTypeToggle.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
//    [self.view addSubview:self.dealTypeToggle];
    
    self.tableView = [[UITableView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 100, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(7.0, 0.0, self.view.height - 200, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self checkToLaunchInvitationModal];
    
    //UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.size.width, 175)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0, self.view.size.width, 100)];
    self.mapView.delegate = self;
    [self.mapView setShowsUserLocation:YES];
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(toggleMapView:)];
    tapped.numberOfTapsRequired = 1;
    tapped.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tapped];
    [self.view addSubview:self.mapView];
    //[self.view addSubview:tapView];
    
    self.mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 100, 15, 0, 22)];
    self.mapLabel.textAlignment = NSTextAlignmentCenter;
    self.mapLabel.font = [ThemeManager boldFontOfSize:10];
    self.mapLabel.textColor = [UIColor whiteColor];
    self.mapLabel.backgroundColor = [[ThemeManager sharedTheme] brownColor];
    [self.mapView addSubview:self.mapLabel];
    self.mapViewFullScreen = NO;
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    self.redoSearchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 55)];
    self.redoSearchContainer.backgroundColor = [UIColor colorWithWhite:230/255.0 alpha:1.0];
    [self.mapView addSubview:self.redoSearchContainer];
    
    self.redoSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redoSearchButton.size = CGSizeMake(250, 35);
    self.redoSearchButton.centerX = self.redoSearchContainer.width/2.0;
    self.redoSearchButton.centerY = self.redoSearchContainer.height/2.0;
    self.redoSearchButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    [self.redoSearchButton setTitle:@"REDO SEARCH IN AREA" forState:UIControlStateNormal];
    //self.inviteFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteFriendsButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    //self.inviteFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., chevronImage.size.width);
    self.redoSearchButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
    [self.redoSearchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redoSearchButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.redoSearchButton addTarget:self action:@selector(redoSearchButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.redoSearchContainer addSubview:self.redoSearchButton];
    
    self.dealInView = [[Deal alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];

}

- (void) checkToLaunchInvitationModal
{
    
    NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    
    if ((launchCount + 1) % 3 == 0) {
        [[MaveSDK sharedInstance] presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
            // Code to present Mave's view controller from yours, e.g:
            //[[AppDelegate sharedAppDelegate].centerNavigationController setSelectedViewController:inviteController animated:YES];
            [self presentViewController:inviteController animated:YES completion:nil];
        } dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
            // Code to transition back to your view controller after Mave's
            // is dismissed (sent invites or cancelled), e.g:
            [controller dismissViewControllerAnimated:YES completion:nil];
        } inviteContext:@"Popup"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.loadingDeals && !self.lastUpdatedDeals) {
        [self reloadDeals];
    }

    [self.rewardsViewController updateRewardsScore];
//    self.groupDeal = YES;
    
    [[AnalyticsManager sharedManager] viewedDealTable];
}

- (UIView *)enableLocationView
{
    if (!_enableLocationView) {
        _enableLocationView = [[UIView alloc] init];
        _enableLocationView.size = CGSizeMake(self.tableView.width, 175);
        _enableLocationView.backgroundColor = [UIColor whiteColor];
        [_enableLocationView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
        
        self.enableLocationLabel = [[UILabel alloc] init];
        self.enableLocationLabel.size = CGSizeMake(250, 200);
        self.enableLocationLabel.font = [ThemeManager regularFontOfSize:14.];
        self.enableLocationLabel.textColor = [UIColor colorWithWhite:102/255.0 alpha:1.0];
        self.enableLocationLabel.numberOfLines = 6;
        self.enableLocationView.hidden = YES;
        self.enableLocationLabel.textAlignment = NSTextAlignmentCenter;
        self.enableLocationLabel.text = @"Want to see great deals nearby? Hotspot needs to know your location.\n\nAllow Location Access in Privacy > Location Services";
        //        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
        //        footerView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
        self.enableLocationLabel.centerX = self.enableLocationView.width/2.0;
        self.enableLocationLabel.bottom = self.enableLocationView.height - 30;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.enableLocationView.height)];
        footerView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
        [footerView addSubview:self.enableLocationLabel];
        [self.enableLocationView addSubview:footerView];
        
        if (&UIApplicationOpenSettingsURLString != NULL) {
            self.enableLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.enableLocationButton.size = CGSizeMake(200, 35);
            self.enableLocationButton.centerX = self.enableLocationView.width/2.0;
            self.enableLocationButton.bottom = self.enableLocationView.height - 20;
            self.enableLocationButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
            [self.enableLocationButton setTitle:@"Go to Hotspot Settings" forState:UIControlStateNormal];
            self.enableLocationButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.enableLocationButton.frame.size.width - ( 50.), 0., 0.);
            self.enableLocationButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 0.);
            self.enableLocationButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
            [self.enableLocationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.enableLocationButton addTarget:self action:@selector(appSettingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.enableLocationView addSubview:self.enableLocationButton];
        }
    }
    return _enableLocationView;
}

- (UIView *)emptyBeaconView
{
    if (!_emptyBeaconView) {
        _emptyBeaconView = [[UIView alloc] init];
        _emptyBeaconView.size = CGSizeMake(self.tableView.width, 149);
        _emptyBeaconView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noDealsPlaceholder"]];
        [_emptyBeaconView addSubview:imageView];
        //[_emptyBeaconView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(happyHoursButtonTouched:)];
        //[_emptyBeaconView addGestureRecognizer:tap];
    }
    return _emptyBeaconView;
}

- (void)didUpdateLocation:(NSNotification *)notification
{
    if (self.loadingDeals) {
        return;
    }
    if (!self.lastUpdatedDeals) {
        [self reloadDeals];
    }
    else {
        NSTimeInterval durationSinceUpdate = [[NSDate date] timeIntervalSinceDate:self.lastUpdatedDeals];
        if (durationSinceUpdate > 60*3) {
            [self reloadDeals];
        }
    }
}

- (void)showEnableLocationView
{
    [self.tableView addSubview:self.enableLocationView];
    self.enableLocationView.hidden = NO;
}

- (void)hideEnableLocationView
{
    self.enableLocationView.hidden = YES;
}

- (void)showEmptyDealsView
{
    [self.tableView addSubview:self.emptyBeaconView];
    self.emptyBeaconView.hidden = NO;
}

- (void)hideEmptyDealsView
{
    self.emptyBeaconView.hidden = YES;
}

- (void)reloadDeals
{
    self.loadingDeals = YES;
    [self hideEnableLocationView];
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    LocationTracker *locationTracker = [[LocationTracker alloc] init];
    if (locationTracker.authorized) {
        [locationTracker fetchCurrentLocation:^(CLLocation *location) {
            //REMOVE THIS LINE AFTER DEMO
            //CLLocation *staticLocation = [[CLLocation alloc] initWithLatitude:47.667759 longitude:-122.312766];
            //REMOVE THIS LINE AFTER DEMO
            [self loadDealsNearCoordinate:location.coordinate withRadius:nil withCompletion:^{
            //[self loadDealsNearCoordinate:staticLocation.coordinate withCompletion:^{
                self.loadingDeals = NO;
                [self updateDealInMap];
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                [[AnalyticsManager sharedManager] viewedDeals:self.deals.count];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDealsUpdatedNotification object:nil];
            }];
        } failure:^(NSError *error) {
            self.loadingDeals = NO;
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        }];
    } else {
        [self showEnableLocationView];
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }
    
}

- (void) updateDealInMap
{
    if (self.deals.count > 0){
        self.dealInView = self.deals[0];
        [self updateMapCoordinates];
    }
}

- (CLLocationDistance)getRadius
{
    CLLocationCoordinate2D centerCoor = [self getCenterCoordinate];
    // init center location from center coordinate
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
    
    CLLocationCoordinate2D topCenterCoor = [self getTopCenterCoordinate];
    CLLocation *topCenterLocation = [[CLLocation alloc] initWithLatitude:topCenterCoor.latitude longitude:topCenterCoor.longitude];
    
    CLLocationDistance radius = [centerLocation distanceFromLocation:topCenterLocation];
    
    return radius/1000;
}

- (CLLocationCoordinate2D)getTopCenterCoordinate
{
    // to get coordinate from CGPoint of your map
    CLLocationCoordinate2D topCenterCoor = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width / 2.0f, 0) toCoordinateFromView:self.mapView];
    return topCenterCoor;
}

- (CLLocationCoordinate2D)getCenterCoordinate
{
    CLLocationCoordinate2D centerCoor = [self.mapView centerCoordinate];
    return centerCoor;
}

- (void)loadDealsNearCoordinate:(CLLocationCoordinate2D)coordinate withRadius:(NSString *)radius withCompletion:(void (^)())completion
{
    [[APIClient sharedClient] getDealsNearCoordinate:coordinate withRadius:radius success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSMutableArray *events = [[NSMutableArray alloc] init];
        NSMutableArray *deals = [[NSMutableArray alloc] init];
        NSMutableArray *happyHours = [[NSMutableArray alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//        for (NSDictionary *eventJSON in responseObject[@"events"]) {
//            Deal *event = [[Deal alloc] initWithDictionary:eventJSON];
//            [events addObject:event];
//        }
        [self.mapView removeAnnotations:[self.mapView annotations]];
        
        for (NSDictionary *dealJSON in responseObject[@"deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(deal.venue.coordinate.latitude, deal.venue.coordinate.longitude);
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:dealLocation2D];
            annotation.title = @"hotspotPin";
            [self.mapView addAnnotation:annotation];
            [deals addObject:deal];
        }
        
        for (NSDictionary *happyHourJSON in responseObject[@"happy_hours"]) {
            HappyHour *happyHour = [[HappyHour alloc] initWithDictionary:happyHourJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:happyHour.venue.coordinate.latitude longitude:happyHour.venue.coordinate.longitude];
            happyHour.venue.distance = [location distanceFromLocation:dealLocation];
            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(happyHour.venue.coordinate.latitude, happyHour.venue.coordinate.longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:dealLocation2D];
            [self.mapView addAnnotation:annotation];
            [happyHours addObject:happyHour];
        }
    
        self.deals = deals;
        self.happyHours = happyHours;
        
//        NSPredicate *predicate;
//        predicate = [NSPredicate predicateWithFormat:@"groupDeal = NO"];
//        NSLog(@"%lu", (unsigned long)[[self.allDeals filteredArrayUsingPredicate:predicate] count]);
//        if ([[self.allDeals filteredArrayUsingPredicate:predicate] count] > 0) {
//            self.dealTypeToggle.hidden = NO;
//        };
        
        [self reloadTableView];
        self.lastUpdatedDeals = [NSDate date];
        if (completion) {
            completion();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion();
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            if ([annotation.title isEqualToString:@"hotspotPin"]){
                pinView.pinColor = MKPinAnnotationColorRed;
            } else {
                pinView.pinColor = MKPinAnnotationColorPurple;
            }
        } else {
            if ([annotation.title isEqualToString:@"hotspotPin"]){
                pinView.pinColor = MKPinAnnotationColorRed;
            } else {
                pinView.pinColor = MKPinAnnotationColorPurple;
            }
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)reloadTableView
{
    if ((self.deals && self.deals.count) || (self.happyHours && self.happyHours.count)) {
        [self hideEmptyDealsView];
//        NSPredicate *predicate;
//        if (self.groupDeal) {
//            predicate = [NSPredicate predicateWithFormat:@"groupDeal = YES"];
//            self.textManyFriends.backgroundColor = [UIColor colorWithRed:37./255 green:37./255 blue:37./255 alpha:1.0];
//            self.textOneFriend.backgroundColor = [UIColor clearColor];
//        }
//        else {
//            predicate = [NSPredicate predicateWithFormat:@"groupDeal = NO"];
//            self.textOneFriend.backgroundColor = [UIColor colorWithRed:37./255 green:37./255 blue:37./255 alpha:1.0];
//            self.textManyFriends.backgroundColor = [UIColor clearColor];
//        }
        //self.deals = [self.allDeals filteredArrayUsingPredicate:predicate];
        //self.deals = self.allDeals;
    }
    else {
        [self showEmptyDealsView];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.deals.count + self.happyHours.count ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deals.count + self.happyHours.count;

}

//- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
//{
//    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
//    annView.pinColor = MKPinAnnotationColorGreen;
//    return annView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.deals.count) {
        return 203;
    } else {
        return 153;
    }
}

-(void)tappedOnCell:(UITapGestureRecognizer *)sender
{
    
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    //NSIndexPath *indexPath = [[self getTableView]  indexPathForCell:self];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.deals.count) {
        Deal *deal;
        deal = self.deals[indexPath.row];
        SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
        dealViewController.deal = deal;
        [self.navigationController pushViewController:dealViewController animated:YES];
    } else {
        HappyHour *happyHour;
        happyHour = self.happyHours[indexPath.row - self.deals.count];
        [[[UIAlertView alloc] initWithTitle:happyHour.venue.name message:happyHour.happyHourDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < self.deals.count) {
        Deal *deal;
        deal = self.deals[indexPath.row];
        
        NSString *DealCellIdentifier = [NSString stringWithFormat:@"DealCell"];
        DealTableViewCell *dealCell = [tableView dequeueReusableCellWithIdentifier:DealCellIdentifier];
        
        if (!dealCell) {
            dealCell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DealCellIdentifier];
            dealCell.backgroundColor = [UIColor clearColor];
            dealCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
        [recognizer setNumberOfTapsRequired:1];
        [dealCell.contentView addGestureRecognizer:recognizer];
        
        dealCell.deal = deal;
        return dealCell;
    } else {
        HappyHour *happyHour;
        happyHour = self.happyHours[indexPath.row - self.deals.count];
        
        NSString *HappyHourCellIdentifier = [NSString stringWithFormat:@"HappyHourCell"];
        HappyHourTableViewCell *happyHourCell = [tableView dequeueReusableCellWithIdentifier:HappyHourCellIdentifier];
        
        if (!happyHourCell) {
            happyHourCell = [[HappyHourTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HappyHourCellIdentifier];
            happyHourCell.backgroundColor = [UIColor clearColor];
            happyHourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
        [recognizer setNumberOfTapsRequired:1];
        [happyHourCell.contentView addGestureRecognizer:recognizer];
        
        happyHourCell.happyHour = happyHour;
        if (indexPath.row % 2 == 0) {
            happyHourCell.backgroundCellView.backgroundColor = [[[ThemeManager sharedTheme] redColor] colorWithAlphaComponent:.05];
            //happyHourCell.backgroundCellView.backgroundColor = [UIColor colorWithWhite:230/255.0 alpha:.5];
        } else {
            //happyHourCell.backgroundCellView.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:.15];
            happyHourCell.backgroundCellView.backgroundColor = [UIColor colorWithWhite:230/255.0 alpha:.5];
        }

        return happyHourCell;
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    Deal *deal;
//    if (self.hasEvents){
//        if (indexPath.row == 0) {
//            deal = self.events[0];
//        } else {
//            deal = self.deals[indexPath.row - 1];
//        }
//    } else {
//        deal = self.deals[indexPath.row];
//    }
//
//    SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
//    dealViewController.deal = deal;
//    [self.navigationController pushViewController:dealViewController animated:YES];
//}

- (void)happyHoursButtonTouched:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"hotspotHappyHours://"];
    BOOL hasHappyHours = [[UIApplication sharedApplication] canOpenURL:url];
    if (!hasHappyHours) {
        url = [NSURL URLWithString:@"http://itunes.apple.com/app/id879840229"];
    }
    [[UIApplication sharedApplication] openURL:url];
}

- (void) redoSearchButtonTouched:(id)sender
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    CLLocationCoordinate2D newMapCenter = [self.mapView centerCoordinate];
    NSString *radiusString = [NSString stringWithFormat:@"%f", [self getRadius]];
    [self loadDealsNearCoordinate:newMapCenter withRadius:radiusString withCompletion:^{
        //[self loadDealsNearCoordinate:staticLocation.coordinate withCompletion:^{
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        //[self toggleMapViewFrame];
        [[AnalyticsManager sharedManager] viewedDeals:self.deals.count];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDealsUpdatedNotification object:nil];
    }];
    
//    if (self.deals.count > 0){
//        self.dealInView = self.deals[0];
//        [self updateMapCoordinates];
//    }
}

- (void)appSettingsButtonTouched:(id)sender
{
    if (&UIApplicationOpenSettingsURLString != NULL) {
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettings];
    }
}

//- (void)tabButtonTouched:(UIButton *)sender
//{
////    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//
//    if (sender == self.textOneFriend) {
//        self.groupDeal = NO;
//        [self showTextOneFriendAnimated:YES];
//    }
//    else if (sender == self.textManyFriends) {
//        self.groupDeal = YES;
//        [self showTextManyFriendsAnimated:YES];
//    }
//    
//    [self reloadTableView];
//}

//- (void)showTextOneFriendAnimated:(BOOL)animated
//{
//    self.textOneFriend.selected = YES;
//    self.textManyFriends.selected = NO;
//    //self.beaconChatViewController.view.alpha = 1;
////    NSTimeInterval duration = animated ? 0.3 : 0.0;
////    [UIView animateWithDuration:duration animations:^{
//////        self.inviteListViewController.view.transform = CGAffineTransformMakeTranslation(self.inviteListViewController.view.frame.size.width, 0);
//////        self.beaconChatViewController.view.transform = CGAffineTransformIdentity;
//////        self.inviteListViewController.view.alpha = 0.0;
//////    } completion:^(BOOL finished) {
//////        self.inviteListViewController.view.alpha = 0;
////    }];
//}

//- (void)showTextManyFriendsAnimated:(BOOL)animated
//{
//    self.textOneFriend.selected = NO;
//    self.textManyFriends.selected = YES;
//    //self.dealRedemptionViewController.view.alpha = 1;
////    NSTimeInterval duration = animated ? 0.3 : 0.0;
////    [UIView animateWithDuration:duration animations:^{
//////        self.beaconChatViewController.view.transform = CGAffineTransformMakeTranslation(self.beaconChatViewController.view.frame.size.width, 0);
//////        self.inviteListViewController.view.transform = self.beaconChatViewController.view.transform;
//////        self.dealRedemptionViewController.view.transform = CGAffineTransformIdentity;
//////        self.beaconChatViewController.view.alpha = 0.0;
//////        self.inviteListViewController.view.alpha = self.beaconChatViewController.view.alpha;
////    } completion:^(BOOL finished) {
//////        self.beaconChatViewController.view.alpha = 0;
////        
////        //self.textManyFriends.backgroundColor = [UIColor redColor];
////    }];
//}

-(void) updateMapCoordinates
{

    CLLocationCoordinate2D initialLocation = CLLocationCoordinate2DMake(self.dealInView.venue.coordinate.latitude, self.dealInView.venue.coordinate.longitude);
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(initialLocation, 550, 550)];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    self.mapLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self.dealInView.venue.name uppercaseString], [self stringForDistance:self.dealInView.venue.distance]];
    //self.mapLabel.text = [NSString stringWithFormat:@"%@", [self stringForDistance:self.dealInView.venue.distance]];
    float mapLabelWidth = [self widthOfString:self.mapLabel.text withFont:self.mapLabel.font];
    self.mapLabel.width = mapLabelWidth + 10;
    self.mapLabel.x = self.view.width - self.mapLabel.width;
    
}

//- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
//{
//    static NSString *AnnotationViewID = @"annotationViewID";
//    
//    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//    
//    if (annotationView == nil)
//    {
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//    }
//
//    annotationView.image = [UIImage imageNamed:@"mapMarker"];
//    annotationView.annotation = annotation;
//    
//    return annotationView;
//}

- (NSString *)stringForDistance:(CLLocationDistance)distance
{
    //   CGFloat distanceMiles = METERS_TO_MILES*distance;
    NSString *distanceString;
    //    if (distanceMiles < 0.25) {
    //        distanceString = [NSString stringWithFormat:@"%0.0fft", (floor((METERS_TO_FEET*distance)/10))*10];
    //    }
    //    else {
    //distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
    //    }
    distanceString = [NSString stringWithFormat:@"%0.1f mi", METERS_TO_MILES*distance];
    return distanceString;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSIndexPath *currentIndexPath= self.tableView.indexPathsForVisibleRows[0];
    
    if (self.deals.count > 0) {
        if (self.tableView.contentOffset.y > 115 && currentIndexPath.row + 1 < self.deals.count) {
            self.dealInView = self.deals[currentIndexPath.row + 1];
        } else if (self.tableView.contentOffset.y > 115 && currentIndexPath.row + 1 >= self.deals.count && currentIndexPath.row < (self.deals.count + self.happyHours.count - 1)){
            self.dealInView = self.happyHours[currentIndexPath.row - [self.deals count] + 1];
        } else if (self.tableView.contentOffset.y < 115 && self.tableView.contentOffset.y > 0) {
            self.dealInView = self.deals[0];
        }
        [self updateMapCoordinates];
    } else if (self.deals.count == 0 && self.happyHours.count > 0) {
        if (self.tableView.contentOffset.y > 115 && currentIndexPath.row + 1 < self.happyHours.count) {
            self.dealInView = self.happyHours[currentIndexPath.row + 1];
        } else if (self.tableView.contentOffset.y > 115 && currentIndexPath.row + 1 >= self.happyHours.count && currentIndexPath.row < (self.deals.count + self.happyHours.count - 1)){
            self.dealInView = self.happyHours[currentIndexPath.row - [self.deals count] + 1];
        } else if (self.tableView.contentOffset.y < 115 && self.tableView.contentOffset.y > 0) {
            self.dealInView = self.happyHours[0];
        }
        [self updateMapCoordinates];
    }
}

- (void)toggleMapView:(id)sender
{
    [self toggleMapViewFrame];
}

- (void)toggleMapViewFrame
{
    if (self.mapViewFullScreen) {
        [UIView animateWithDuration:.5f animations:^{
            CGRect theFrame = self.mapView.frame;
            theFrame.size.height -= self.view.size.height - 100;
            self.mapView.frame = theFrame;
        }];
        
        [self hideRedoSearchContainer];
        //self.mapView.frame = CGRectMake(0,0, self.view.size.width, 125);
    } else {
        //self.mapView.frame = CGRectMake(0, 0, self.view.size.width, self.view.size.height);
        [UIView animateWithDuration:.5f animations:^{
            CGRect theFrame = self.mapView.frame;
            theFrame.size.height += self.view.size.height - 100;
            self.mapView.frame = theFrame;
        }];
    }
    self.mapViewFullScreen = !self.mapViewFullScreen;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && self.mapViewFullScreen){
        [self showRedoSearchContainer];
    }
}

- (void) showRedoSearchContainer
{
    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
        CGRect frame = self.mapLabel.frame;
        frame.origin.x = self.view.width + self.mapLabel.width;
        self.mapLabel.frame = frame; // move to new location
    }];
    
    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
        CGRect frame = self.redoSearchContainer.frame;
        frame.origin.y = self.view.height - 55;
        self.redoSearchContainer.frame = frame; // move to new location
    }];
}

- (void) hideRedoSearchContainer
{
    [UIView animateWithDuration:0.8 animations:^{  // animate the following:
        CGRect frame = self.mapLabel.frame;
        frame.origin.x = self.view.width - self.mapLabel.width;
        self.mapLabel.frame = frame; // move to new location
    }];
    
    [UIView animateWithDuration:0.8 animations:^{  // animate the following:
        CGRect frame = self.redoSearchContainer.frame;
        frame.origin.y = self.view.height;
        self.redoSearchContainer.frame = frame; // move to new location
    }];
}

@end