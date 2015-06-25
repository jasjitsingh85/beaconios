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
//#import "SetDealViewController.h"
#import "DealDetailViewController.h"
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
#import "RewardTableViewCell.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "RewardManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DealsTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

typedef enum dealTypeStates
{
    HAPPY_HOUR,
    HOTSPOT,
    REWARD
} DealTypes;

@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) UIView *enableLocationView;
@property (strong, nonatomic) UIView *dealTypeToggleContainer;
@property (strong, nonatomic) UIView *viewContainer;
@property (strong, nonatomic) UIView *mapViewContainer;
@property (strong, nonatomic) NSDate *lastUpdatedDeals;
@property (strong, nonatomic) UIButton *enableLocationButton;
@property (strong, nonatomic) UIButton *sliderThumb;
@property (strong, nonatomic) UIButton *mapListToggleButton;
@property (strong, nonatomic) UILabel *enableLocationLabel;
@property (strong, nonatomic) UILabel *mapLabel;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (assign, nonatomic) CLLocationCoordinate2D mapCenter;
@property (strong, nonatomic) UITapGestureRecognizer *mapTapped;
@property (assign, nonatomic) float initialRadius;
@property (assign, nonatomic) BOOL loadingDeals;
@property (assign, nonatomic) BOOL locationEnabled;
@property (assign, nonatomic) BOOL isMapViewActive;
@property (assign, nonatomic) BOOL isMapViewDealShowing;
//@property (strong, nonatomic) Deal *dealInView;
@property (strong, nonatomic) RewardsViewController *rewardsViewController;
//@property (assign, nonatomic) NSInteger *currentTopRow;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) UIView *redoSearchContainer;
@property (nonatomic, strong) UIButton *redoSearchButton;
@property (strong, nonatomic) UIView *selectedDealInMap;
@property (nonatomic, assign) DealTypes dealType;
@property (nonatomic, assign) DealTypes previousDealType;
@property (nonatomic, assign) int selectedDealIndex;

@property (nonatomic, strong) UIImageView *venueImageView;
@property (nonatomic, strong) UIImageView *backgroundGradient;
@property (nonatomic, strong) UIView *venueView;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UILabel *distanceLabel;

@end

@implementation DealsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    UIView *searchBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 175, 25)];
    self.navigationItem.titleView = searchBarContainer;
    
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 175, 25)];
//    //weird hack for black search bar issue
//    self.searchBar.backgroundImage = [UIImage new];
//    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
//    //self.searchBar.delegate = self;
//    //self.searchBar.barTintColor = [[ThemeManager sharedTheme] redColor];
//    self.searchBar.translucent = NO;
//    self.searchBar.layer.cornerRadius = 12;
//    self.searchBar.layer.borderWidth = 1.0;
//    self.searchBar.centerX = searchBarContainer.width/2.1;
//    self.searchBar.layer.borderColor = [[UIColor unnormalizedColorWithRed:167 green:167 blue:167 alpha:255] CGColor];
//    //self.searchBar.searchBarStyle = UISearchBarStyleProminent;
//    [searchBarContainer addSubview:self.searchBar];
//    //[self.view addSubview:self.searchBar];
    
    self.mapListToggleButton = [UIButton navButtonWithTitle:@"MAP"];
    [self.mapListToggleButton addTarget:self action:@selector(toggleMapView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.mapListToggleButton];
    
    self.viewContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.viewContainer];

    self.dealType = HOTSPOT;
    
    self.initialRadius = 1.6;
    
    self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
    //[self addChildViewController:self.rewardsViewController];
    [self.rewardsViewController updateRewardsScore];
    
    CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 70, [[UIScreen mainScreen] bounds].size.width, 70);
    self.dealTypeToggleContainer = [[UIView alloc] initWithFrame:frame];
    self.dealTypeToggleContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dealTypeToggleContainer];
    
    UIView *topBorder = [[UIView alloc] init];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:167 green:167 blue:167 alpha:255];
    topBorder.frame = CGRectMake(0, 0, self.view.width, 1.0);
    [self.dealTypeToggleContainer addSubview:topBorder];
    
    UIImageView *sliderTrack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider"]];
    sliderTrack.centerX = self.view.width/2;
    sliderTrack.y = 39;
    [self.dealTypeToggleContainer addSubview:sliderTrack];
    
    self.sliderThumb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.sliderThumb setImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    self.sliderThumb.y = 30;
