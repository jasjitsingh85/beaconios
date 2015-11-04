//
//  FeedViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 8/11/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedTableViewController.h"
#import "LoadingIndictor.h"
#import "APIClient.h"
#import "FeedItem.h"
#import "FeedItemTableViewCell.h"
#import "DealTableViewEventCell.h"
#import "NavigationBarTitleLabel.h"
#import "ContactManager.h"
#import "SetupNewsfeedPopupView.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "WebViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FeedTableViewController () <UITableViewDataSource, UITableViewDelegate>
//<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isViewShowing;
@property (strong, nonatomic) UIView *emptyFeedView;
@property (assign, nonatomic) BOOL pullToRefresh;
@property (strong, nonatomic) UIImageView *syncContactsButtonContainer;
@property (strong, nonatomic) UIButton *syncContactsButton;

@property (strong, nonatomic) UIImageView *firstRecPicture;
@property (strong, nonatomic) UILabel *firstRecHeader;
@property (strong, nonatomic) UILabel *firstRecBody;
@property (strong, nonatomic) UIButton *firstRecFollowButton;

@property (strong, nonatomic) UIImageView *secondRecPicture;
@property (strong, nonatomic) UILabel *secondRecHeader;
@property (strong, nonatomic) UILabel *secondRecBody;
@property (strong, nonatomic) UIButton *secondRecFollowButton;

@property (strong, nonatomic) UIImageView *thirdRecPicture;
@property (strong, nonatomic) UILabel *thirdRecHeader;
@property (strong, nonatomic) UILabel *thirdRecBody;
@property (strong, nonatomic) UIButton *thirdRecFollowButton;
@property (assign, nonatomic) BOOL followAdded;

@property (strong, nonatomic) DealTableViewEventCell *eventCell;
@property (strong, nonatomic) WebViewController *webView;
@property (strong, nonatomic) SetupNewsfeedPopupView *modal;

//@property (strong, nonatomic) UINavigationController *navigationWebviewController;

@end

@implementation FeedTableViewController

- (id) initWithLoadingIndicator  {
    self = [super init];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = YES;
    //self.tableView.backgroundColor = [UIColor colorWithWhite:178/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.syncContactsButtonContainer];
    
    self.webView = [[WebViewController alloc] init];
    
    self.pullToRefresh = NO;
    
    self.feed = [[NSMutableArray alloc] init];
    
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
//
//    self.isRefreshing = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingIndicator:) name:kFeedUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedStartedRefreshing:) name:kFeedStartRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedFinishedRefreshing:) name:kFeedFinishRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishNewsfeedPermissions:) name:kDidFinishNewsfeedPermissions object:nil];
    
    self.isViewShowing = NO;
    
    self.modal = [[SetupNewsfeedPopupView alloc] init];
    
    if (!self) {
        return nil;
    } else {
        return self;
    }
}

