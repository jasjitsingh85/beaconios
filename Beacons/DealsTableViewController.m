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
#import "SponsoredEventTableViewCell.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "RewardManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FreeDrinksExplanationPopupView.h"
#import "AppInviteViewController.h"
#import "FilterViewController.h"
#import "FaqViewController.h"
#import "FeedItem.h"
#import "FeedTableViewController.h"
#import "Event.h"
#import "SponsoredEvent.h"
#import "RedemptionViewController.h"
#import "EventRedemptionViewController.h"
#import "HelpPopupView.h"

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

//@property (nonatomic, strong) UIImageView *venueImageView;
//@property (nonatomic, strong) UIImageView *backgroundGradient;
@property (nonatomic, strong) UIView *venueView;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
//@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UILabel *placeType;
@property (strong, nonatomic) UILabel *itemPriceLabel;
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

@property (strong, nonatomic) SponsoredEventTableViewCell *eventCell;

@property (strong, nonatomic) FaqViewController *faqViewController;

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
    self.sponsoredEvents = [[NSArray alloc] init];
    self.selectedVenues = [[NSArray alloc] init];
    
    [self initializeFilterViewController];
    
    
    self.viewContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.viewContainer];
    
    self.initialRadius = 0.5;
    self.hasRewardItem = NO;
    
    self.tableView = [[UITableView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.viewContainer addSubview:self.tableView];
    
//    UIView *filterHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.width, 50)];
//    filterHeader.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:filterHeader];
    
//    self.filterHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 17, self.view.width, 30)];
//    self.filterHeaderLabel.text = @"Hotspots & Happy Hours";
//    self.filterHeaderLabel.font = [ThemeManager boldFontOfSize:12];
//    self.filterHeaderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//    [filterHeader addSubview:self.filterHeaderLabel];
    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.frame = CGRectMake(0.0f, 50.0f, self.view.width, .5f);
    
//    bottomBorder.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;
//    [filterHeader.layer addSublayer:bottomBorder];
    
//    self.filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.filterButton.size = CGSizeMake(70, 25);
//    self.filterButton.x = self.view.width - 80;
//    self.filterButton.y = 20;
//    self.filterButton.layer.borderWidth = 1;
//    self.filterButton.layer.cornerRadius = 2;
//    self.filterButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;
//    [self.filterButton setImage:[UIImage imageNamed:@"filterButton"] forState:UIControlStateNormal];
//    [self.filterButton setImage:[UIImage imageNamed:@"filterButtonSelected"] forState:UIControlStateHighlighted];
//    [self.filterButton addTarget:self action:@selector(filterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [filterHeader addSubview:self.filterButton];
    
    [self checkToLaunchInvitationModal];
    
    self.mapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.size.width, self.view.size.height)];
    self.mapViewContainer.hidden = YES;
    [self.viewContainer addSubview:self.mapViewContainer];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.size.width, self.view.size.height - 64)];
    self.mapView.delegate = self;
    [self.mapView setShowsUserLocation:YES];
//    self.mapTapped = [[UITapGestureRecognizer alloc]
//      initWithTarget:self action:@selector(toggleMapViewDeal:)];
//    self.mapTapped.numberOfTapsRequired = 1;
//    self.mapTapped.numberOfTouchesRequired = 1;
//    self.mapTapped.enabled = NO;
//    [self.mapView addGestureRecognizer:self.mapTapped];
    [self.mapViewContainer addSubview:self.mapView];
    
    self.isMapViewActive = NO;
    self.isMapViewDealShowing = NO;
    self.faqViewController = [[FaqViewController alloc] initForModal];
    
    self.selectedDealInMap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 210, HOTSPOT_HEIGHT)];
    self.selectedDealInMap.layer.cornerRadius = 6;
    self.selectedDealInMap.backgroundColor = [UIColor whiteColor];
    self.selectedDealInMap.layer.shadowColor = [UIColor blackColor].CGColor;
    self.selectedDealInMap.layer.shadowOffset = CGSizeMake(4, 4);
    self.selectedDealInMap.layer.shadowOpacity = .35;
    self.selectedDealInMap.layer.shadowRadius = 1.0;
    UITapGestureRecognizer *selectedDealTapped = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(tappedOnSelectedDealInMap:)];
    selectedDealTapped.numberOfTapsRequired = 1;
    selectedDealTapped.numberOfTouchesRequired = 1;
    self.selectedDealInMap.userInteractionEnabled = YES;
    [self.selectedDealInMap addGestureRecognizer:selectedDealTapped];
    [self.mapViewContainer addSubview:self.selectedDealInMap];
    
