//
//  DealsTableViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/29/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealsTableViewController.h"
#import "UIView+BounceAnimation.h"
#import "UIView+Shadow.h"
#import "DealDetailViewController.h"
#import "CenterNavigationController.h"
#import "AppDelegate.h"
#import "DealTableViewCell.h"
//#import "HappyHourTableViewCell.h"
#import "APIClient.h"
#import "LocationTracker.h"
#import "Deal.h"
#import "Venue.h"
#import "LoadingIndictor.h"
#import "AnalyticsManager.h"
#import "ContactManager.h"
#import "UIButton+HSNavButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MapKit/MapKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Utilities.h"
#import "HotspotAnnotation.h"
//#import "HappyHour.h"
//#import "HappyHourVenue.h"
#import "RewardTableViewCell.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "RewardManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FreeDrinksExplanationPopupView.h"
#import "AppInviteViewController.h"
#import "FilterViewController.h"
#import "FeedItem.h"
#import "FeedTableViewController.h"
#import "Event.h"

@interface DealsTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,FreeDrinksExplanationViewControllerDelegate>

typedef enum dealTypeStates
{
    HAPPY_HOUR,
    HOTSPOT,
    REWARD
} DealTypes;

@property (strong, nonatomic) UIView *emptyBeaconView;
@property (strong, nonatomic) UIView *enableLocationView;
//@property (strong, nonatomic) UIView *dealTypeToggleContainer;
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
@property (assign, nonatomic) BOOL hasRewardItem;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) UIView *redoSearchContainer;
@property (nonatomic, strong) UIButton *redoSearchButton;
@property (strong, nonatomic) UIView *selectedDealInMap;
@property (nonatomic, assign) int selectedDealIndex;

@property (nonatomic, strong) UIImageView *venueImageView;
@property (nonatomic, strong) UIImageView *backgroundGradient;
@property (nonatomic, strong) UIView *venueView;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *marketPriceLabel;
@property (strong, nonatomic) NSString *numberOfRewardItems;
@property (strong, nonatomic) FeedTableViewController *feedTableViewController;

@property (strong, nonatomic) UILabel *rewardScore;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UIView *priceContainer;

@property (strong, nonatomic) UIView *rewardExplanationContainer;
@property (strong, nonatomic) UILabel *rewardItemLabel;

@property (strong, nonatomic) NSMutableArray *feed;
@property (strong, nonatomic) NSMutableArray *events;

@property (strong, nonatomic) UIImageView *notificationIcon;

@property (strong, nonatomic) UILabel *filterHeaderLabel;
@property (strong, nonatomic) UIButton *filterButton;

@property (strong, nonatomic) FilterViewController *filterViewController;

@end

@implementation DealsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"newHotspotLogo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
//    UIView *searchBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 175, 25)];
//    self.navigationItem.titleView = searchBarContainer;
    
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
    
    self.feedTableViewController = [[FeedTableViewController alloc] initWithLoadingIndicator];
    self.feed = [[NSMutableArray alloc] init];
    self.events = [[NSMutableArray alloc] init];
    self.allVenues = [[NSArray alloc] init];
    self.selectedVenues = [[NSArray alloc] init];
    
    [self initializeFilterViewController];
    
    self.viewContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.viewContainer];
    
    self.initialRadius = 1.6;
    self.hasRewardItem = NO;
    
    self.tableView = [[UITableView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(36.0, 0.0, 50.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.viewContainer addSubview:self.tableView];
    
    UIView *filterHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.width, 50)];
    filterHeader.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:filterHeader];
    
    self.filterHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, self.view.width, 30)];
    self.filterHeaderLabel.text = @"Hot and New";
    self.filterHeaderLabel.font = [ThemeManager boldFontOfSize:14];
    self.filterHeaderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    [filterHeader addSubview:self.filterHeaderLabel];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 50.0f, self.view.width, .5f);
    
    bottomBorder.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;
    [filterHeader.layer addSublayer:bottomBorder];
    
    self.filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.filterButton.size = CGSizeMake(70, 25);
    self.filterButton.x = self.view.width - 80;
    self.filterButton.y = 20;
    self.filterButton.layer.borderWidth = 1;
    self.filterButton.layer.cornerRadius = 2;
    self.filterButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;
    [self.filterButton setImage:[UIImage imageNamed:@"filterButton"] forState:UIControlStateNormal];
    [self.filterButton setImage:[UIImage imageNamed:@"filterButtonSelected"] forState:UIControlStateHighlighted];
    [self.filterButton addTarget:self action:@selector(filterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [filterHeader addSubview:self.filterButton];
    
    [self checkToLaunchInvitationModal];
    
    self.mapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.size.width, self.view.size.height)];
    self.mapViewContainer.hidden = YES;
    [self.viewContainer addSubview:self.mapViewContainer];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.size.width, self.view.size.height - 64)];
    self.mapView.delegate = self;
    [self.mapView setShowsUserLocation:YES];
    self.mapTapped = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(toggleMapViewDeal:)];
    self.mapTapped.numberOfTapsRequired = 1;
    self.mapTapped.numberOfTouchesRequired = 1;
    self.mapTapped.enabled = NO;
    [self.mapView addGestureRecognizer:self.mapTapped];
    [self.mapViewContainer addSubview:self.mapView];
    
    self.isMapViewActive = NO;
    self.isMapViewDealShowing = NO;
    
    self.selectedDealInMap = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 146)];
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
    
    self.redoSearchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.height, self.view.width, 55)];
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
    self.dealTime.font = [ThemeManager regularFontOfSize:14];
    self.dealTime.textColor = [UIColor whiteColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.width = 200;
    self.dealTime.height = 20;
    self.dealTime.x = 8;
    self.dealTime.y=117;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venueView addSubview:self.dealTime];
    