-(void)setRecommendations:(NSArray *)recommendations
{
    _recommendations = recommendations;
    
    self.followAdded = NO;
    
    NSString *urlString = recommendations[0][@"image_url"];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.firstRecPicture sd_setImageWithURL:url];
    
    int firstNumberOfFollowers = [recommendations[0][@"number_of_followers"] intValue];
    NSString *firstHeaderText;
    if (firstNumberOfFollowers > 10) {
        firstHeaderText = [NSString stringWithFormat:@"%@ - %@ Followers", recommendations[0][@"name"], recommendations[0][@"number_of_followers"]];
    } else {
        firstHeaderText = [NSString stringWithFormat:@"%@", recommendations[0][@"name"]];
    }
    
    self.firstRecHeader.text = firstHeaderText;
    self.firstRecBody.text = recommendations[0][@"description"];
    
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:self.firstRecHeader.text];
    NSRange attrStringRange = [self.firstRecHeader.text rangeOfString:recommendations[0][@"name"]];
    [attrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:attrStringRange];
    [attrMessage addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:11] range:attrStringRange];
    
    self.firstRecHeader.attributedText = attrMessage;
    
    NSString *secondUrlString = recommendations[1][@"image_url"];
    NSURL *secondUrl = [NSURL URLWithString:secondUrlString];
    [self.secondRecPicture sd_setImageWithURL:secondUrl];
    
    int secondNumberOfFollowers = [recommendations[1][@"number_of_followers"] intValue];
    NSString *secondHeaderText;
    if (secondNumberOfFollowers > 10) {
        secondHeaderText = [NSString stringWithFormat:@"%@ - %@ Followers", recommendations[1][@"name"], recommendations[1][@"number_of_followers"]];
    } else {
        secondHeaderText = [NSString stringWithFormat:@"%@", recommendations[1][@"name"]];
    }
    
    self.secondRecHeader.text = secondHeaderText;
    self.secondRecBody.text = recommendations[1][@"description"];
    
    NSMutableAttributedString *secondAttrMessage = [[NSMutableAttributedString alloc] initWithString:self.secondRecHeader.text];
    NSRange secondAttrStringRange = [self.secondRecHeader.text rangeOfString:recommendations[1][@"name"]];
    [secondAttrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:secondAttrStringRange];
    [secondAttrMessage addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:11] range:secondAttrStringRange];
    
    self.secondRecHeader.attributedText = secondAttrMessage;
    
    NSString *thirdUrlString = recommendations[2][@"image_url"];
    NSURL *thirdUrl = [NSURL URLWithString:thirdUrlString];
    [self.thirdRecPicture sd_setImageWithURL:thirdUrl];
    
    int thirdNumberOfFollowers = [recommendations[2][@"number_of_followers"] intValue];
    NSString *thirdHeaderText;
    if (thirdNumberOfFollowers > 10) {
        thirdHeaderText = [NSString stringWithFormat:@"%@ - %@ Followers", recommendations[2][@"name"], recommendations[2][@"number_of_followers"]];
    } else {
        thirdHeaderText = [NSString stringWithFormat:@"%@", recommendations[2][@"name"]];
    }
    
    self.thirdRecHeader.text = thirdHeaderText;
    self.thirdRecBody.text = recommendations[2][@"description"];
    
    NSMutableAttributedString *thirdAttrMessage = [[NSMutableAttributedString alloc] initWithString:self.thirdRecHeader.text];
    NSRange thirdAttrStringRange = [self.thirdRecHeader.text rangeOfString:recommendations[2][@"name"]];
    [thirdAttrMessage addAttribute:NSForegroundColorAttributeName value:[[ThemeManager sharedTheme] redColor] range:thirdAttrStringRange];
    [thirdAttrMessage addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:11] range:thirdAttrStringRange];
    
    self.thirdRecHeader.attributedText = thirdAttrMessage;
}