//    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
//    [panRec setDelegate:self];
//    [self.mapView addGestureRecognizer:panRec];
    
    self.redoSearchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.height, self.view.width, 35)];
    self.redoSearchContainer.centerX = self.view.width/2;
    self.redoSearchContainer.backgroundColor = [UIColor whiteColor];
    [self.mapView addSubview:self.redoSearchContainer];
    
    self.redoSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redoSearchButton.size = CGSizeMake(160, 22);
    self.redoSearchButton.centerX = self.redoSearchContainer.width/2.0;
    self.redoSearchButton.centerY = self.redoSearchContainer.height/2.0;
//    [self.redoSearchButton setImage:[UIImage imageNamed:@"redoSearchContainer"] forState:UIControlStateNormal];
    //self.redoSearchButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
    [self.redoSearchButton setTitle:@"REDO SEARCH IN AREA" forState:UIControlStateNormal];
    //self.inviteFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteFriendsButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    //self.inviteFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., chevronImage.size.width);
    self.redoSearchButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
    self.redoSearchButton.layer.cornerRadius = 3;
    self.redoSearchButton.layer.borderWidth = 1;
    self.redoSearchButton.backgroundColor = [UIColor whiteColor];
    self.redoSearchButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
    [self.redoSearchButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    [self.redoSearchButton setTitleColor:[[[ThemeManager sharedTheme] redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.redoSearchButton addTarget:self action:@selector(redoSearchButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.redoSearchContainer addSubview:self.redoSearchButton];
    
    self.venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.selectedDealInMap.frame.size.width, self.selectedDealInMap.height)];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:12];
    self.venueLabelLineOne.textColor = [UIColor blackColor];
    self.venueLabelLineOne.width = 150;
    self.venueLabelLineOne.x = 10;
    self.venueLabelLineOne.height = 15;
    self.venueLabelLineOne.y = 6;
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.venueView addSubview:self.venueLabelLineOne];
    
    self.descriptionLabel = [[UILabel alloc] init];
    //self.descriptionLabel.width = self.venuePreviewView.size.width * .6;
    self.descriptionLabel.height = 22;
    self.descriptionLabel.x = 0;
    self.descriptionLabel.y = 32;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:11];
    //self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.venueView addSubview:self.descriptionLabel];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager regularFontOfSize:9];
    self.dealTime.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.x = 10;
    self.dealTime.height = 20;
    self.dealTime.width = self.selectedDealInMap.width;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venueView addSubview:self.dealTime];
    
    self.marketPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 40, 26)];
    self.marketPriceLabel.textColor = [UIColor whiteColor];
    self.marketPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.marketPriceLabel.font = [ThemeManager regularFontOfSize:11];
    [self.venueView addSubview:self.marketPriceLabel];
    
    self.itemPriceLabel = [[UILabel alloc] init];
    self.itemPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.itemPriceLabel.font = [ThemeManager boldFontOfSize:11];
    self.itemPriceLabel.textColor = [UIColor whiteColor];
    self.itemPriceLabel.height = 26;
    self.itemPriceLabel.y = 30;
    [self.venueView addSubview:self.itemPriceLabel];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager lightFontOfSize:14];
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.venueView addSubview:self.distanceLabel];
    
    [self.venueView addSubview:self.marketPriceLabel];
//    [self.priceContainer addSubview:self.priceLabel];
//    [self.venueView addSubview:self.priceContainer];
    
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
    self.mapListToggleButton.size = CGSizeMake(70, 62);
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushFavoriteFeed:) name:kPushFavoriteFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundRefreshFeed:) name:kFeedUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNewsfeedNotification:) name:kRemoveNewsfeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyFilterNotification:) name:kApplyFilterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterToggleFavorite:) name:kRefreshAfterToggleFavoriteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFaq:) name:@"ShowFaq" object:nil];
//    [self updateRewardItems];

}