//    self.sliderThumb.x = 30;
    self.sliderThumb.centerX = self.view.width/2;
    [self.dealTypeToggleContainer addSubview:self.sliderThumb];
    
    UIImageView *hotspotSliderLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotSliderLabel"]];
    //hotspotSliderImage.size = CGSizeMake(30, 100);
    hotspotSliderLabel.height = 25;
    hotspotSliderLabel.width = 73;
    hotspotSliderLabel.centerX = self.view.width/2;
    hotspotSliderLabel.y = 5;
    [self.dealTypeToggleContainer addSubview:hotspotSliderLabel];
    
    UILabel *happyHourLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 10, 70, 20)];
    happyHourLabel.text = @"HAPPY HOURS";
    happyHourLabel.font = [ThemeManager lightFontOfSize:9];
    happyHourLabel.textAlignment = NSTextAlignmentCenter;
    [self.dealTypeToggleContainer addSubview:happyHourLabel];
    
    UILabel *rewardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 78, 10, 70, 20)];
    rewardsLabel.text = @"REWARDS";
    rewardsLabel.font = [ThemeManager lightFontOfSize:9];
    rewardsLabel.textAlignment = NSTextAlignmentCenter;
    [self.dealTypeToggleContainer addSubview:rewardsLabel];
    
    UIButton *happyHourButton = [UIButton buttonWithType:UIButtonTypeCustom];
    happyHourButton.size = CGSizeMake(70, 70);
    happyHourButton.x = 10;
    happyHourButton.y = 0;
    //happyHourButton.backgroundColor = [[[ThemeManager sharedTheme] blueColor] colorWithAlphaComponent:0.2];
    [happyHourButton addTarget:self action:@selector(happyHourButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.dealTypeToggleContainer addSubview:happyHourButton];
    
    UIButton *hotspotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hotspotButton.size = CGSizeMake(70, 70);
    hotspotButton.centerX = self.view.width/2;
    hotspotButton.y = 0;
    //hotspotButton.backgroundColor = [[[ThemeManager sharedTheme] blueColor] colorWithAlphaComponent:0.2];
    [hotspotButton addTarget:self action:@selector(hotspotButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.dealTypeToggleContainer addSubview:hotspotButton];
    
    UIButton *rewardsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rewardsButton.size = CGSizeMake(70, 70);
    rewardsButton.x = self.view.width - 80;
    rewardsButton.y = 0;
    //rewardsButton.backgroundColor = [[[ThemeManager sharedTheme] blueColor] colorWithAlphaComponent:0.2];
    [rewardsButton addTarget:self action:@selector(rewardsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.dealTypeToggleContainer addSubview:rewardsButton];
    
    self.tableView = [[UITableView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 80, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.viewContainer addSubview:self.tableView];
    
    [self checkToLaunchInvitationModal];
    
    self.mapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.size.width, self.view.size.height - 70)];
    self.mapViewContainer.hidden = YES;
    [self.viewContainer addSubview:self.mapViewContainer];
    
    //UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.size.width, 175)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.size.width, self.view.size.height - 70 - 64)];
    self.mapView.delegate = self;
    [self.mapView setShowsUserLocation:YES];
    self.mapTapped = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(toggleMapViewDeal:)];
    self.mapTapped.numberOfTapsRequired = 1;
    self.mapTapped.numberOfTouchesRequired = 1;
    self.mapTapped.enabled = NO;
    [self.mapView addGestureRecognizer:self.mapTapped];
    [self.mapViewContainer addSubview:self.mapView];
    //[self.view addSubview:tapView];
    
//    self.mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 100, 15, 0, 22)];
//    self.mapLabel.textAlignment = NSTextAlignmentCenter;
//    self.mapLabel.font = [ThemeManager boldFontOfSize:10];
//    self.mapLabel.textColor = [UIColor whiteColor];
//    self.mapLabel.backgroundColor = [[ThemeManager sharedTheme] brownColor];
//    [self.mapView addSubview:self.mapLabel];
    self.isMapViewActive = NO;
    self.isMapViewDealShowing = NO;
    
    self.selectedDealInMap = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 70, self.view.width, 146)];
    self.selectedDealInMap.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *selectedDealTapped = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(tappedOnSelectedDealInMap:)];
    selectedDealTapped.numberOfTapsRequired = 1;
    selectedDealTapped.numberOfTouchesRequired = 1;
    [self.selectedDealInMap addGestureRecognizer:selectedDealTapped];
    [self.mapViewContainer addSubview:self.selectedDealInMap];
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    self.redoSearchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -55, self.view.width, 55)];
    self.redoSearchContainer.centerX = self.view.width/2;
    self.redoSearchContainer.backgroundColor = [UIColor clearColor];
    [self.mapView addSubview:self.redoSearchContainer];
    
    self.redoSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redoSearchButton.size = CGSizeMake(self.view.width, 75);
    self.redoSearchButton.centerX = self.redoSearchContainer.width/2.0;
    self.redoSearchButton.centerY = self.redoSearchContainer.height/2.0;
    [self.redoSearchButton setImage:[UIImage imageNamed:@"redoSearchContainer"] forState:UIControlStateNormal];
    //self.redoSearchButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    //[self.redoSearchButton setTitle:@"REDO SEARCH IN AREA" forState:UIControlStateNormal];
    //self.inviteFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteFriendsButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    //self.inviteFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., chevronImage.size.width);
    self.redoSearchButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
    [self.redoSearchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redoSearchButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.redoSearchButton addTarget:self action:@selector(redoSearchButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.redoSearchContainer addSubview:self.redoSearchButton];
    
    self.venueImageView = [[UIImageView alloc] init];
    self.venueImageView.height = 146;
    self.venueImageView.width = self.view.width;
    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.venueImageView.clipsToBounds = YES;
    [self.selectedDealInMap addSubview:self.venueImageView];
    
    self.backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 87, self.venueImageView.size.width, 60)];
    UIImage *gradientImage = [UIImage imageNamed:@"backgroundGradient@2x.png"];
    [self.backgroundGradient setImage:gradientImage];
    [self.venueImageView addSubview:self.backgroundGradient];
    
    self.venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.selectedDealInMap.frame.size.width, 146)];
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.venueImageView.bounds];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.venueView addSubview:backgroundView];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:20];
    self.venueLabelLineOne.textColor = [UIColor whiteColor];
    self.venueLabelLineOne.width = self.view.width - 20;
    self.venueLabelLineOne.x = 5;
    self.venueLabelLineOne.height = 30;
    self.venueLabelLineOne.y = 35;
    //self.venueLabelLineOne.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.venueView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:34];
    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
    self.venueLabelLineTwo.width = self.view.width - 20;
    self.venueLabelLineTwo.x = 4;
    self.venueLabelLineTwo.height = 46;
    self.venueLabelLineTwo.y = 49;
    //self.venueLabelLineTwo.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineTwo.numberOfLines = 1;
    [self.venueView addSubview:self.venueLabelLineTwo];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:16 green:193 blue:255 alpha:255];
    //self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 26;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 90;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:14];
    //self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.venueView addSubview:self.descriptionLabel];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager lightFontOfSize:14];
    self.dealTime.textColor = [UIColor whiteColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.width = 200;
    self.dealTime.height = 20;
    self.dealTime.x = 8;
    self.dealTime.y=117;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venueView addSubview:self.dealTime];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager lightFontOfSize:14];
    self.distanceLabel.size = CGSizeMake(67, 20);
    //self.distanceLabel.layer.cornerRadius = self.distanceLabel.width/2.0;
    //self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.textAlignment = NSTextAlignmentRight;
    self.distanceLabel.y = 117;
    self.distanceLabel.x = self.view.width - 77;
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.venueView addSubview:self.distanceLabel];
    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    //[self.venueScroll addSubview:self.venueDetailView];
    
    [self.selectedDealInMap addSubview:self.venueView];
    
    
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
            [self loadDealsNearCoordinate:location.coordinate withRadius:[NSString stringWithFormat:@"%f", self.initialRadius] withCompletion:^{
            //[self loadDealsNearCoordinate:staticLocation.coordinate withRadius:[NSString stringWithFormat:@"%f", self.initialRadius] withCompletion:^{
                self.loadingDeals = NO;
                //self.mapCenter = staticLocation.coordinate;
                self.mapCenter = location.coordinate;
                [self updateMapCoordinates];
                [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
                [[AnalyticsManager sharedManager] viewedDeals:self.hotspots.count];
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

//- (void) updateDealInMap
//{
//    if (self.hotspots.count > 0){
//        self.dealInView = self.hotspots[0];
//        [self updateMapCoordinates];
//    }
//}

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
        NSMutableArray *rewards = [[NSMutableArray alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//        for (NSDictionary *eventJSON in responseObject[@"events"]) {
//            Deal *event = [[Deal alloc] initWithDictionary:eventJSON];
//            [events addObject:event];
//        }
        [self.mapView removeAnnotations:[self.mapView annotations]];
        
        for (NSDictionary *dealJSON in responseObject[@"deals"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
//            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(deal.venue.coordinate.latitude, deal.venue.coordinate.longitude);
            deal.venue.distance = [location distanceFromLocation:dealLocation];
//            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//            [annotation setCoordinate:dealLocation2D];
//            annotation.title = @"hotspotPin";
//            [self.mapView addAnnotation:annotation];
            [deals addObject:deal];
        }
        
        for (NSDictionary *happyHourJSON in responseObject[@"happy_hours"]) {
            HappyHour *happyHour = [[HappyHour alloc] initWithDictionary:happyHourJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:happyHour.venue.coordinate.latitude longitude:happyHour.venue.coordinate.longitude];
            happyHour.venue.distance = [location distanceFromLocation:dealLocation];
//            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(happyHour.venue.coordinate.latitude, happyHour.venue.coordinate.longitude);
//            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//            [annotation setCoordinate:dealLocation2D];
//            [self.mapView addAnnotation:annotation];
            [happyHours addObject:happyHour];
        }
        
        for (NSDictionary *dealJSON in responseObject[@"unlocked_rewards"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            deal.locked = NO;
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            [rewards addObject:deal];
        }
        for (NSDictionary *dealJSON in responseObject[@"locked_rewards"]) {
            Deal *deal = [[Deal alloc] initWithDictionary:dealJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:deal.venue.coordinate.latitude longitude:deal.venue.coordinate.longitude];
            deal.locked = YES;
            deal.venue.distance = [location distanceFromLocation:dealLocation];
            [rewards addObject:deal];
        }
    
        self.hotspots = deals;
        self.happyHours = happyHours;
        self.rewards = rewards;
        
        if (self.dealType == HOTSPOT) {
            self.selectedDeals = self.hotspots;
        } else if (self.dealType == HAPPY_HOUR) {
            self.selectedDeals = self.happyHours;
        } else if (self.dealType == REWARD) {
            self.selectedDeals = self.rewards;
        }
        
        
        [self reloadAnnotations];
        
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

- (void) reloadAnnotations
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (self.dealType == HOTSPOT || self.dealType == REWARD) {
        int dealIndex = 0;
        for (Deal *deal in self.selectedDeals) {
            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(deal.venue.coordinate.latitude, deal.venue.coordinate.longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:dealLocation2D];
            annotation.title = [NSString stringWithFormat:@"%d", dealIndex];
            ++dealIndex;
            [self.mapView addAnnotation:annotation];
        }
    } else {
        int happyHourIndex = 0;
        for (HappyHour *happyHour in self.selectedDeals) {
            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(happyHour.venue.coordinate.latitude, happyHour.venue.coordinate.longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:dealLocation2D];
            annotation.title = [NSString stringWithFormat:@"%d", happyHourIndex];
            ++happyHourIndex;
            [self.mapView addAnnotation:annotation];
        }
    }
    
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
            pinView.canShowCallout = NO;
            if (self.dealType == HOTSPOT){
                //pinView.pinColor = MKPinAnnotationColorRed;
                pinView.image = [UIImage imageNamed:@"bluePin"];
            } else if (self.dealType == HAPPY_HOUR) {
                //pinView.pinColor = MKPinAnnotationColorPurple;
                pinView.image = [UIImage imageNamed:@"purplePin"];
            } else if (self.dealType == REWARD) {
                pinView.image = [UIImage imageNamed:@"greenPin"];
            }
        } else {
            if (self.dealType == HOTSPOT){
                //pinView.pinColor = MKPinAnnotationColorRed;
                pinView.image = [UIImage imageNamed:@"bluePin"];
            } else if (self.dealType == HAPPY_HOUR) {
                //pinView.pinColor = MKPinAnnotationColorPurple;
                pinView.image = [UIImage imageNamed:@"purplePin"];
            } else if (self.dealType == REWARD) {
                pinView.image = [UIImage imageNamed:@"greenPin"];
            }
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    return nil;
}

- (void)reloadTableView
{
    if (self.selectedDeals && self.selectedDeals.count){
        [self hideEmptyDealsView];
    }
    else {
        [self showEmptyDealsView];
    }
    
    [self.tableView reloadData];
}

- (void) reloadTableViewAfterDealToggle
{
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    if (self.dealType == REWARD) {
        [self.rewardsViewController showRewardsScore];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationLeft];
    } else if (self.dealType == HAPPY_HOUR) {
        [self.rewardsViewController hideRewardsScore];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationRight];
    } else if (self.dealType == HOTSPOT) {
        [self.rewardsViewController hideRewardsScore];
        if (self.previousDealType == HAPPY_HOUR) {
            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationRight];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.selectedDeals ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedDeals.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 151;
//    if (indexPath.row < self.hotspots.count) {
//        return 151;
//    } else {
//        return 113;
//    }
}

-(void)tappedOnCell:(UITapGestureRecognizer *)sender
{
    
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    //NSIndexPath *indexPath = [[self getTableView]  indexPathForCell:self];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.dealType == HOTSPOT) {
        Deal *deal;
        deal = self.selectedDeals[indexPath.row];
        DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
        dealViewController.deal = deal;
        [self.navigationController pushViewController:dealViewController animated:YES];
    } else if (self.dealType == HAPPY_HOUR) {
        HappyHour *happyHour;
        happyHour = self.selectedDeals[indexPath.row];
//        [[[UIAlertView alloc] initWithTitle:happyHour.venue.name message:happyHour.happyHourDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
        dealViewController.happyHour = happyHour;
        [self.navigationController pushViewController:dealViewController animated:YES];
    } else if (self.dealType == REWARD) {
        Deal *deal;
        deal = self.selectedDeals[indexPath.row];
        if (!deal.locked) {
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Purchase Voucher?" message:@"Would you like to purchase this voucher?"];
            [alertView bk_addButtonWithTitle:@"Yes" handler:^{
                [[RewardManager sharedManager] purchaseRewardItem:deal.dealID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRewardsUpdated object:self];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Working");
                }];
            }];
            
            [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
            [alertView show];
            return;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Not Enough Points" message:@"You don't have enough points to purchase this item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.dealType == HOTSPOT) {
        Deal *deal;
        deal = self.hotspots[indexPath.row];
        
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
    } else if (self.dealType == HAPPY_HOUR) {
        HappyHour *happyHour;
        happyHour = self.happyHours[indexPath.row];
        
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
    } else if (self.dealType == REWARD) {
        Deal *deal;
        NSString *CellIdentifier = [NSString stringWithFormat:@"%d", (int)indexPath.row];
        RewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[RewardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
        [recognizer setNumberOfTapsRequired:1];
        [cell.contentView addGestureRecognizer:recognizer];
        
//        if (indexPath.row == 0) {
//            cell.deal = nil;
//        } else {
            deal = self.selectedDeals[indexPath.row];
            cell.deal = deal;
//        }
        
        return cell;
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
    self.mapCenter = [self.mapView centerCoordinate];
    NSString *radiusString = [NSString stringWithFormat:@"%f", [self getRadius]];
    [self loadDealsNearCoordinate:self.mapCenter withRadius:radiusString withCompletion:^{
        //[self loadDealsNearCoordinate:staticLocation.coordinate withCompletion:^{
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self hideRedoSearchContainer];
        [[AnalyticsManager sharedManager] viewedDeals:self.hotspots.count];
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



-(void) updateMapCoordinates
{

    CLLocationCoordinate2D initialLocation = CLLocationCoordinate2DMake(self.mapCenter.latitude, self.mapCenter.longitude);
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(initialLocation, self.initialRadius * 1000, self.initialRadius * 1000 * (self.view.height/self.view.width))];
    
    [self.mapView setRegion:adjustedRegion animated:YES];
    
//    self.mapLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self.dealInView.venue.name uppercaseString], [self stringForDistance:self.dealInView.venue.distance]];
    //self.mapLabel.text = [NSString stringWithFormat:@"%@", [self stringForDistance:self.dealInView.venue.distance]];
//    float mapLabelWidth = [self widthOfString:self.mapLabel.text withFont:self.mapLabel.font];
//    self.mapLabel.width = mapLabelWidth + 10;
//    self.mapLabel.x = self.view.width - self.mapLabel.width;
    
}

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


- (void)toggleMapViewDeal:(id)sender
{
    [self toggleMapViewDealWithoutTouch];
}

- (void) toggleMapViewDealWithoutTouch
{
    if (self.isMapViewDealShowing) {
        [UIView animateWithDuration:.5f animations:^{
            CGRect theFrame = self.mapView.frame;
            theFrame.size.height += 146;
            self.mapView.frame = theFrame;
            
            self.selectedDealInMap.y = self.view.height - 70;
            
            self.mapTapped.enabled = NO;
        }];
    } else {
        [UIView animateWithDuration:.5f animations:^{
            CGRect theFrame = self.mapView.frame;
            theFrame.size.height -= 146;
            self.mapView.frame = theFrame;
            
            self.selectedDealInMap.y = self.view.height - 70 - 146;
            
            self.mapTapped.enabled = YES;
        }];
    }
    self.isMapViewDealShowing = !self.isMapViewDealShowing;
}

- (void) minimizeMapViewDeal
{
    if (self.isMapViewDealShowing) {
        [self toggleMapViewDealWithoutTouch];
    }
}

- (void)toggleMapView:(id)sender
{
    [self toggleMapViewFrame];
}

- (void)toggleMapViewFrame
{
    [UIView transitionWithView:self.viewContainer
                      duration:.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        if (!self.isMapViewActive) {
                            [self.tableView setHidden:YES];
                            [self.mapViewContainer setHidden:NO];
                        } else {
                            [self.tableView setHidden:NO];
                            [self.mapViewContainer setHidden:YES];
                        }
                        
                    } completion:^(BOOL finished) {
                        if (finished) {
                            self.isMapViewActive = !self.isMapViewActive;
                            if (self.isMapViewActive) {
                                [self.mapListToggleButton setTitle:@"LIST" forState:UIControlStateNormal];
                            } else {
                                [self.mapListToggleButton setTitle:@"MAP" forState:UIControlStateNormal];
                            }
                        }
                    }];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && self.isMapViewActive){
        [self showRedoSearchContainer];
    }
}

- (void) showRedoSearchContainer
{
//    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
//        CGRect frame = self.mapLabel.frame;
//        frame.origin.x = self.view.width + self.mapLabel.width;
//        self.mapLabel.frame = frame; // move to new location
//    }];
    
    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
        CGRect frame = self.redoSearchContainer.frame;
        frame.origin.y = 0;
        self.redoSearchContainer.frame = frame; // move to new location
    }];
}

- (void) hideRedoSearchContainer
{
//    [UIView animateWithDuration:0.8 animations:^{  // animate the following:
//        CGRect frame = self.mapLabel.frame;
//        frame.origin.x = self.view.width - self.mapLabel.width;
//        self.mapLabel.frame = frame; // move to new location
//    }];
    
    [UIView animateWithDuration:0.35 animations:^{  // animate the following:
        CGRect frame = self.redoSearchContainer.frame;
        frame.origin.y = -55;
        self.redoSearchContainer.frame = frame; // move to new location
    }];
}

- (void) happyHourButtonTouched:(id)sender
{
    [UIView animateWithDuration:0.35f animations:^{
        self.sliderThumb.frame = CGRectMake(25, 30, 30, 30);
    } completion:^(BOOL finished) {
        self.previousDealType = self.dealType;
        self.dealType = HAPPY_HOUR;
        self.selectedDeals = self.happyHours;
        [self reloadTableViewAfterDealToggle];
        [self reloadAnnotations];
        [self minimizeMapViewDeal];
    }];
}

- (void) hotspotButtonTouched:(id)sender
{
    [UIView animateWithDuration:0.35f animations:^{
        self.sliderThumb.frame = CGRectMake(self.view.width/2 - 15, 30, 30, 30);
    } completion:^(BOOL finished) {
        self.previousDealType = self.dealType;
        self.dealType = HOTSPOT;
        self.selectedDeals = self.hotspots;
        [self reloadTableViewAfterDealToggle];
        [self reloadAnnotations];
        [self minimizeMapViewDeal];
    }];
}

- (void) rewardsButtonTouched:(id)sender
{
    [UIView animateWithDuration:0.35f animations:^{
        self.sliderThumb.frame = CGRectMake(self.view.width - 55, 30, 30, 30);
    } completion:^(BOOL finished) {
        self.previousDealType = self.dealType;
        self.dealType = REWARD;
        self.selectedDeals = self.rewards;
        [self reloadTableViewAfterDealToggle];
        [self reloadAnnotations];
        [self minimizeMapViewDeal];
    }];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.selectedDealIndex = [view.annotation.title intValue];
    
    if (self.dealType == HOTSPOT || self.dealType == REWARD) {
        Deal *deal = self.selectedDeals[self.selectedDealIndex];
        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:deal.venue.name];
        self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
        self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
        [self.venueImageView sd_setImageWithURL:deal.venue.imageURL];
        self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
        self.dealTime.text = [deal.dealStartString uppercaseString];
        
        if (self.dealType == HOTSPOT) {
            self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR $%@", [deal.itemName uppercaseString], deal.itemPrice];
            CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
            
            CGFloat descriptionLabelWidth;
            if (textSize.width < self.view.width * .6) {
                descriptionLabelWidth = textSize.width;
            } else {
                descriptionLabelWidth = self.view.width * .6;
            }
            
            self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
            
            self.descriptionLabel.width = descriptionLabelWidth + 10;
        } else {
            self.descriptionLabel.text = [NSString stringWithFormat:@"  %@", [deal.itemName uppercaseString]];
            CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
            
            CGFloat descriptionLabelWidth;
            if (textSize.width < self.view.width * .6) {
                descriptionLabelWidth = textSize.width;
            } else {
                descriptionLabelWidth = self.view.width * .6;
            }
            
            self.dealTime.text = @"";
            
            self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] greenColor];
            
            self.descriptionLabel.width = descriptionLabelWidth + 10;
        }
        
    } else if (self.dealType == HAPPY_HOUR) {
        HappyHour *deal = self.selectedDeals[self.selectedDealIndex];
        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:deal.venue.name];
        self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
        self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
        [self.venueImageView sd_setImageWithURL:deal.venue.imageURL];
        self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
        self.dealTime.text = [deal.happyHourStartString uppercaseString];
        self.descriptionLabel.text = @"  HAPPY HOUR";
        CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
        
        CGFloat descriptionLabelWidth;
        if (textSize.width < self.view.width * .6) {
            descriptionLabelWidth = textSize.width;
        } else {
            descriptionLabelWidth = self.view.width * .6;
        }
        
        self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] purpleColor];
        
        self.descriptionLabel.width = descriptionLabelWidth + 10;
        
    }
    
    [self toggleMapViewDeal:nil];
    
}