-(void)feedStartedRefreshing:(NSNotification *)notification
{
    if (!self.pullToRefresh) {
        [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
    }
    self.isRefreshing = YES;
}

-(void)feedFinishedRefreshing:(NSNotification *)notification
{
    [LoadingIndictor hideLoadingIndicatorForView:self.tableView animated:YES];
    [self.refreshControl endRefreshing];
    self.isRefreshing = NO;
    self.pullToRefresh = NO;
    
}

-(void)finishNewsfeedPermissions:(NSNotification *)notification
{
    self.syncContactsButtonContainer.hidden = YES;
}

//-(void) showLoadingIndicator:(id)sender
//{
//    [LoadingIndictor showLoadingIndicatorInView:self.tableView animated:YES];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor unnormalizedColorWithRed:230 green:230 blue:230 alpha:255];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    self.emptyFeedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.emptyFeedView.backgroundColor = [UIColor clearColor];
    self.emptyFeedView.hidden = YES;
    [self.tableView addSubview:self.emptyFeedView];
    
    UIImageView *groupIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyNewsfeedIcon"]];
    groupIcon.width = 35;
    groupIcon.height = 35;
    groupIcon.centerX = self.view.width/2.0;
    groupIcon.y = 30;
    [self.emptyFeedView addSubview:groupIcon];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, self.view.width, 20)];
    header.textAlignment = NSTextAlignmentCenter;
    header.font = [ThemeManager boldFontOfSize:12];
    header.text = @"OH SNAP!";
    [self.emptyFeedView addSubview:header];
    
    UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, self.view.width - 70, 90)];
    body.textAlignment = NSTextAlignmentCenter;
    body.font = [ThemeManager lightFontOfSize:12];
    body.numberOfLines = 0;
    body.centerX = self.view.width/2.0;
    body.text = @"With Hotspot's newsfeed, you'll see events, updates and specials from your favorite places. Follow venues to see what's going on tonight!";
    [self.emptyFeedView addSubview:body];
    
    UILabel *recommendationHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, self.view.width, 20)];
    recommendationHeader.textAlignment = NSTextAlignmentCenter;
    recommendationHeader.font = [ThemeManager boldFontOfSize:12];
    recommendationHeader.text = @"Get started with some top venues:";
    [self.emptyFeedView addSubview:recommendationHeader];
    
    UIView *firstRecommendation = [[UIView alloc] initWithFrame:CGRectMake(10, 190, self.view.width-20, 70)];
    firstRecommendation.backgroundColor = [UIColor whiteColor];
    [self.emptyFeedView addSubview:firstRecommendation];
    
    self.firstRecPicture = [[UIImageView alloc] init];
    self.firstRecPicture.x = 10;
    self.firstRecPicture.y = 10;
    self.firstRecPicture.height = 50;
    self.firstRecPicture.width = 50;
    self.firstRecPicture.clipsToBounds = YES;
    self.firstRecPicture.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.firstRecPicture.contentMode = UIViewContentModeScaleAspectFill;
    self.firstRecPicture.layer.cornerRadius = 10.0;
    [firstRecommendation addSubview:self.firstRecPicture];
    
    self.firstRecFollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.firstRecFollowButton.size = CGSizeMake(60, 20);
    self.firstRecFollowButton.x = firstRecommendation.size.width - 65;
    self.firstRecFollowButton.y = 25;
    [self.firstRecFollowButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.firstRecFollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.firstRecFollowButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.firstRecFollowButton.titleLabel.font = [ThemeManager mediumFontOfSize:9];
    self.firstRecFollowButton.backgroundColor = [UIColor clearColor];
    self.firstRecFollowButton.titleLabel.textColor = [UIColor blackColor];
    self.firstRecFollowButton.layer.cornerRadius = 4;
    self.firstRecFollowButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.firstRecFollowButton.layer.borderWidth = 1.0;
    [self.firstRecFollowButton addTarget:self action:@selector(followFirstRecButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [firstRecommendation addSubview:self.firstRecFollowButton];
    
    self.firstRecHeader = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, self.view.width - 175, 20)];
    self.firstRecHeader.font = [ThemeManager lightFontOfSize:10];
    [firstRecommendation addSubview:self.firstRecHeader];
    
    self.firstRecBody = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, self.view.width - 175, 35)];
    self.firstRecBody.numberOfLines = 2;
    self.firstRecBody.font = [ThemeManager lightFontOfSize:10];
    [firstRecommendation addSubview:self.firstRecBody];
    
    UIView *secondRecommendation = [[UIView alloc] initWithFrame:CGRectMake(10, 270, self.view.width-20, 70)];
    secondRecommendation.backgroundColor = [UIColor whiteColor];
    [self.emptyFeedView addSubview:secondRecommendation];
    
    self.secondRecPicture = [[UIImageView alloc] init];
    self.secondRecPicture.x = 10;
    self.secondRecPicture.y = 10;
    self.secondRecPicture.height = 50;
    self.secondRecPicture.width = 50;
    self.secondRecPicture.clipsToBounds = YES;
    self.secondRecPicture.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.secondRecPicture.contentMode = UIViewContentModeScaleAspectFill;
    self.secondRecPicture.layer.cornerRadius = 10.0;
    [secondRecommendation addSubview:self.secondRecPicture];
    
    self.secondRecFollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.secondRecFollowButton.size = CGSizeMake(60, 20);
    self.secondRecFollowButton.x = firstRecommendation.size.width - 65;
    self.secondRecFollowButton.y = 25;
    [self.secondRecFollowButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.secondRecFollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.secondRecFollowButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.secondRecFollowButton.titleLabel.font = [ThemeManager mediumFontOfSize:9];
    self.secondRecFollowButton.backgroundColor = [UIColor clearColor];
    self.secondRecFollowButton.titleLabel.textColor = [UIColor blackColor];
    self.secondRecFollowButton.layer.cornerRadius = 4;
    self.secondRecFollowButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.secondRecFollowButton.layer.borderWidth = 1.0;
    [self.secondRecFollowButton addTarget:self action:@selector(followSecondRecButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [secondRecommendation addSubview:self.secondRecFollowButton];
    
    self.secondRecHeader = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, self.view.width - 175, 20)];
    self.secondRecHeader.font = [ThemeManager lightFontOfSize:10];
    [secondRecommendation addSubview:self.secondRecHeader];
    
    self.secondRecBody = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, self.view.width - 175, 35)];
    self.secondRecBody.numberOfLines = 2;
    self.secondRecBody.font = [ThemeManager lightFontOfSize:10];
    [secondRecommendation addSubview:self.secondRecBody];
    
    UIView *thirdRecommendation = [[UIView alloc] initWithFrame:CGRectMake(10, 350, self.view.width-20, 70)];
    thirdRecommendation.backgroundColor = [UIColor whiteColor];
    [self.emptyFeedView addSubview:thirdRecommendation];
    
    self.thirdRecPicture = [[UIImageView alloc] init];
    self.thirdRecPicture.x = 10;
    self.thirdRecPicture.y = 10;
    self.thirdRecPicture.height = 50;
    self.thirdRecPicture.width = 50;
    self.thirdRecPicture.clipsToBounds = YES;
    self.thirdRecPicture.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.thirdRecPicture.contentMode = UIViewContentModeScaleAspectFill;
    self.thirdRecPicture.layer.cornerRadius = 10.0;
    [thirdRecommendation addSubview:self.thirdRecPicture];
    
    self.thirdRecFollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.thirdRecFollowButton.size = CGSizeMake(60, 20);
    self.thirdRecFollowButton.x = firstRecommendation.size.width - 65;
    self.thirdRecFollowButton.y = 25;
    [self.thirdRecFollowButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.thirdRecFollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.thirdRecFollowButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.thirdRecFollowButton.titleLabel.font = [ThemeManager mediumFontOfSize:9];
    self.thirdRecFollowButton.backgroundColor = [UIColor clearColor];
    self.thirdRecFollowButton.titleLabel.textColor = [UIColor blackColor];
    self.thirdRecFollowButton.layer.cornerRadius = 4;
    self.thirdRecFollowButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.thirdRecFollowButton.layer.borderWidth = 1.0;
    [self.thirdRecFollowButton addTarget:self action:@selector(followThirdRecButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [thirdRecommendation addSubview:self.thirdRecFollowButton];
    
    self.thirdRecHeader = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, self.view.width - 175, 20)];
    self.thirdRecHeader.font = [ThemeManager lightFontOfSize:10];
    [thirdRecommendation addSubview:self.thirdRecHeader];
    
    self.thirdRecBody = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, self.view.width - 175, 35)];
    self.thirdRecBody.numberOfLines = 2;
    self.thirdRecBody.font = [ThemeManager lightFontOfSize:10];
    [thirdRecommendation addSubview:self.thirdRecBody];
    
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Newsfeed"];
    
    self.syncContactsButtonContainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonBackground"]];
    self.syncContactsButtonContainer.height = 120;
    self.syncContactsButtonContainer.y = self.view.height - 120;
    self.syncContactsButtonContainer.userInteractionEnabled = YES;
    
    self.syncContactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.syncContactsButton.size = CGSizeMake(self.view.width - 50, 35);
    self.syncContactsButton.centerX = self.view.width/2.0;
    self.syncContactsButton.y = 73;
    self.syncContactsButton.layer.cornerRadius = 4;
    self.syncContactsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.syncContactsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.syncContactsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    self.syncContactsButton.titleLabel.font = [ThemeManager boldFontOfSize:14];
    [self.syncContactsButton addTarget:self action:@selector(showSetupModal) forControlEvents:UIControlEventTouchUpInside];
    [self.syncContactsButton setTitle:@"SETUP NEWSFEED" forState:UIControlStateNormal];

    [self.syncContactsButtonContainer addSubview:self.syncContactsButton];
    
    [self updateSetupNewsfeedButtonContainer];
}