-(void)initializeFilterViewController
{
    self.filterViewController = [[FilterViewController alloc] init];
    self.filterViewController.isHotspotToggleOn = YES;
    self.filterViewController.isHappyHourToggleOn = YES;
    self.filterViewController.now = YES;
    self.filterViewController.upcoming = YES;
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
        self.feedTableViewController.events = self.events;
        self.feedTableViewController.feed = self.feed;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedFinishRefreshNotification object:self userInfo:nil];
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
        _emptyBeaconView.size = CGSizeMake(self.tableView.width, self.view.height);
        _emptyBeaconView.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        
        UIView *backgroundTile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 130)];
        backgroundTile.backgroundColor = [UIColor whiteColor];
        [_emptyBeaconView addSubview:backgroundTile];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotIcon"]];
        imageView.centerX = self.view.width/2;
        imageView.y = 15;
        
        UILabel *tileHeading = [[UILabel alloc] init];
        tileHeading.width = 150;
        tileHeading.height = 30;
        tileHeading.centerX = self.view.width/2;
        tileHeading.y = 40;
        tileHeading.textAlignment = NSTextAlignmentCenter;
        tileHeading.textColor = [UIColor blackColor];
        tileHeading.text = @"No Nearby Venues";
        tileHeading.font = [ThemeManager boldFontOfSize:12];
        [backgroundTile addSubview:tileHeading];
        
        UILabel *tileTextBody = [[UILabel alloc] init];
        tileTextBody.width = self.view.width - 100;
        tileTextBody.height = 70;
        tileTextBody.centerX = self.view.width/2;
        tileTextBody.y = 50;
        tileTextBody.numberOfLines = 4;
        tileTextBody.textAlignment = NSTextAlignmentCenter;
        tileTextBody.textColor = [UIColor blackColor];
        tileTextBody.text = @"Adjust filters or move the map to a different area to see nearby venues with Hotspots or Happy Hours.";
        tileTextBody.font = [ThemeManager lightFontOfSize:12];
        [backgroundTile addSubview:tileTextBody];
        
        
        [backgroundTile addSubview:imageView];
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
    LocationTracker *locationTracker = [[LocationTracker alloc] init];
    if (locationTracker.authorized) {
        [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
        [locationTracker fetchCurrentLocation:^(CLLocation *location) {
            //REMOVE THIS LINE AFTER DEMO
//            CLLocation *staticLocation = [[CLLocation alloc] initWithLatitude:47.667759 longitude:-122.312766];
            //REMOVE THIS LINE AFTER DEMO
            [self loadDealsNearCoordinate:location.coordinate withRadius:[NSString stringWithFormat:@"%f", self.initialRadius] withCompletion:^{
//            [self loadDealsNearCoordinate:staticLocation.coordinate withRadius:[NSString stringWithFormat:@"%f", self.initialRadius] withCompletion:^{
                self.loadingDeals = NO;
//                self.mapCenter = staticLocation.coordinate;
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

-(void)refreshAfterToggleFavorite:(NSNotification *)notification
{
    [self getFavoriteFeed];
}

-(void)reloadDealsInSameLocation
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    self.mapCenter = [self.mapView centerCoordinate];
    NSString *radiusString = [NSString stringWithFormat:@"%f", [self getRadius]];
    [self loadDealsNearCoordinate:self.mapCenter withRadius:radiusString withCompletion:^{
//    [self loadDealsNearCoordinate:staticLocation.coordinate withCompletion:^{
        self.loadingDeals = NO;
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        [self hideRedoSearchContainer:YES];
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
        NSMutableArray *sponsoredEvents = [[NSMutableArray alloc] init];
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
        
        for (NSDictionary *sponsoredEventJSON in responseObject[@"sponsored_events"]) {
            SponsoredEvent *sponsoredEvent = [[SponsoredEvent alloc] initWithDictionary:sponsoredEventJSON];
            [sponsoredEvents addObject:sponsoredEvent];
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
        self.sponsoredEvents = sponsoredEvents;
        [self filterVenuesAndReloadTableView];
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
    
    int nonDealIndex = 0;
    for (Venue *venue in self.selectedVenues) {
        if (!venue.deal) {
            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(venue.coordinate.latitude, venue.coordinate.longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:dealLocation2D];
            annotation.title = [NSString stringWithFormat:@"%d", nonDealIndex];
            [self.mapView addAnnotation:annotation];
        }
        ++nonDealIndex;
    }
    
    int dealIndex = 0;
    for (Venue *venue in self.selectedVenues) {
        if (venue.deal) {
            CLLocationCoordinate2D dealLocation2D = CLLocationCoordinate2DMake(venue.coordinate.latitude, venue.coordinate.longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:dealLocation2D];
            annotation.title = [NSString stringWithFormat:@"%d", dealIndex];
            [self.mapView addAnnotation:annotation];
        }
        ++dealIndex;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    self.selectedDealIndex = [annotation.title intValue];
    Venue *venue = self.selectedVenues[self.selectedDealIndex];
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = NO;
            if (!isEmpty(venue.deal)) {
                pinView.image = [UIImage imageNamed:@"newRedPin"];
            } else {
                pinView.image = [UIImage imageNamed:@"newGrayPin"];
            }
        } else {
            if (!isEmpty(venue.deal)) {
                pinView.image = [UIImage imageNamed:@"newRedPin"];
            } else {
                pinView.image = [UIImage imageNamed:@"newGrayPin"];
            }
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    return nil;
}

- (void)reloadTableView
{
    if (self.selectedVenues.count > 0 || self.sponsoredEvents.count){
        [self hideEmptyDealsView];
    }
    else {
        [self showEmptyDealsView];
    }
    
    [self.tableView reloadData];
    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sponsoredEvents.count && self.selectedVenues.count) {
        return 2;
    } else if (self.sponsoredEvents.count || self.selectedVenues.count) {
        return 2;
    } else {
        return 0;
    }
//    return 2;

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.sponsoredEvents.count) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        /* Create custom view to display section header... */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8.5, tableView.frame.size.width, 15)];
        [label setFont:[ThemeManager mediumFontOfSize:10]];
        NSString *string = @"FEATURED EVENTS";
        [label setText:string];
        [view addSubview:label]
        ;
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 30, view.width, 1.f)];
        bottomBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        
        NSRange range = [label.text rangeOfString:@"FEATURED"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText addAttribute:NSFontAttributeName value:[ThemeManager italicFontOfSize:10] range:range];
        label.attributedText = attributedText;
        
        [view addSubview:bottomBorder];
        
        UIButton *featuredEventHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        featuredEventHelpButton.size = CGSizeMake(30, 30);
        featuredEventHelpButton.x = 98;
        featuredEventHelpButton.y = .5;
        [featuredEventHelpButton setImage:[UIImage imageNamed:@"helpIcon"] forState:UIControlStateNormal];
        [featuredEventHelpButton addTarget:self action:@selector(showFeaturedEventExplanationModal:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:featuredEventHelpButton];
        
        [view setBackgroundColor:[UIColor whiteColor]];
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        /* Create custom view to display section header... */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8.5, tableView.frame.size.width, 15)];
        [label setFont:[ThemeManager mediumFontOfSize:10]];
        NSString *string = @"HOTSPOTS & HAPPY HOURS";
        [label setText:string];
        [view addSubview:label]
        ;
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 30, view.width, 1.f)];
        bottomBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        [view addSubview:bottomBorder];
        
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        filterButton.size = CGSizeMake(100, 35);
        filterButton.x = 235;
        filterButton.y = -1.75;
        [filterButton setImage:[UIImage imageNamed:@"newFilterButton"] forState:UIControlStateNormal];
        [filterButton setImage:[UIImage imageNamed:@"newFilterButtonSelected"] forState:UIControlStateSelected];
        [filterButton addTarget:self action:@selector(filterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:filterButton];
        
        NSRange range = [label.text rangeOfString:@"HOTSPOTS &"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText addAttribute:NSFontAttributeName value:[ThemeManager italicFontOfSize:10] range:range];
        label.attributedText = attributedText;
        
        UIButton *hotspotHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        hotspotHelpButton.size = CGSizeMake(30, 30);
        hotspotHelpButton.x = 145;
        hotspotHelpButton.y = .5;
        [hotspotHelpButton setImage:[UIImage imageNamed:@"helpIcon"] forState:UIControlStateNormal];
        [hotspotHelpButton addTarget:self action:@selector(showHotspotExplanationModal:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:hotspotHelpButton];
        
        [view setBackgroundColor:[UIColor whiteColor]];
        return view;
    }
}

- (void)showFeaturedEventExplanationModal:(id)sender
{
    HelpPopupView *featuredEventPopup = [[HelpPopupView alloc] init];
    [featuredEventPopup showFeaturedEventExplanationModal];
}

- (void)showHotspotExplanationModal:(id)sender
{
    HelpPopupView *hotspotPopup = [[HelpPopupView alloc] init];
    [hotspotPopup showHotspotExplanationModal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && !self.sponsoredEvents.count) {
        return 0;
    } else if (section == 1 && !self.selectedVenues.count) {
        return 0;
    } else {
        return 30;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.sponsoredEvents.count) {
            return 1;
        } else {
            return 0;
        }
    } else {
         return self.selectedVenues.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 201;
    } else {
//        if (indexPath.row == 0){
//            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSeenHotspotTile]) {
//                return 0;
//            } else {
//                return 151;
//            }
//        } else {
            Venue *venue = self.selectedVenues[indexPath.row];
            if (venue.deal) {
                return 151;
            } else {
                return 101;
            }
//        }
    }
}