//    self.distanceLabel = [[UILabel alloc] init];
//    self.distanceLabel.font = [ThemeManager lightFontOfSize:14];
//    self.distanceLabel.size = CGSizeMake(67, 20);
//    //self.distanceLabel.layer.cornerRadius = self.distanceLabel.width/2.0;
//    //self.distanceLabel.clipsToBounds = YES;
//    self.distanceLabel.textAlignment = NSTextAlignmentRight;
//    self.distanceLabel.y = 117;
//    self.distanceLabel.x = self.view.width - 77;
//    self.distanceLabel.textColor = [UIColor whiteColor];
//    [self.venueView addSubview:self.distanceLabel];
//    //self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    self.priceContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 117, 80, 20)];
    self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, -5, 50, 30)];
    [self.priceContainer addSubview:self.priceLabel];
    
    self.priceLabel.font = [ThemeManager lightFontOfSize:14];
    self.priceLabel.textColor = [UIColor whiteColor];
    
    self.marketPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 90, 40, 26)];
    self.marketPriceLabel.textColor = [UIColor whiteColor];
    self.marketPriceLabel.textAlignment = NSTextAlignmentCenter;
    self.marketPriceLabel.font = [ThemeManager regularFontOfSize:12];
    
    [self.venueImageView addSubview:self.marketPriceLabel];

    [self.priceContainer addSubview:self.priceLabel];
    [self.venueView addSubview:self.priceContainer];
    
    self.rewardExplanationContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 50, self.view.width, 50)];