-(void) updateSetupNewsfeedButtonContainer
{
    if ([self hasAcceptedPermissions]) {
        self.syncContactsButtonContainer.hidden = YES;
    } else {
        self.syncContactsButtonContainer.hidden = NO;
    }
}

-(void) addFriendsButtonTouched:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"Syncing contacts lets you see what your friends are up to on Hotspot"];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Sync Contacts" message:message];
    [alertView bk_addButtonWithTitle:@"Sync Contacts" handler:^{
        [self requestContactPermissions];
    }];
    [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:^ {
    }];
    [alertView show];
}

- (void)requestContactPermissions
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    self.syncContactsButtonContainer.hidden = YES;
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            [[ContactManager sharedManager] syncContacts];
        } else {
            self.syncContactsButtonContainer.hidden = NO;
        }
    });
}

-(void) setFeed:(NSMutableArray *)feed
{
    _feed = feed;
    
    [self.tableView reloadData];
    
    if (self.isViewShowing && !self.isRefreshing) {
        [self markViewAsSeen];
        if (self.feed.count > 0) {
            self.emptyFeedView.hidden = YES;
        } else {
            self.emptyFeedView.hidden = NO;
        }
    }
}

//-(void)showProperView
//{
//    if (self.feed.count > 0) {
//        self.tableView.hidden = NO;
//        self.emptyFeedView.hidden = YES;
//    } else {
//        self.tableView.hidden = YES;
//        self.emptyFeedView.hidden = NO;
//    }
//}