//-(void)hotspotGotItButtonTouched:(id)sender
//{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasSeenHotspotTile];
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
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        SponsoredEvent *event = self.sponsoredEvents[self.eventCell.pageControl.currentPage];
        if (event.eventStatusOption == EventStatusGoing || event.eventStatusOption == EventStatusRedeemed) {
            EventRedemptionViewController *eventRedemptionViewController = [[EventRedemptionViewController alloc] init];
            if (event.eventStatusOption == EventStatusRedeemed) {
                eventRedemptionViewController.openToChatRoom = YES;
            } else {
                eventRedemptionViewController.openToChatRoom = NO;
            }
            eventRedemptionViewController.sponsoredEvent = event;
//            [eventRedemptionViewController refreshSponsoredEventData];
            [self.navigationController pushViewController:eventRedemptionViewController animated:YES];
//            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//            [appDelegate setSelectedViewControllerToSponsoredEvent:event];
        } else {
            DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
            dealViewController.sponsoredEvent = event;
            [self.navigationController pushViewController:dealViewController animated:YES];
        }
    } else {
        Venue *venue;
        venue = self.selectedVenues[indexPath.row];
        DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
        dealViewController.venue = venue;
        [self.navigationController pushViewController:dealViewController animated:YES];
    }
}


//- (UITableViewCell *)topHotspotExplanationTile
//{
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSeenHotspotTile]) {
//        UIImageView *headerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotIcon"]];
//        headerIcon.y = 5;
//        headerIcon.centerX = cell.contentView.width/2;
//        [cell.contentView addSubview:headerIcon];
//        
//        UILabel *tileHeading = [[UILabel alloc] init];
//        tileHeading.width = 150;
//        tileHeading.height = 30;
//        tileHeading.centerX = cell.contentView.width/2;
//        tileHeading.y = 30;
//        tileHeading.textAlignment = NSTextAlignmentCenter;
//        tileHeading.textColor = [UIColor blackColor];
//        tileHeading.text = @"WHAT IS A HOTSPOT?";
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
//        tileTextBody.text = @"We buy drinks wholesale from bars, giving you access to exclusive, anytime drink specials. Get craft beers, cocktails, or shots for as little as $1, and never wait for the check when you pay with Hotspot.";
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
//        [gotItButton addTarget:self action:@selector(hotspotGotItButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:gotItButton];
//    }
//
//    return cell;
//}

//- (void)seenHotspotTile
//{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasSeenHotspotTile];
//}

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
    if (indexPath.section == 0) {
        NSString *DealCellIdentifier = [NSString stringWithFormat:@"events"];
        self.eventCell = [tableView dequeueReusableCellWithIdentifier:DealCellIdentifier];
        
        if (!self.eventCell) {
            self.eventCell = [[SponsoredEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DealCellIdentifier];
            self.eventCell.backgroundColor = [UIColor clearColor];
            self.eventCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
            [recognizer setNumberOfTapsRequired:1];
            [self.eventCell.contentView addGestureRecognizer:recognizer];
        }
        
        if (self.sponsoredEvents.count) {
            self.eventCell.events = self.sponsoredEvents;
        }
        
        return self.eventCell;
    } else {
//        if (indexPath.row == 0) {
//            return [self topHotspotExplanationTile];
//        } else {
            Venue *venue;
//            venue = self.selectedVenues[indexPath.row - 1];
            venue = self.selectedVenues[indexPath.row];
            
            NSString *DealCellIdentifier = [NSString stringWithFormat:@"Venue: %@", venue.name];
            DealTableViewCell *dealCell = [tableView dequeueReusableCellWithIdentifier:DealCellIdentifier];
            
            if (!dealCell) {
                dealCell = [[DealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DealCellIdentifier];
                dealCell.backgroundColor = [UIColor clearColor];
                dealCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dealCell.venue = venue;
                
                UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
                [recognizer setNumberOfTapsRequired:1];
                [dealCell.contentView addGestureRecognizer:recognizer];
            }
        
            return dealCell;
//        }
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
//    if (self.isMapViewDealShowing) {
//        [self toggleMapViewDealWithoutTouch];
//    }
    
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

//
//- (void)toggleMapViewDeal:(id)sender
//{
//    [self toggleMapViewDealWithoutTouch];
//}

- (void) showMapViewDeal:(CGPoint)point
{
//    if (!self.isMapViewDealShowing) {
//        [UIView animateWithDuration:.5f animations:^{
//            CGRect theFrame = self.mapView.frame;
//            theFrame.size.height -= 146;
//            self.mapView.frame = theFrame;
//            
//            self.selectedDealInMap.y = self.view.height - 146;
//            
//            
//            self.mapTapped.enabled = YES;
//            
//            self.isMapViewDealShowing = !self.isMapViewDealShowing;
//            
//        }];
//    }
    self.selectedDealInMap.x = [self getUpdatedX:point.x];
    self.selectedDealInMap.y = [self getUpdatedY:point.y];
    
}

-(CGFloat)getUpdatedX:(CGFloat)pointX
{
    CGFloat x = (pointX/2) - self.selectedDealInMap.width/2;
    if (x < 10) {
        return 10;
    } else if (x > (320 - self.selectedDealInMap.width - 10)) {
        return 320 - self.selectedDealInMap.width - 10;
    } else {
        return x;
    }
}

-(CGFloat)getUpdatedY:(CGFloat)pointY
{
    CGFloat y = (pointY/2) - 60;
    if (y < 10 + HOTSPOT_HEIGHT) {
        return y + 50 + HOTSPOT_HEIGHT;
    } else {
        return y - (self.selectedDealInMap.height - HOTSPOT_HEIGHT);
    }
}

//- (void) toggleMapViewDealWithoutTouch
//{
//    if (self.isMapViewDealShowing) {
//        [UIView animateWithDuration:.5f animations:^{
//            CGRect theFrame = self.mapView.frame;
//            theFrame.size.height += 146;
//            self.mapView.frame = theFrame;
//            
//            self.selectedDealInMap.y = self.view.height;
//            
//            self.mapTapped.enabled = NO;
//            
//            [self hideRedoSearchContainer];
//        }];
//    } else {
//        [UIView animateWithDuration:.5f animations:^{
//            CGRect theFrame = self.mapView.frame;
//            theFrame.size.height -= 146;
//            self.mapView.frame = theFrame;
//            
//            self.selectedDealInMap.y = self.view.height - 146;
//        
//            
//            self.mapTapped.enabled = YES;
//            
//        }];
//    }
//    self.isMapViewDealShowing = !self.isMapViewDealShowing;
//}

//- (void) minimizeMapViewDeal
//{
//    if (self.isMapViewDealShowing) {
//        [self toggleMapViewDealWithoutTouch];
//    }
//}

- (void)toggleMapView:(id)sender
{
    [self toggleMapViewFrame];
}

- (void)toggleMapViewFrame
{
    [self hideRedoSearchContainer:NO];
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

//- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
//    
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && self.isMapViewActive){
//        [self showRedoSearchContainer];
//    }
//}

- (void) showRedoSearchContainer
{
//    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
//        CGRect frame = self.mapLabel.frame;
//        frame.origin.x = self.view.width + self.mapLabel.width;
//        self.mapLabel.frame = frame; // move to new location
//    }];
    
    [UIView animateWithDuration:0.5 animations:^{  // animate the following:
        CGRect frame = self.redoSearchContainer.frame;
        frame.origin.y = self.mapView.height - 35;
        self.redoSearchContainer.frame = frame;
    }];
    
    
}

- (void) hideRedoSearchContainer:(BOOL)animated
{
//    [UIView animateWithDuration:0.8 animations:^{  // animate the following:
//        CGRect frame = self.mapLabel.frame;
//        frame.origin.x = self.view.width - self.mapLabel.width;
//        self.mapLabel.frame = frame; // move to new location
//    }];
    if (animated) {
        [UIView animateWithDuration:0.35 animations:^{  // animate the following:
            CGRect frame = self.redoSearchContainer.frame;
            frame.origin.y = self.mapView.height;
            self.redoSearchContainer.frame = frame; // move to new location
        }];
    } else {
        CGRect frame = self.redoSearchContainer.frame;
        frame.origin.y = self.mapView.height;
        self.redoSearchContainer.frame = frame;
    }
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

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self hideSelectedDeal];
    [self showRedoSearchContainer];
}

- (void)hideSelectedDeal
{
    [UIView transitionWithView:self.selectedDealInMap
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.selectedDealInMap.hidden = YES;
}

- (void)showSelectedDeal
{
    [UIView transitionWithView:self.selectedDealInMap
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.selectedDealInMap.hidden = NO;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.selectedDealIndex = [view.annotation.title intValue];
    Venue *venue = self.selectedVenues[self.selectedDealIndex];
    self.venueLabelLineOne.text = [venue.name uppercaseString];
    
    CGPoint windowPoint = [view convertPoint:[view center] toView:self.view];
    [self updateSelectedDealInMap:venue];
    [self showMapViewDeal:windowPoint];
    [self showSelectedDeal];
    
//    [self toggleMapViewDeal:nil];
    
}

-(void)tappedOnSelectedDealInMap:(id)sender
{
    Venue *venue = self.selectedVenues[self.selectedDealIndex];
    DealDetailViewController *dealViewController = [[DealDetailViewController alloc] init];
    dealViewController.venue = venue;
    [self.navigationController pushViewController:dealViewController animated:YES];
}

//-(NSMutableDictionary *)parseStringIntoTwoLines:(NSString *)originalString
//{
//    NSMutableDictionary *firstAndSecondLine = [[NSMutableDictionary alloc] init];
//    NSArray *arrayOfStrings = [originalString componentsSeparatedByString:@" "];
//    if ([arrayOfStrings count] == 1) {
//        [firstAndSecondLine setObject:@"" forKey:@"firstLine"];
//        [firstAndSecondLine setObject:originalString forKey:@"secondLine"];
//    } else {
//        NSMutableString *firstLine = [[NSMutableString alloc] init];
//        NSMutableString *secondLine = [[NSMutableString alloc] init];
//        NSInteger firstLineCharCount = 0;
//        for (int i = 0; i < [arrayOfStrings count]; i++) {
//            if ((firstLineCharCount + [arrayOfStrings[i] length] < 12 && i + 1 != [arrayOfStrings count]) || i == 0) {
//                if ([firstLine  length] == 0) {
//                    [firstLine appendString:arrayOfStrings[i]];
//                } else {
//                    [firstLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
//                }
//                firstLineCharCount = firstLineCharCount + [arrayOfStrings[i] length];
//            } else {
//                if ([secondLine length] == 0) {
//                    [secondLine appendString:arrayOfStrings[i]];
//                } else {
//                    [secondLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
//                }
//            }
//        }
//        [firstAndSecondLine setObject:firstLine forKey:@"firstLine"];
//        [firstAndSecondLine setObject:secondLine forKey:@"secondLine"];
//    }
//    
//    return firstAndSecondLine;
//}

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
    NSPredicate *dealTypeFilter;
    NSPredicate *timeFilter;
//    NSCompoundPredicate *compoundPredicate;
    if (self.filterViewController.isHotspotToggleOn && !self.filterViewController.isHappyHourToggleOn) {
        dealTypeFilter = [NSPredicate predicateWithFormat:@"deal != nil"];
        if (self.filterViewController.now && !self.filterViewController.upcoming) {
            timeFilter = [NSPredicate predicateWithFormat:@"deal.now == YES"];
        } else if (!self.filterViewController.now && self.filterViewController.upcoming) {
            timeFilter = [NSPredicate predicateWithFormat:@"deal.now == NO"];
        }
    } else if (!self.filterViewController.isHotspotToggleOn && self.filterViewController.isHappyHourToggleOn) {
        dealTypeFilter = [NSPredicate predicateWithFormat:@"happyHour != nil"];
        if (self.filterViewController.now && !self.filterViewController.upcoming) {
            timeFilter = [NSPredicate predicateWithFormat:@"happyHour.now == YES"];
        } else if (!self.filterViewController.now && self.filterViewController.upcoming) {
            timeFilter = [NSPredicate predicateWithFormat:@"happyHour.now == NO"];
        }
    } else {
        if (self.filterViewController.isHotspotToggleOn && self.filterViewController.isHappyHourToggleOn) {
            dealTypeFilter = [NSPredicate predicateWithValue:YES];
        } else {
            dealTypeFilter = [NSPredicate predicateWithValue:NO];
        }
        
        if (self.filterViewController.now && !self.filterViewController.upcoming) {
            timeFilter = [NSPredicate predicateWithFormat:@"(deal.now == YES) OR (happyHour.now == YES)"];
        } else if (!self.filterViewController.now && self.filterViewController.upcoming) {
            timeFilter = [NSPredicate predicateWithFormat:@"(deal.now == NO) OR (happyHour.now == NO)"];
        }
    }
    
    if (self.filterViewController.now && self.filterViewController.upcoming) {
        timeFilter = [NSPredicate predicateWithValue:YES];
    } else if (!self.filterViewController.now && !self.filterViewController.upcoming) {
        timeFilter = [NSPredicate predicateWithValue:NO];
    }
    
    NSCompoundPredicate *compoundPredicateWithNowAndUpcoming = [NSCompoundPredicate andPredicateWithSubpredicates:@[dealTypeFilter, timeFilter]];
    
    self.selectedVenues = [self.allVenues filteredArrayUsingPredicate:compoundPredicateWithNowAndUpcoming];
    
    [self updateFilterText];
    [self reloadAnnotations];
    [self reloadTableView];
}

-(void)updateFilterText
{
    if (self.filterViewController.isHappyHourToggleOn && self.filterViewController.isHotspotToggleOn) {
        if (self.filterViewController.now && self.filterViewController.upcoming) {
            self.filterHeaderLabel.text = @"Hotspots & Happy Hours";
        } else if (self.filterViewController.now || self.filterViewController.upcoming) {
            if (self.filterViewController.now) {
                self.filterHeaderLabel.text = @"Active Hotspots & Happy Hours";
            } else {
                self.filterHeaderLabel.text = @"Active Hotspots & Happy Hours";
            }
        } else {
            self.filterHeaderLabel.text = @"";
        }
    } else if (self.filterViewController.isHappyHourToggleOn || self.filterViewController.isHotspotToggleOn) {
        if (self.filterViewController.now && self.filterViewController.upcoming) {
            if (self.filterViewController.isHotspotToggleOn) {
                self.filterHeaderLabel.text = @"Hotspots";
            } else {
                self.filterHeaderLabel.text = @"Happy Hours";
            }
        } else if (self.filterViewController.now && !self.filterViewController.upcoming) {
            if (self.filterViewController.isHotspotToggleOn) {
                self.filterHeaderLabel.text = @"Active Hotspots";
            } else {
                self.filterHeaderLabel.text = @"Active Happy Hours";
            }
        } else if (!self.filterViewController.now && self.filterViewController.upcoming) {
            if (self.filterViewController.isHotspotToggleOn) {
                self.filterHeaderLabel.text = @"Upcoming Hotspots";
            } else {
                self.filterHeaderLabel.text = @"Upcoming Happy Hours";
            }
        }
    } else {
        self.filterHeaderLabel.text = @"";
    }
}

-(void)applyFilterNotification:(id)sender
{
    [self filterVenuesAndReloadTableView];
}

-(void)updateSelectedDealInMap:(Venue *)venue
{
    NSString *emDash= [NSString stringWithUTF8String:"\xe2\x80\x94"];
    
    if (venue.deal) {
        self.selectedDealInMap.height = HOTSPOT_HEIGHT;
        if (venue.neighborhood != (NSString *)[NSNull null]) {
            self.dealTime.text = [NSString stringWithFormat:@"%@ %@ %@ | %@", [venue.deal.dealStartString uppercaseString], emDash, [venue.neighborhood uppercaseString],[self stringForDistance:venue.distance]];
        } else {
            self.dealTime.text = [NSString stringWithFormat:@"%@ %@ %@", [venue.deal.dealStartString uppercaseString], emDash, [self stringForDistance:venue.distance]];
        }
        NSString *marketPriceString = [NSString stringWithFormat:@"$%@", venue.deal.itemMarketPrice];
        self.marketPriceLabel.text = marketPriceString;
        NSDictionary* attributes = @{
                                     NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     };
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.marketPriceLabel.text attributes:attributes];
        self.marketPriceLabel.attributedText = attrText;
        self.descriptionLabel.text = [NSString stringWithFormat:@"   %@ FOR", [venue.deal.itemName uppercaseString]];
        CGSize textSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:11]}];
        CGFloat descriptionLabelWidth;
        descriptionLabelWidth = textSize.width;
        self.marketPriceLabel.x = descriptionLabelWidth + 3;
        CGSize marketLabelTextSize = [self.marketPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager regularFontOfSize:12]}];
        
        if (venue.deal.isRewardItem) {
            self.itemPriceLabel.text = [NSString stringWithFormat:@"FREE"];
            //self.descriptionLabel.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
            self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] greenColor];
        } else {
            self.itemPriceLabel.text = [NSString stringWithFormat:@"$%@", venue.deal.itemPrice];
            self.descriptionLabel.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
        }
        CGSize itemPriceTextSize = [self.itemPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:11.5]}];
        self.itemPriceLabel.width = itemPriceTextSize.width;
        self.itemPriceLabel.x = self.marketPriceLabel.x + marketLabelTextSize.width + 3;
        
        self.descriptionLabel.width = descriptionLabelWidth + marketLabelTextSize.width + itemPriceTextSize.width + 15;
        
        self.placeType.y = 70.5;
        self.venueLabelLineOne.y = 9;
        self.marketPriceLabel.y = 25;
        self.itemPriceLabel.y = 25;
        self.descriptionLabel.y = 28;
        self.dealTime.y = 49;
        
    } else {
        self.selectedDealInMap.height = NON_HOTSPOT_HEIGHT;
        self.marketPriceLabel.text = @"";
        self.itemPriceLabel.text = @"";
        
        self.placeType.y = 55.5;
        self.venueLabelLineOne.y = 6;
        self.marketPriceLabel.y = 30;
        self.itemPriceLabel.y = 30;
        self.descriptionLabel.y = 32;
        self.dealTime.y = 19;
        self.descriptionLabel.width = 0;
        
        if (venue.neighborhood != (NSString *)[NSNull null]) {
            self.dealTime.text = [NSString stringWithFormat:@"%@ | %@", [venue.neighborhood uppercaseString],[self stringForDistance:venue.distance]];
        } else {
            self.dealTime.text = [NSString stringWithFormat:@"%@", [self stringForDistance:venue.distance]];
        }
    }
    if (!isEmpty(venue.placeType)) {
        self.placeType.text = [venue.placeType uppercaseString];
    }
    
    CGSize headingSize = [self.venueLabelLineOne.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:11.5]}];
    CGFloat headingWidth = headingSize.width;
    
    CGSize dealTimeSize = [self.dealTime.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:9]}];
    CGFloat dealTimeWidth = dealTimeSize.width;
    if (headingWidth > 150) {
        headingWidth = 150;
    }
    
    NSArray *sorted1 = [[NSArray arrayWithObjects: @(self.descriptionLabel.width),@(headingWidth), @(dealTimeWidth), nil] sortedArrayUsingSelector:@selector(compare:)];
    
    self.selectedDealInMap.width = [sorted1[2] floatValue] + 25;
    
    self.placeType.x = 6;
}

-(void)showFaq:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.faqViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    NSLog(@"%@", gestureRecognizer);
//    NSLog(@"%@", touch.view);
////    if([touch.view isKindOfClass:[UITableViewCell class]]) {
////        return NO;
////    }
////    // UITableViewCellContentView => UITableViewCell
////    if([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
////        return NO;
////    }
////    // UITableViewCellContentView => UITableViewCellScrollView => UITableViewCell
////    if([touch.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
////        return NO;
////    }
//    return YES; // handle the touch
//}

@end