//    self.rewardExplanationContainer.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
    self.rewardExplanationContainer.backgroundColor = [[ThemeManager sharedTheme] greenColor];
    self.rewardExplanationContainer.hidden = YES;
    [self.view addSubview:self.rewardExplanationContainer];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(showDrinkModal:)];
    
    [self.rewardExplanationContainer addGestureRecognizer:singleFingerTap];
    
    self.rewardItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, self.view.width, 20)];
    self.rewardItemLabel.font = [ThemeManager regularFontOfSize:16];
    self.rewardItemLabel.textColor = [UIColor whiteColor];
    self.rewardItemLabel.textAlignment = NSTextAlignmentCenter;
    [self.rewardExplanationContainer addSubview:self.rewardItemLabel];
    
    UILabel *rewardItemLabelLineTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.width, 20)];
    rewardItemLabelLineTwo.font = [ThemeManager lightFontOfSize:13];
    rewardItemLabelLineTwo.textColor = [UIColor whiteColor];
    rewardItemLabelLineTwo.textAlignment = NSTextAlignmentCenter;
    rewardItemLabelLineTwo.text = @"Tap on a venue to get your voucher";
    [self.rewardExplanationContainer addSubview:rewardItemLabelLineTwo];

    [self.selectedDealInMap addSubview:self.venueView];
    
    self.mapListToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mapListToggleButton.size = CGSizeMake(70, 70);
    self.mapListToggleButton.x = self.view.width - 80;
    self.mapListToggleButton.y = self.view.height - 80;
    [self.mapListToggleButton setImage:[UIImage imageNamed:@"mapToggleButton"] forState:UIControlStateNormal];
    //self.redoSearchButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    //[self.redoSearchButton setTitle:@"REDO SEARCH IN AREA" forState:UIControlStateNormal];
    //self.inviteFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteFriendsButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    //self.inviteFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., chevronImage.size.width);
    //self.redoSearchButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
    [self.mapListToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mapListToggleButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.mapListToggleButton addTarget:self action:@selector(toggleMapView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mapListToggleButton];
    
//    UIView *rewardItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
//    //rewardItemView.backgroundColor = [UIColor blackColor];
    
    UIView *newsfeedNavContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    //newsfeedNavContainer.backgroundColor = [UIColor blackColor];
    
    UIImageView *newsfeedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newsfeedIcon"]];
    newsfeedIcon.x = 20;
    newsfeedIcon.y = 10;
    
    self.notificationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification"]];
    self.notificationIcon.y = 19;
    self.notificationIcon.x = 32;
    
    UITapGestureRecognizer *singleFingerTapOnNav =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(pushFavoriteFeed:)];
    
    [newsfeedNavContainer addGestureRecognizer:singleFingerTapOnNav];
    
    [newsfeedNavContainer addSubview:newsfeedIcon];
    
    self.notificationIcon.hidden = YES;
    [newsfeedNavContainer addSubview:self.notificationIcon];
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .6;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.3];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    [self.notificationIcon.layer addAnimation:pulseAnimation forKey:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newsfeedNavContainer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundRefreshFeed:) name:kFeedUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNewsfeedNotification:) name:kRemoveNewsfeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyFilterNotification:) name:kApplyFilterNotification object:nil];
//    [self updateRewardItems];

}

-(void)initializeFilterViewController
{
    self.filterViewController = [[FilterViewController alloc] init];
    self.filterViewController.isHotspotToggleOn = YES;
    self.filterViewController.isHappyHourToggleOn = YES;
    self.filterViewController.isHotspotNow = YES;
    self.filterViewController.isHotspotUpcoming = YES;
    self.filterViewController.isHappyHourNow = YES;
    self.filterViewController.isHappyHourUpcoming = YES;
}

- (void) showDrinkModal:(id)sender
{
    FreeDrinksExplanationPopupView *modal = [[FreeDrinksExplanationPopupView alloc] init];
    modal.delegate = self;
    modal.numberOfRewardItems = self.numberOfRewardItems;
    [modal show];
}

- (void)launchInviteFriends
{

        AppInviteViewController *appInviteViewController = [[AppInviteViewController alloc] init];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:appInviteViewController];
        navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager lightFontOfSize:17]};
        navigationController.navigationBar.tintColor = [[ThemeManager sharedTheme] redColor];
        [self presentViewController:navigationController animated:YES completion:nil];
}

- (void) getFavoriteFeed
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedStartRefreshNotification object:self userInfo:nil];
    [[APIClient sharedClient] getFavoriteFeed:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.feed removeAllObjects];
        [self.events removeAllObjects];
        
        for (NSDictionary *feedJSON in responseObject[@"favorite_feed"]) {
            FeedItem *feedItem = [[FeedItem alloc] initWithDictionary:feedJSON];
            [self.feed addObject:feedItem];
        }
        
        for (NSDictionary *eventJSON in responseObject[@"events"]) {
            Event *event = [[Event alloc] initWithDictionary:eventJSON];
            [self.events addObject:event];
        }
        
        //self.feedTableViewController.isRefreshing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedFinishRefreshNotification object:self userInfo:nil];
        self.feedTableViewController.events = self.events;
        self.feedTableViewController.feed = self.feed;
        [[AnalyticsManager sharedManager] openNewsfeedWithNumberOfFollowItems:self.feed.count];
        [self checkNewsfeedNotification];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Favorite Feed Failed");
    }];
    
    [self getFollowRecommendations];
}