- (void) viewWillAppear:(BOOL)animated
{
    self.isViewShowing = YES;
    if (!self.isRefreshing) {
        [self markViewAsSeen];
        if (self.feed.count > 0) {
            self.emptyFeedView.hidden = YES;
        } else {
            self.emptyFeedView.hidden = NO;
        }
    }
    
    [self incrementAndSaveNewsfeedLaunchCount];
}

- (void) incrementAndSaveNewsfeedLaunchCount
{
    if (![self hasAcceptedPermissions]) {
        NSInteger newsfeedLaunchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"newsfeedLaunchCount"];
        newsfeedLaunchCount++;
        [[NSUserDefaults standardUserDefaults] setInteger:newsfeedLaunchCount  forKey:@"newsfeedLaunchCount"];
        
        if ((newsfeedLaunchCount) % 3 == 1) {
            [self showSetupModal];
        }
    }
}

-(BOOL) hasAcceptedPermissions
{
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if ([FBSDKAccessToken currentAccessToken] && contactAuthStatus != kABAuthorizationStatusNotDetermined && [[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        return YES;
    } else {
       return NO;
    }
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        self.isViewShowing = NO;
    }
    
    if (self.followAdded)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];
    }
    
    [self hideSetupModal];
    
    [super viewWillDisappear:animated];
}

-(void)markViewAsSeen
{
    if (self.feed.count > 0) {
        FeedItem *feedItem = self.feed[0];
        [[NSUserDefaults standardUserDefaults] setObject:feedItem.dateCreated forKey:kFeedUpdateNotification];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveNewsfeedNotification object:self userInfo:nil];
        NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [[APIClient sharedClient] storeLastFollowView:timestamp success:nil failure:nil];
    }
}

-(void)pullToRefresh:(id)sender
{
    self.pullToRefresh = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.events.count > 0) {
         return self.feed.count + 1;
    } else {
        return self.feed.count;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        Event *event = self.events[self.eventCell.pageControl.currentPage];
        self.webView.websiteUrl = event.websiteURL;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webView];
        [self presentViewController:navigationController
                               animated:YES
                             completion:nil];
    } else {
        FeedItem *feedItem = self.feed[indexPath.row - 1];
        if (![feedItem.source isEqualToString:@"hotspot"]) {
            self.webView.websiteUrl = feedItem.url;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webView];
            [self presentViewController:navigationController
                               animated:YES
                             completion:nil];
        }
    }
}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    return NO;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString *identifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        self.eventCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!self.eventCell) {
            self.eventCell = [[DealTableViewEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            self.eventCell.backgroundColor = [UIColor whiteColor];
            self.eventCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (self.events.count > 0) {
            self.eventCell.events = self.events;
        }
        
        return self.eventCell;
    } else {
        FeedItem *feedItem = self.feed[indexPath.row - 1];
        NSString *identifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        FeedItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[FeedItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.feedItem = feedItem;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    if (indexPath.row == 0)
    {
        if (self.events.count > 0)
        {
            cellHeight = 200;
        } else {
            cellHeight = 0;
        }
    } else {
        FeedItem *feedItem = self.feed[indexPath.row - 1];
        CGFloat imageHeight;
        
        CGRect messageRect = [feedItem.message boundingRectWithSize:CGSizeMake(190, 0)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:11]}
                                                                context:nil];
        
        CGRect messageBodyRect = [feedItem.message boundingRectWithSize:CGSizeMake(220, 0)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:11]}
                                                                     context:nil];
        
        if (feedItem.image) {
            imageHeight = feedItem.image.size.height;

        } else {
            imageHeight = 0;
        }
        if ([feedItem.source isEqualToString:@"hotspot"]) {
            cellHeight = messageRect.size.height + imageHeight + 70;
        } else {
            cellHeight = messageBodyRect.size.height + imageHeight + 80;
        }
    }
    return cellHeight;
}