-(void)tappedOnSelectedDealInMap:(id)sender
{
    if (self.dealType == HOTSPOT) {
        Deal *deal = self.selectedDeals[self.selectedDealIndex];
        DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
        dealViewController.deal = deal;
        [self.navigationController pushViewController:dealViewController animated:YES];
    } else if (self.dealType == HAPPY_HOUR) {
        HappyHour *happyHour;
        happyHour = self.selectedDeals[self.selectedDealIndex];
        [[[UIAlertView alloc] initWithTitle:happyHour.venue.name message:happyHour.happyHourDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (self.dealType == REWARD) {
        Deal *deal = self.selectedDeals[self.selectedDealIndex];
        if (!deal.locked) {
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Purchase Voucher?" message:@"Would you like to purchase this voucher?"];
            [alertView bk_addButtonWithTitle:@"Yes" handler:^{
                [[RewardManager sharedManager] purchaseRewardItem:deal.dealID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRewardsUpdated object:self];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Failure");
                }];
            }];
            
            [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
            [alertView show];
            return;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Not Enough Points" message:@"You don't have enough points to purchase this item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

-(NSMutableDictionary *)parseStringIntoTwoLines:(NSString *)originalString
{
    NSMutableDictionary *firstAndSecondLine = [[NSMutableDictionary alloc] init];
    NSArray *arrayOfStrings = [originalString componentsSeparatedByString:@" "];
    if ([arrayOfStrings count] == 1) {
        [firstAndSecondLine setObject:@"" forKey:@"firstLine"];
        [firstAndSecondLine setObject:originalString forKey:@"secondLine"];
    } else {
        NSMutableString *firstLine = [[NSMutableString alloc] init];
        NSMutableString *secondLine = [[NSMutableString alloc] init];
        NSInteger firstLineCharCount = 0;
        for (int i = 0; i < [arrayOfStrings count]; i++) {
            if ((firstLineCharCount + [arrayOfStrings[i] length] < 12 && i + 1 != [arrayOfStrings count]) || i == 0) {
                if ([firstLine  length] == 0) {
                    [firstLine appendString:arrayOfStrings[i]];
                } else {
                    [firstLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
                firstLineCharCount = firstLineCharCount + [arrayOfStrings[i] length];
            } else {
                if ([secondLine length] == 0) {
                    [secondLine appendString:arrayOfStrings[i]];
                } else {
                    [secondLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
            }
        }
        [firstAndSecondLine setObject:firstLine forKey:@"firstLine"];
        [firstAndSecondLine setObject:secondLine forKey:@"secondLine"];
    }
    
    return firstAndSecondLine;
}

@end