-(void)getFollowRecommendations
{
    [[APIClient sharedClient] getFollowRecommendations:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.feedTableViewController.recommendations = responseObject[@"recommendations"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Follow Recommendation Fail");
    }];
}

-(void)checkNewsfeedNotification
{
    if (self.feed.count > 0) {
        NSDate *lastFeedItem = [[NSUserDefaults standardUserDefaults] objectForKey:kFeedUpdateNotification];
        
        FeedItem *feedItem = self.feed[0];
        NSDate *latestFeedItem = feedItem.dateCreated;
        if ([latestFeedItem compare:lastFeedItem] == NSOrderedDescending || lastFeedItem == NULL) {
            [self addNewsfeedNotification];
        } else {
            [self removeNewsfeedNotification:nil];
        }
    }
}

-(void) addNewsfeedNotification
{
    self.notificationIcon.hidden = NO;
}

-(void)removeNewsfeedNotification:(NSNotification *)notification
{
    self.notificationIcon.hidden = YES;
}

- (void) checkToLaunchInvitationModal
{
    
    NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    
    if ((launchCount) % 3 == 0) {
        [self launchInviteFriends];

    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getFavoriteFeed];
    
    [super viewWillAppear:animated];
    if (!self.loadingDeals && !self.lastUpdatedDeals) {
        [self reloadDeals];
    }

//    [self updateRewardItems];
    
//    [self.rewardsViewController updateRewardsScore];
//    self.groupDeal = YES;
    
    [[AnalyticsManager sharedManager] viewedDealTable];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"is hotspot upcoming: %d", self.filterViewController.isHotspotUpcoming);
}

- (UIView *)enableLocationView
{
    if (!_enableLocationView) {
        _enableLocationView = [[UIView alloc] init];
        _enableLocationView.size = CGSizeMake(self.tableView.width, 220);
        _enableLocationView.backgroundColor = [UIColor whiteColor];
        [_enableLocationView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
        
        self.enableLocationLabel = [[UILabel alloc] init];
        self.enableLocationLabel.size = CGSizeMake(250, 220);
        self.enableLocationLabel.font = [ThemeManager lightFontOfSize:16.];
        self.enableLocationLabel.textColor = [UIColor blackColor];
        self.enableLocationLabel.numberOfLines = 6;
        self.enableLocationView.hidden = YES;
        self.enableLocationLabel.textAlignment = NSTextAlignmentCenter;
        self.enableLocationLabel.text = @"Want to see great deals nearby? Hotspot needs to know your location.\n\nAllow Location Access in Privacy > Location Services";
        //        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
        //        footerView.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
        self.enableLocationLabel.centerX = self.enableLocationView.width/2.0;
        self.enableLocationLabel.bottom = self.enableLocationView.height - 30;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.enableLocationView.height)];
        footerView.backgroundColor = [UIColor whiteColor];
        [footerView addSubview:self.enableLocationLabel];
        [self.enableLocationView addSubview:footerView];
        
        if (&UIApplicationOpenSettingsURLString != NULL) {
            self.enableLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.enableLocationButton.size = CGSizeMake(200, 40);
            self.enableLocationButton.centerX = self.enableLocationView.width/2.0;
            self.enableLocationButton.bottom = self.enableLocationView.height - 20;
            self.enableLocationButton.layer.cornerRadius = 4;
            self.enableLocationButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
            [self.enableLocationButton setTitle:@"GO TO HOTSPOT SETTINGS" forState:UIControlStateNormal];
            self.enableLocationButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.enableLocationButton.frame.size.width - ( 50.), 0., 0.);
            self.enableLocationButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 0.);
            self.enableLocationButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
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
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
//        [[LocationTracker sharedTracker] startMonitoringBeaconRegions];
//    }
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
                [[AnalyticsManager sharedManager] viewedDeals:self.selectedVenues.count];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDealsUpdatedNotification object:nil];
            }];
        } failure:^(NSError *error) {
            self.loadingDeals = NO;
            [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        }];
//    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
//        self.loadingDeals = NO;
//        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//        [self showEnableLocationView];
    } else {
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self showEnableLocationView];
    }
    
}

//-(void)refreshFeed:(NSNotification *)notification
//{
//    
//    [self getFavoriteFeed];
//}

-(void)backgroundRefreshFeed:(NSNotification *)notification
{
    
    [self getFavoriteFeed];
    [self reloadDealsInSameLocation];
}