-(void)followFirstRecButtonTouched:(id)sender
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    NSNumber *firstDealPlaceID = self.recommendations[0][@"deal_place_id"];
    [[APIClient sharedClient] toggleFavorite:firstDealPlaceID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        self.followAdded = YES;
        [self toggleFirstFollowButtonState:[responseObject[@"is_favorited"] boolValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

-(void)followSecondRecButtonTouched:(id)sender
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    NSNumber *firstDealPlaceID = self.recommendations[1][@"deal_place_id"];
    [[APIClient sharedClient] toggleFavorite:firstDealPlaceID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        self.followAdded = YES;
        [self toggleSecondFollowButtonState:[responseObject[@"is_favorited"] boolValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

-(void)followThirdRecButtonTouched:(id)sender
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    NSNumber *firstDealPlaceID = self.recommendations[2][@"deal_place_id"];
    [[APIClient sharedClient] toggleFavorite:firstDealPlaceID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        self.followAdded = YES;
        [self toggleThirdFollowButtonState:[responseObject[@"is_favorited"] boolValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

- (void)toggleFirstFollowButtonState:(BOOL)active
{
    if (active) {
        [self.firstRecFollowButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        self.firstRecFollowButton.size = CGSizeMake(65, 20);
        self.firstRecFollowButton.x = self.view.width - 90;
        [self.firstRecFollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.firstRecFollowButton setTitleColor:[[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
        self.firstRecFollowButton.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
        self.firstRecFollowButton.layer.borderColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255].CGColor;
    } else {
        self.firstRecFollowButton.size = CGSizeMake(60, 20);
        self.firstRecFollowButton.x = self.view.width - 85;
        [self.firstRecFollowButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [self.firstRecFollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.firstRecFollowButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
        self.firstRecFollowButton.backgroundColor = [UIColor clearColor];
        self.firstRecFollowButton.titleLabel.textColor = [UIColor blackColor];
        self.firstRecFollowButton.layer.borderColor = [[UIColor blackColor] CGColor];
    }
}

- (void)toggleSecondFollowButtonState:(BOOL)active
{
    if (active) {
        [self.secondRecFollowButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        self.secondRecFollowButton.size = CGSizeMake(65, 20);
        self.secondRecFollowButton.x = self.view.width - 90;
        [self.secondRecFollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.secondRecFollowButton setTitleColor:[[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
        self.secondRecFollowButton.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
        self.secondRecFollowButton.layer.borderColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255].CGColor;
    } else {
        self.secondRecFollowButton.size = CGSizeMake(60, 20);
        self.secondRecFollowButton.x = self.view.width - 85;
        [self.secondRecFollowButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [self.secondRecFollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.secondRecFollowButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
        self.secondRecFollowButton.backgroundColor = [UIColor clearColor];
        self.secondRecFollowButton.titleLabel.textColor = [UIColor blackColor];
        self.secondRecFollowButton.layer.borderColor = [[UIColor blackColor] CGColor];
    }
}

- (void)toggleThirdFollowButtonState:(BOOL)active
{
    if (active) {
        [self.thirdRecFollowButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        self.thirdRecFollowButton.size = CGSizeMake(65, 20);
        self.thirdRecFollowButton.x = self.view.width - 90;
        [self.thirdRecFollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.thirdRecFollowButton setTitleColor:[[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
        self.thirdRecFollowButton.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255];
        self.thirdRecFollowButton.layer.borderColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255].CGColor;
    } else {
        self.thirdRecFollowButton.size = CGSizeMake(60, 20);
        self.thirdRecFollowButton.x = self.view.width - 85;
        [self.thirdRecFollowButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [self.thirdRecFollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.thirdRecFollowButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
        self.thirdRecFollowButton.backgroundColor = [UIColor clearColor];
        self.thirdRecFollowButton.titleLabel.textColor = [UIColor blackColor];
        self.thirdRecFollowButton.layer.borderColor = [[UIColor blackColor] CGColor];
    }
}

- (void) showSetupModal
{
    [self.modal show];
}

- (void) hideSetupModal
{
    [self.modal dismiss];
}

@end