-(void)reloadDealsInSameLocation
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    self.mapCenter = [self.mapView centerCoordinate];
    NSString *radiusString = [NSString stringWithFormat:@"%f", [self getRadius]];
    [self loadDealsNearCoordinate:self.mapCenter withRadius:radiusString withCompletion:^{
        //[self loadDealsNearCoordinate:staticLocation.coordinate withCompletion:^{
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self hideRedoSearchContainer];
        [[AnalyticsManager sharedManager] viewedDeals:self.selectedVenues.count];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDealsUpdatedNotification object:nil];
    }];
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
    [[APIClient sharedClient] getPlacesNearCoordinate:coordinate withRadius:radius success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *venues = [[NSMutableArray alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.mapView removeAnnotations:[self.mapView annotations]];
        self.numberOfRewardItems = responseObject[@"number_of_reward_items"];
        
        for (NSDictionary *venueJSON in responseObject[@"deals"]) {
            Venue *venue = [[Venue alloc] initWithDictionary:venueJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:venue.coordinate.latitude longitude:venue.coordinate.longitude];
            venue.distance = [location distanceFromLocation:dealLocation];
            [venues addObject:venue];
        }
        
        for (NSDictionary *venueJSON in responseObject[@"non_deals"]) {
            Venue *venue = [[Venue alloc] initWithDictionary:venueJSON];
            CLLocation *dealLocation = [[CLLocation alloc] initWithLatitude:venue.coordinate.latitude longitude:venue.coordinate.longitude];
            venue.distance = [location distanceFromLocation:dealLocation];
            [venues addObject:venue];
        }
        
        self.rewardScore.text = [NSString stringWithFormat:@"%@x", self.numberOfRewardItems];
        if ([self.numberOfRewardItems integerValue] > 0) {
            self.hasRewardItem = YES;
            self.rewardExplanationContainer.hidden = NO;
            if ([self.numberOfRewardItems intValue] == 1) {
                self.rewardItemLabel.text = [NSString stringWithFormat:@"You have %@ free drink", self.numberOfRewardItems];
            } else {
                self.rewardItemLabel.text = [NSString stringWithFormat:@"You have %@ free drinks", self.numberOfRewardItems];
            }
        } else  {
            self.hasRewardItem = NO;
            self.rewardExplanationContainer.hidden = YES;
        }
    
        self.allVenues = venues;
        [self filterVenuesAndReloadTableView];
        [self reloadAnnotations];
//        [self reloadTableView];
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
    
    int dealIndex = 0;
    for (Venue *venue in self.selectedVenues) {
        CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(venue.coordinate.latitude, venue.coordinate.longitude);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:dealLocation2D];
        annotation.title = [NSString stringWithFormat:@"%d", dealIndex];
        ++dealIndex;
        [self.mapView addAnnotation:annotation];
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
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = NO;
            pinView.image = [UIImage imageNamed:@"bluePin"];
        } else {
            pinView.image = [UIImage imageNamed:@"bluePin"];
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    return nil;
}

- (void)reloadTableView
{
    if (self.selectedVenues.count > 0){
        [self hideEmptyDealsView];
    }
    else {
        [self showEmptyDealsView];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

//- (void) reloadTableViewAfterDealToggle
//{
//    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
//    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
//    if (self.dealType == REWARD) {
//        //[self.rewardsViewController showRewardsScore];
//        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationLeft];
//    } else if (self.dealType == HAPPY_HOUR) {
//        //[self.rewardsViewController hideRewardsScore];
//        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationRight];
//    } else if (self.dealType == HOTSPOT) {
//        //[self.rewardsViewController hideRewardsScore];
//        if (self.previousDealType == HAPPY_HOUR) {
//            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationLeft];
//        } else {
//            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationRight];
//        }
//    }
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.selectedVenues ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 //   if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSeenHotspotTile]) {
    return self.selectedVenues.count + 1;
   // } else {
     //   return self.selectedVenues.count + 1;
    //}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSeenHotspotTile]) {
            return 0;
        } else {
            return 151;
        }
    } else {
        Venue *venue = self.selectedVenues[indexPath.row - 1];
        if (venue.deal) {
            return 151;
        } else {
            return 101;
        }
    }
}

-(void)hotspotGotItButtonTouched:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasSeenHotspotTile];
    [self.tableView reloadData];
    
}

//-(void)happyHourGotItButtonTouched:(id)sender
//{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasSeenHappyHourTile];
//    [self.tableView reloadData];
//    
//}

- (void)pushFavoriteFeed:(id)sender
{
    self.feedTableViewController.feed = self.feed;
    [self.navigationController pushViewController:self.feedTableViewController animated:YES];
}

-(void)tappedOnCell:(UITapGestureRecognizer *)sender
{
    
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    //NSIndexPath *indexPath = [[self getTableView]  indexPathForCell:self];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row != 0) {
        Venue *venue;
        venue = self.selectedVenues[indexPath.row - 1];
        DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
        dealViewController.venue = venue;
        [self.navigationController pushViewController:dealViewController animated:YES];
    }
}

//- (UITableViewCell *)topHappyHourExplanationTile
//{
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSeenHappyHourTile]) {
//        UIImageView *headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drinkIcon"]];
//        headerIcon.y = 5;
//        headerIcon.centerX = cell.contentView.width/2;
//        [cell.contentView addSubview:headerIcon];
//        
//        UILabel *tileHeading = [[UILabel alloc] init];
//        tileHeading.width = 250;
//        tileHeading.height = 30;
//        tileHeading.centerX = cell.contentView.width/2;
//        tileHeading.y = 30;
//        tileHeading.textAlignment = NSTextAlignmentCenter;
//        tileHeading.textColor = [UIColor blackColor];
//        tileHeading.text = @"HAPPY HOURS ON HOTSPOT";
//        tileHeading.font = [ThemeManager boldFontOfSize:12];
//        [cell.contentView addSubview:tileHeading];
//        
//        UILabel *tileTextBody = [[UILabel alloc] init];
//        tileTextBody.width = cell.contentView.width - 45;
//        tileTextBody.height = 70;
//        tileTextBody.centerX = cell.contentView.width/2;
//        tileTextBody.y = 50;
//        tileTextBody.numberOfLines = 4;
//        tileTextBody.textAlignment = NSTextAlignmentCenter;
//        tileTextBody.textColor = [UIColor blackColor];
//        tileTextBody.text = @"We’ve got the most comprehensive, up-to-date list of Happy Hours near you. Check out Hotspots to save even more with exclusive specials that are available even when happy hour isn’t";
//        tileTextBody.font = [ThemeManager lightFontOfSize:12];
//        [cell.contentView addSubview:tileTextBody];
//        
//        UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [gotItButton setTitle:@"Got It" forState:UIControlStateNormal];
//        gotItButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
//        [gotItButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor]  forState:UIControlStateNormal];
//        //    gotItButton.titleLabel.textColor = [[ThemeManager sharedTheme] lightBlueColor];
//        gotItButton.size = CGSizeMake(60, 40);
//        gotItButton.centerX = cell.contentView.width/2;
//        gotItButton.y = 110;
//        //happyHourButton.backgroundColor = [[[ThemeManager sharedTheme] blueColor] colorWithAlphaComponent:0.2];
//        [gotItButton addTarget:self action:@selector(happyHourGotItButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:gotItButton];
//    }
//    
//    return cell;
//}

- (UITableViewCell *)topHotspotExplanationTile
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSeenHotspotTile]) {
        UIImageView *headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotIcon"]];
        headerIcon.y = 5;
        headerIcon.centerX = cell.contentView.width/2;
        [cell.contentView addSubview:headerIcon];
        
        UILabel *tileHeading = [[UILabel alloc] init];
        tileHeading.width = 150;
        tileHeading.height = 30;
        tileHeading.centerX = cell.contentView.width/2;
        tileHeading.y = 30;
        tileHeading.textAlignment = NSTextAlignmentCenter;
        tileHeading.textColor = [UIColor blackColor];
        tileHeading.text = @"WHAT IS A HOTSPOT?";
        tileHeading.font = [ThemeManager boldFontOfSize:12];
        [cell.contentView addSubview:tileHeading];
        
        UILabel *tileTextBody = [[UILabel alloc] init];
        tileTextBody.width = cell.contentView.width - 45;
        tileTextBody.height = 70;
        tileTextBody.centerX = cell.contentView.width/2;
        tileTextBody.y = 50;
        tileTextBody.numberOfLines = 4;
        tileTextBody.textAlignment = NSTextAlignmentCenter;
        tileTextBody.textColor = [UIColor blackColor];
        tileTextBody.text = @"We buy drinks wholesale from bars, giving you access to exclusive, anytime drink specials. Get craft beers, cocktails, or shots for as little as $1, and never wait for the check when you pay with Hotspot.";
        tileTextBody.font = [ThemeManager lightFontOfSize:12];
        [cell.contentView addSubview:tileTextBody];
        
        UIButton *gotItButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [gotItButton setTitle:@"Got It" forState:UIControlStateNormal];
        gotItButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
        [gotItButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor]  forState:UIControlStateNormal];
        //    gotItButton.titleLabel.textColor = [[ThemeManager sharedTheme] lightBlueColor];
        gotItButton.size = CGSizeMake(60, 40);
        gotItButton.centerX = cell.contentView.width/2;
        gotItButton.y = 110;
        //happyHourButton.backgroundColor = [[[ThemeManager sharedTheme] blueColor] colorWithAlphaComponent:0.2];
        [gotItButton addTarget:self action:@selector(hotspotGotItButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:gotItButton];
    }

    return cell;
}

- (void)seenHotspotTile
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasSeenHotspotTile];
}

- (void) hideRewardContainer
{
    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
        CGRect frame = self.rewardExplanationContainer.frame;
        frame.origin.y = frame.origin.y + 60;
        self.rewardExplanationContainer.frame = frame; // move to new location
    }];
}

- (void) showRewardContainer
{
    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
        CGRect frame = self.rewardExplanationContainer.frame;
        frame.origin.y = frame.origin.y - 60;
        self.rewardExplanationContainer.frame = frame; // move to new location
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self topHotspotExplanationTile];
    } else {
        NSLog(@"INDEX ROW: %ld", (long)indexPath.row);
        Venue *venue;
        venue = self.selectedVenues[indexPath.row - 1];
        
        NSString *DealCellIdentifier = [NSString stringWithFormat:@"Venue: %@", venue.name];
        DealTableViewCell *dealCell = [tableView dequeueReusableCellWithIdentifier:DealCellIdentifier];
        
        if (!dealCell) {
            dealCell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DealCellIdentifier];
            dealCell.backgroundColor = [UIColor clearColor];
            dealCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
        [recognizer setNumberOfTapsRequired:1];
        [dealCell.contentView addGestureRecognizer:recognizer];
        
        dealCell.venue = venue;
        return dealCell;
    }
}

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
    if (self.isMapViewDealShowing) {
        [self toggleMapViewDealWithoutTouch];
    }
    
    [self reloadDealsInSameLocation];

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
            
            self.selectedDealInMap.y = self.view.height;
            
            self.mapTapped.enabled = NO;
            
            [self hideRedoSearchContainer];
        }];
    } else {
        [UIView animateWithDuration:.5f animations:^{
            CGRect theFrame = self.mapView.frame;
            theFrame.size.height -= 146;
            self.mapView.frame = theFrame;
            
            self.selectedDealInMap.y = self.view.height - 146;
        
            
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
                            [self hideRewardContainer];
                        } else {
                            [self.tableView setHidden:NO];
                            [self.mapViewContainer setHidden:YES];
                            [self showRewardContainer];
                        }
                        
                    } completion:^(BOOL finished) {
                        if (finished) {
                            self.isMapViewActive = !self.isMapViewActive;
                            if (self.isMapViewActive) {
                                [self.mapListToggleButton setImage:[UIImage imageNamed:@"listToggleButton"] forState:UIControlStateNormal];
                            } else {
                                [self.mapListToggleButton setImage:[UIImage imageNamed:@"mapToggleButton"] forState:UIControlStateNormal];
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
        frame.origin.y = self.mapView.height - 55;
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
        frame.origin.y = self.mapView.height;
        self.redoSearchContainer.frame = frame; // move to new location
    }];
}

//- (void) happyHourButtonTouched
//{
//    [UIView animateWithDuration:0.35f animations:^{
//        self.sliderThumb.frame = CGRectMake(25, 30, 30, 30);
//        [self hideRewardContainer];
//    } completion:^(BOOL finished) {
//        self.previousDealType = self.dealType;
//        self.dealType = HAPPY_HOUR;
//        self.selectedDeals = self.happyHours;
//        [self reloadTableViewAfterDealToggle];
//        [self reloadAnnotations];
//        [self minimizeMapViewDeal];
//    }];
//}

//- (void) hotspotButtonTouched
//{
//    [UIView animateWithDuration:0.35f animations:^{
//        self.sliderThumb.frame = CGRectMake(self.view.width/2 - 15, 30, 30, 30);
//        [self showRewardContainer];
//    } completion:^(BOOL finished) {
//        self.previousDealType = self.dealType;
//        self.dealType = HOTSPOT;
//        self.selectedDeals = self.hotspots;
//        [self reloadTableViewAfterDealToggle];
//        [self reloadAnnotations];
//        [self minimizeMapViewDeal];
//    }];
//}

//- (void) rewardsButtonTouched:(id)sender
//{
//    [UIView animateWithDuration:0.35f animations:^{
//        self.sliderThumb.frame = CGRectMake(self.view.width - 55, 30, 30, 30);
//    } completion:^(BOOL finished) {
//        self.previousDealType = self.dealType;
//        self.dealType = REWARD;
//        self.selectedDeals = self.rewards;
//        [self reloadTableViewAfterDealToggle];
//        [self reloadAnnotations];
//        [self minimizeMapViewDeal];
//    }];
//}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    self.selectedDealIndex = [view.annotation.title intValue];
//    
//    self.marketPriceLabel.x = self.descriptionLabel.width - 60;
//    
//    if (self.dealType == HOTSPOT) {
//        Deal *deal = self.selectedDeals[self.selectedDealIndex];
//        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:deal.venue.name];
//        self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
//        self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
//        [self.venueImageView sd_setImageWithURL:deal.venue.imageURL];
////        self.distanceLabel.text = [self stringForDistance:deal.venue.distance];
//        NSString *emDash= [NSString stringWithUTF8String:"\xe2\x80\x94"];
//        //    self.priceLabel.text = [NSString stringWithFormat:@"$%@", self.deal.itemPrice];
//        self.dealTime.text = [NSString stringWithFormat:@"%@ %@ %@", [deal.dealStartString uppercaseString], emDash, [self stringForDistance:deal.venue.distance]];
//        
//        if (self.dealType == HOTSPOT) {
//            
//            if (deal.isRewardItem) {
//                self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR FREE", [deal.itemName uppercaseString]];
//                self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] greenColor];
//                //self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
//            } else {
//                self.descriptionLabel.text = [NSString stringWithFormat:@"  %@ FOR $%@", [deal.itemName uppercaseString], deal.itemPrice];
//                self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:16 green:193 blue:255 alpha:255];
//            }
//            
//            CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:14]}];
//            
//            CGFloat descriptionLabelWidth;
//            descriptionLabelWidth = textSize.width;
//            
//            self.descriptionLabel.width = descriptionLabelWidth + 10;
//        }
//    }
//    
//}

-(void)tappedOnSelectedDealInMap:(id)sender
{
    Venue *venue = self.selectedVenues[self.selectedDealIndex];
    DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
    dealViewController.venue = venue;
    [self.navigationController pushViewController:dealViewController animated:YES];
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

-(void)filterButtonTouched:(id)sender
{
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:self.filterViewController];
    navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager mediumFontOfSize:15]};
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)filterVenuesAndReloadTableView
{
    NSPredicate *hotspotFilter;
    NSPredicate *happyHourFilter;
    if (self.filterViewController.isHotspotToggleOn) {
        hotspotFilter = [NSPredicate predicateWithFormat:@"deal != nil"];
    } else {
        hotspotFilter = [NSPredicate predicateWithFormat:@"happyHour != nil"];
    }
    
    if (self.filterViewController.isHappyHourToggleOn) {
        happyHourFilter = [NSPredicate predicateWithFormat:@"happyHour != nil"];
    } else {
        happyHourFilter = [NSPredicate predicateWithFormat:@"deal != nil"];
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[hotspotFilter, happyHourFilter]];
    
    self.selectedVenues = [self.allVenues filteredArrayUsingPredicate:compoundPredicate];
    
    NSLog(@"Venues: %@", self.selectedVenues);
    [self reloadTableView];
}

-(void)applyFilterNotification:(id)sender
{
    [self filterVenuesAndReloadTableView];
}

@end