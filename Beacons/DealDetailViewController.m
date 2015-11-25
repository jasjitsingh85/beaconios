//
//  DealDetailViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 6/21/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DealDetailViewController.h"
#import "Deal.h"
#import "Venue.h"
#import "HappyHour.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MapKit/MapKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Utilities.h"
#import "DealDetailImageCell.h"
//#import "FindFriendsViewController.h"
#import "AnalyticsManager.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "LoadingIndictor.h"
//#import "DealView.h"
//#import "HappyHourView.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@interface DealDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *getDealButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UIImageView *getDealButtonContainer;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UILabel *happyHourTime;
@property (strong, nonatomic) UILabel *dealPrompt;
@property (strong, nonatomic) UIScrollView *mainScroll;
@property (strong, nonatomic) UIButton *followButton;
@property (strong, nonatomic) UIButton *publicToggleButton;
@property (strong, nonatomic) UIImageView *publicToggleButtonIcon;

@property (strong, nonatomic) UILabel *venueTextLabel;
@property (assign, nonatomic) BOOL isFollowed;
@property (assign, nonatomic) BOOL isPresent;
@property (assign, nonatomic) BOOL isPublic;
@property (assign, nonatomic) BOOL hasVenueDescription;

@property (strong, nonatomic) Deal *deal;
@property (strong, nonatomic) HappyHour *happyHour;
@property (strong, nonatomic) NSArray *events;

@property (readonly) NSInteger imageContainer;
@property (readonly) NSInteger dealContainer;
@property (readonly) NSInteger tutorialContainer;
@property (readonly) NSInteger happyHourContainer;
@property (readonly) NSInteger venueContainer;
@property (readonly) NSInteger eventsContainer;
@property (readonly) NSInteger mapContainer;

@property (strong, nonatomic) UILabel *dealTextLabel;
@property (strong, nonatomic) UILabel *happyHourTextLabel;

@end

@implementation DealDetailViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.isPublic = YES;
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followButton.size = CGSizeMake(60, 20);
    self.followButton.x = 0;
    self.followButton.y = 1;
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[[ThemeManager sharedTheme] redColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.titleLabel.font = [ThemeManager regularFontOfSize:9];
    self.followButton.backgroundColor = [UIColor clearColor];
    self.followButton.titleLabel.textColor = [[ThemeManager sharedTheme] redColor];
    self.followButton.layer.cornerRadius = 4;
    self.followButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.followButton.layer.borderWidth = 1.0;
    [self.followButton addTarget:self action:@selector(followButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.followButton];
    
    if (self.venue.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
}

-(void) updateIsUserPresent
{
    if (self.venue.distance < 0.1) {
        self.isPresent = YES;
    } else {
        self.isPresent = NO;
    }
}

-(NSInteger)imageContainer
{
    return 0;
}

-(NSInteger) dealContainer {
    return 2;
}

-(NSInteger) happyHourContainer {
    return 3;
}

-(NSInteger) venueContainer {
    return 1;
}

-(NSInteger) mapContainer {
    return 5;
}

-(NSInteger) tutorialContainer {
    return 4;
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

- (void)getDirectionsToBeacon:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Get Directions"];
    [actionSheet bk_addButtonWithTitle:@"Google Maps" handler:^{
        [Utilities launchGoogleMapsDirectionsToCoordinate:self.venue.coordinate addressDictionary:nil destinationName:self.venue.name];
    }];
    [actionSheet bk_addButtonWithTitle:@"Apple Maps" handler:^{
        [Utilities launchAppleMapsDirectionsToCoordinate:self.venue.coordinate addressDictionary:nil destinationName:self.venue.name];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Nevermind" handler:nil];
    [actionSheet showInView:self.view];
}

//#pragma mark - Find Friends Delegate
//- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts andMessage:(NSString *)message andDate:(NSDate *)date
//{
//    //if (contacts.count >= self.deal.inviteRequirement.integerValue) {
//    [self setBeaconOnServerWithInvitedContacts:contacts andMessage:message andDate:date];
//        [[AnalyticsManager sharedManager] setDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name numberOfInvites:contacts.count];
//    //}
////    else {
////        NSString *message = [NSString stringWithFormat:@"Just select %d more friends to unlock this deal", self.deal.inviteRequirement.integerValue - contacts.count];
////        [[[UIAlertView alloc] initWithTitle:@"You're Almost There..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
////    }
//}

//- (void)setBeaconOnServerWithInvitedContacts:(NSArray *)contacts andMessage:(NSString *)message andDate:(NSDate *)date
//{
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    UIView *view = appDelegate.window.rootViewController.view;
//    MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
//    [[APIClient sharedClient] applyForDeal:self.deal invitedContacts:contacts customMessage:message time:date imageUrl:@"" success:^(Beacon *beacon) {
//        [loadingIndicator hide:YES];
//        [[AnalyticsManager sharedManager] setDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name numberOfInvites:contacts.count];
//        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
//    } failure:^(NSError *error) {
//        [loadingIndicator hide:YES];
//        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }];
//}

- (void) setVenue:(Venue *)venue

{
    _venue = venue;
    
    [self updateIsUserPresent];
    [self updateVenueData];
    
    self.getDealButtonContainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonBackground"]];
    self.getDealButtonContainer.height = 120;
    self.getDealButtonContainer.y = self.view.height - 120;
    self.getDealButtonContainer.userInteractionEnabled = YES;
    [self.view addSubview:self.getDealButtonContainer];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 0.5)];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:204 green:204 blue:204 alpha:255];
    [self.getDealButtonContainer addSubview:topBorder];
    
    self.publicToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.publicToggleButton.size = CGSizeMake(65, 25);
    self.publicToggleButton.x = self.view.width - 90;
    self.publicToggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.publicToggleButton.y = 45;
    [self.publicToggleButton setTitle:@"Friends" forState:UIControlStateNormal];
    [self.publicToggleButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    [self.publicToggleButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.publicToggleButton.titleLabel.font = [ThemeManager mediumFontOfSize:9];
    self.publicToggleButton.backgroundColor = [UIColor clearColor];
    self.publicToggleButton.titleLabel.textColor = [[ThemeManager sharedTheme] redColor];
    [self.publicToggleButton addTarget:self action:@selector(publicToggleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.getDealButtonContainer addSubview:self.publicToggleButton];
    
    self.publicToggleButtonIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publicGlobe"]];
    self.publicToggleButtonIcon.frame = CGRectMake(16, 5, 16, 16);
    [self.publicToggleButton addSubview:self.publicToggleButtonIcon];
    
    self.getDealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getDealButton.size = CGSizeMake(self.view.width - 50, 35);
    self.getDealButton.centerX = self.view.width/2.0;
    self.getDealButton.y = 73;
    self.getDealButton.layer.cornerRadius = 4;
    self.getDealButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.getDealButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getDealButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    [self.getDealButtonContainer addSubview:self.getDealButton];
    
    self.getDealButton.titleLabel.font = [ThemeManager boldFontOfSize:15];
    [self.getDealButton addTarget:self action:@selector(getDealButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.dealPrompt = [[UILabel alloc] initWithFrame:CGRectMake(25, 47, 150, 16)];
    self.dealPrompt.font = [ThemeManager mediumFontOfSize:9];
    self.dealPrompt.textColor = [UIColor unnormalizedColorWithRed:38 green:38 blue:38 alpha:255];
    self.dealPrompt.text = @"Tap below to get voucher";
    [self.getDealButtonContainer addSubview:self.dealPrompt];
    
    self.hasVenueDescription = ![self.venue.placeDescription isEqual: @""];
    
    if (!self.deal) {
        [self.getDealButtonContainer setHidden:YES];
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    } else {
        [self.getDealButtonContainer setHidden:NO];
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 120.0, 0.0);
    }
    
//    DealView *dealView = [[DealView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 146)];
//    dealView.deal = self.venue.deal;
//    [self.mainScroll addSubview:dealView];
    
//    if (hasVenueDescription) {
//        
//        UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"venueIcon"]];
//        venueIcon.centerX = self.view.width/2;
//        venueIcon.y = dealTextLabel.y + dealTextLabel.height + 10;
//        [self.mainScroll addSubview:venueIcon];
//        
//        UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueIcon.y + 20, self.view.width, 30)];
//        venueHeadingLabel.centerX = self.view.width/2;
//        venueHeadingLabel.text = @"THE VENUE";
//        venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
//        venueHeadingLabel.textAlignment = NSTextAlignmentCenter;
//        [self.mainScroll addSubview:venueHeadingLabel];
//        
//        UIView *yelpContainer = [[UIView alloc] initWithFrame:CGRectMake(0, venueHeadingLabel.y + 25, self.view.width, 25)];
//        [self.mainScroll addSubview:yelpContainer];
//        if (![self.venue.yelpRating isEmpty]) {
//            UIImageView *yelpReview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 83, 15)];
//            yelpReview.centerX = self.view.width/2;
//            [yelpReview sd_setImageWithURL:self.venue.yelpRating];
//            
//            UIImageView *poweredByYelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelpLogo"]];
//            poweredByYelp.y = 4;
//            poweredByYelp.x = self.view.width - 48;
//            [yelpContainer addSubview:poweredByYelp];
//            
//            UILabel *yelpReviewCount = [[UILabel alloc] initWithFrame:CGRectMake(203, 5, 67, 15)];
//            yelpReviewCount.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//            yelpReviewCount.font = [ThemeManager lightFontOfSize:10];
//            yelpReviewCount.textAlignment = NSTextAlignmentRight;
//            yelpReviewCount.text = [NSString stringWithFormat:@"%@ reviews on", self.venue.yelpReviewCount];
//            [yelpContainer addSubview:yelpReviewCount];
//            
//            [yelpContainer addSubview:yelpReview];
//        } else {
//            yelpContainer.height = 0;
//        }
//        
//        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
//        CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
//        CGRect venueDescriptionHeight = [self.venue.placeDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:14]} context:context];
//        
//        self.venueTextLabel = [[UILabel alloc] init];
//        self.venueTextLabel.x = 0;
//        self.venueTextLabel.width = self.view.width - 50;
//        self.venueTextLabel.y = venueHeadingLabel.y + yelpContainer.height + 25;
//        self.venueTextLabel.height = venueDescriptionHeight.size.height;
//        self.venueTextLabel.font = [ThemeManager lightFontOfSize:13];
//        self.venueTextLabel.centerX = self.view.width/2;
//        self.venueTextLabel.numberOfLines = 0;
//        self.venueTextLabel.textAlignment = NSTextAlignmentCenter;
//        [self.mainScroll addSubview:self.venueTextLabel];
//        
//    }
//    
//    UIImageView *docIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentIcon"]];
//    docIcon.centerX = self.view.width/2;
//    [self.mainScroll addSubview:docIcon];
//    
//    UILabel *docHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
//    docHeadingLabel.centerX = self.view.width/2;
//    docHeadingLabel.text = @"HOW THIS WORKS";
//    docHeadingLabel.font = [ThemeManager boldFontOfSize:12];
//    docHeadingLabel.textAlignment = NSTextAlignmentCenter;
//    [self.mainScroll addSubview:docHeadingLabel];
//    
//    UILabel *docTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
//    docTextLabel.centerX = self.view.width/2;
//    docTextLabel.font = [ThemeManager lightFontOfSize:13];
//    docTextLabel.width = self.view.width - 50;
//    docTextLabel.centerX = self.view.width/2;
//    docTextLabel.numberOfLines = 0;
//    docTextLabel.textAlignment = NSTextAlignmentCenter;
//    [self.mainScroll addSubview:docTextLabel];
//    
//    if (hasVenueDescription) {
//        docIcon.y = self.venueTextLabel.y + self.venueTextLabel.size.height + 15;
//        docHeadingLabel.y = docIcon.y + 20;
//        docTextLabel.y = docIcon.y + 40;
//    } else {
//        docIcon.y = dealTextLabel.y + dealTextLabel.size.height + 10;
//        docHeadingLabel.y = docIcon.y + 20;
//        docTextLabel.y = docIcon.y + 40;
//    }
//    
//    UIImageView *directionsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directionsIcon"]];
//    directionsIcon.centerX = self.view.width/2;
//    directionsIcon.y = docTextLabel.y + docTextLabel.size.height + 10;
//    [self.mainScroll addSubview:directionsIcon];
//    
//    UILabel *directionHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
//    directionHeadingLabel.y = docTextLabel.y + docTextLabel.size.height + 30;
//    directionHeadingLabel.centerX = self.view.width/2;
//    directionHeadingLabel.text = @"DIRECTIONS";
//    directionHeadingLabel.font = [ThemeManager boldFontOfSize:12];
//    directionHeadingLabel.textAlignment = NSTextAlignmentCenter;
//    [self.mainScroll addSubview:directionHeadingLabel];
//    
//    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
//    CLLocationCoordinate2D center = self.venue.coordinate;
//    options.region = MKCoordinateRegionMakeWithDistance(self.venue.coordinate, 300, 300);
//    center.latitude -= options.region.span.latitudeDelta * 0.12;
//    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
//    options.scale = [UIScreen mainScreen].scale;
//    options.size = CGSizeMake(self.view.width, 200);
//    
//    MKMapSnapshotter *mapSnapshot = [[MKMapSnapshotter alloc] initWithOptions:options];
//    [mapSnapshot startWithCompletionHandler:^(MKMapSnapshot *mapSnap, NSError *error) {
//        //mapSnapshotImage = mapSnap.image;
//        //UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 55, 25, 120, 120)];
//        UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, docTextLabel.y + docTextLabel.size.height + 60, self.view.width, 200)];
//        [mapImageView setImage:mapSnap.image];
//        //[mapImageView setImage:[UIImage imageNamed:@"mapMarker"]];
//        //CALayer *imageLayer = mapImageView.layer;
//        //[imageLayer setCornerRadius:200/2];
//        //[imageLayer setBorderWidth:3];
//        //[imageLayer setBorderColor:[[UIColor whiteColor] CGColor]];
//        //[imageLayer setBorderColor:[[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9] CGColor]];
//        //[imageLayer setMasksToBounds:YES];
//        
//        UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((mapImageView.frame.size.width/2) - 20, (mapImageView.frame.size.height/2) - 20 - 30, 40, 40)];
//        UIImage *markerImage = [UIImage imageNamed:@"bluePin"];
//        [markerImageView setImage:markerImage];
//        [mapImageView addSubview:markerImageView];
//        
//        [mapImageView setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon:)];
//        [singleTap setNumberOfTapsRequired:1];
//        [mapImageView addGestureRecognizer:singleTap];
//        
//        CGSize textSize = [self.venue.address sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]}];
//        
//        int addressContainerWidth;
//        if (textSize.width < (self.view.width - 10)) {
//            addressContainerWidth = textSize.width + 100;
//        } else {
//            addressContainerWidth = self.view.width - 10;
//        }
//        
//        UIView *addressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, mapImageView.height - 60, addressContainerWidth, 50)];
//        addressContainer.backgroundColor = [UIColor whiteColor];
//        addressContainer.centerX = self.view.width/2;
//        [mapImageView addSubview:addressContainer];
//        
//        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, addressContainer.width, 20)];
//        address.text = [self.venue.address uppercaseString];
//        address.textAlignment = NSTextAlignmentCenter;
//        address.font = [ThemeManager lightFontOfSize:13];
//        [addressContainer addSubview:address];
//        
//        UILabel *getDirections = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, addressContainer.width, 20)];
//        getDirections.text = @"GET DIRECTIONS";
//        getDirections.textAlignment = NSTextAlignmentCenter;
//        getDirections.textColor = [[ThemeManager sharedTheme] redColor];
//        getDirections.font = [ThemeManager lightFontOfSize:13];
//        [addressContainer addSubview:getDirections];
//        
//        self.mainScroll.contentSize = CGSizeMake(self.view.width, mapImageView.y + mapImageView.height + 90);
//        
//        [self.mainScroll addSubview:mapImageView];
//    }];
//
//    self.venueTextLabel.text = self.venue.placeDescription;
//    
//    if (venue.deal.isRewardItem) {
//        docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'USE FREE DRINK HERE' to get your free drink voucher. To receive drink, just show this voucher to the server.", self.venue.name];
//    } else {
//       // if (self.isPresent) {
//            docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'CHECK IN AND GET VOUCHER' to get a drink voucher. You'll only be charged once, through the app, when your server taps to redeem.", self.venue.name];
//        //} else  {
//        //    docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'I'M GOING HERE' to get a drink voucher. You'll only be charged once, through the app, when your server taps to redeem.", self.deal.venue.name];
//        //}
//    }
//    
//    self.dealPrompt.text = @"Tap below to get voucher";
//    
//    [self.view addSubview:self.mainScroll];
//    
//    //[self.view addSubview:self.getDealButton];
//    

//}

//- (void) setHappyHour:(HappyHour *)happyHour
//{
//    _happyHour = happyHour;
//    
//    HappyHourView *happyHourView = [[HappyHourView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 146)];
//    happyHourView.happyHour = self.happyHour;
//    [self.mainScroll addSubview:happyHourView];
//    
//    bool hasHappyHourVenueDescription = ![self.happyHour.venue.placeDescription isEqual: @""];
//    
//    UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dollarSign"]];
//    dealIcon.centerX = self.view.width/2;
//    dealIcon.y = 165;
//    [self.mainScroll addSubview:dealIcon];
//    
//    UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 185, self.view.width, 30)];
//    dealHeadingLabel.centerX = self.view.width/2;
//    dealHeadingLabel.text = @"HAPPY HOUR DEAL";
//    dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
//    dealHeadingLabel.textAlignment = NSTextAlignmentCenter;
//    [self.mainScroll addSubview:dealHeadingLabel];
//    
//    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
//    CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
//    CGRect happyHourDescriptionHeight = [self.happyHour.happyHourDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]} context:context];
//    
//    UILabel *dealTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, self.view.width - 50, happyHourDescriptionHeight.size.height)];
//    dealTextLabel.centerX = self.view.width/2;
//    dealTextLabel.font = [ThemeManager lightFontOfSize:13];
//    dealTextLabel.textAlignment = NSTextAlignmentCenter;
//    dealTextLabel.numberOfLines = 0;
//    
//    [self.mainScroll addSubview:dealTextLabel];
//    
//    UIImageView *directionsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directionsIcon"]];
//    directionsIcon.centerX = self.view.width/2;
//    directionsIcon.y = 0;
//    [self.mainScroll addSubview:directionsIcon];
//    
//    UILabel *directionHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
//    directionHeadingLabel.y = 0;
//    directionHeadingLabel.centerX = self.view.width/2;
//    directionHeadingLabel.text = @"DIRECTIONS";
//    directionHeadingLabel.font = [ThemeManager boldFontOfSize:12];
//    directionHeadingLabel.textAlignment = NSTextAlignmentCenter;
//    [self.mainScroll addSubview:directionHeadingLabel];
//    
//    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.happyHour.venue.name];
//    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
//    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
//    [self.venueImageView sd_setImageWithURL:self.happyHour.venue.imageURL];
//    self.distanceLabel.text = [self stringForDistance:self.happyHour.venue.distance];
//    self.dealTime.text = [self.happyHour.happyHourStartString uppercaseString];
//    dealTextLabel.text = [NSString stringWithFormat:@"%@", self.happyHour.happyHourDescription];
//    
//    if (hasHappyHourVenueDescription) {
//        UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"venueIcon"]];
//        venueIcon.centerX = self.view.width/2;
//        venueIcon.y = dealTextLabel.y + dealTextLabel.height + 5;
//        [self.mainScroll addSubview:venueIcon];
//        
//        UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueIcon.y + 20, self.view.width, 30)];
//        venueHeadingLabel.centerX = self.view.width/2;
//        venueHeadingLabel.text = @"THE VENUE";
//        venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
//        venueHeadingLabel.textAlignment = NSTextAlignmentCenter;
//        [self.mainScroll addSubview:venueHeadingLabel];
//        
//        UIView *yelpContainer = [[UIView alloc] initWithFrame:CGRectMake(0, venueHeadingLabel.y + 20, self.view.width, 25)];
//        [self.mainScroll addSubview:yelpContainer];
//        if (![self.happyHour.venue.yelpRating isEmpty]) {
//            UIImageView *yelpReview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 83, 15)];
//            yelpReview.centerX = self.view.width/2;
//            [yelpReview sd_setImageWithURL:self.happyHour.venue.yelpRating];
//            
//            UIImageView *poweredByYelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelpLogo"]];
//            poweredByYelp.y = 4;
//            poweredByYelp.x = self.view.width - 48;
//            [yelpContainer addSubview:poweredByYelp];
//            
//            UILabel *yelpReviewCount = [[UILabel alloc] initWithFrame:CGRectMake(203, 5, 67, 15)];
//            yelpReviewCount.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//            yelpReviewCount.font = [ThemeManager lightFontOfSize:10];
//            yelpReviewCount.textAlignment = NSTextAlignmentRight;
//            yelpReviewCount.text = [NSString stringWithFormat:@"%@ reviews on", self.happyHour.venue.yelpReviewCount];
//            [yelpContainer addSubview:yelpReviewCount];
//            
//            [yelpContainer addSubview:yelpReview];
//        } else {
//            yelpContainer.height = 0;
//        }
//        
//        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
//        CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
//        CGRect happyHourVenueHeight = [self.happyHour.venue.placeDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]} context:context];
//        
//        self.venueTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueIcon.y + yelpContainer.height + 40, self.view.width - 50, happyHourVenueHeight.size.height)];
//        self.venueTextLabel.centerX = self.view.width/2;
//        self.venueTextLabel.font = [ThemeManager lightFontOfSize:13];
//        self.venueTextLabel.centerX = self.view.width/2;
//        self.venueTextLabel.numberOfLines = 0;
//        self.venueTextLabel.textAlignment = NSTextAlignmentCenter;
//        [self.mainScroll addSubview:self.venueTextLabel];
//        
//        self.venueTextLabel.text = self.happyHour.venue.placeDescription;
//    }
//    
//    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
//    CLLocationCoordinate2D center = self.happyHour.venue.coordinate;
//    options.region = MKCoordinateRegionMakeWithDistance(self.venue.coordinate, 300, 300);
//    center.latitude -= options.region.span.latitudeDelta * 0.12;
//    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
//    options.scale = [UIScreen mainScreen].scale;
//    options.size = CGSizeMake(self.view.width, 200);
//    
//    MKMapSnapshotter *mapSnapshot = [[MKMapSnapshotter alloc] initWithOptions:options];
//    [mapSnapshot startWithCompletionHandler:^(MKMapSnapshot *mapSnap, NSError *error) {
//        //mapSnapshotImage = mapSnap.image;
//        //UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 55, 25, 120, 120)];
//        UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
//        [mapImageView setImage:mapSnap.image];
//        //[mapImageView setImage:[UIImage imageNamed:@"mapMarker"]];
//        //CALayer *imageLayer = mapImageView.layer;
//        //[imageLayer setCornerRadius:200/2];
//        //[imageLayer setBorderWidth:3];
//        //[imageLayer setBorderColor:[[UIColor whiteColor] CGColor]];
//        //[imageLayer setBorderColor:[[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9] CGColor]];
//        //[imageLayer setMasksToBounds:YES];
//        
//        UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((mapImageView.frame.size.width/2) - 20, (mapImageView.frame.size.height/2) - 20 - 30, 40, 40)];
//        UIImage *markerImage = [UIImage imageNamed:@"purplePin"];
//        [markerImageView setImage:markerImage];
//        [mapImageView addSubview:markerImageView];
//        
//        [mapImageView setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon:)];
//        [singleTap setNumberOfTapsRequired:1];
//        [mapImageView addGestureRecognizer:singleTap];
//        
//        CGSize textSize = [self.happyHour.venue.address sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]}];
//        
//        int addressContainerWidth;
//        if (textSize.width < (self.view.width - 10)) {
//            addressContainerWidth = textSize.width + 100;
//        } else {
//            addressContainerWidth = self.view.width - 10;
//        }
//        
//        UIView *addressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, mapImageView.height - 60, addressContainerWidth, 50)];
//        addressContainer.backgroundColor = [UIColor whiteColor];
//        addressContainer.centerX = self.view.width/2;
//        [mapImageView addSubview:addressContainer];
//        
//        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, addressContainer.width, 20)];
//        address.text = [self.happyHour.venue.address uppercaseString];
//        address.textAlignment = NSTextAlignmentCenter;
//        address.font = [ThemeManager lightFontOfSize:13];
//        [addressContainer addSubview:address];
//        
//        UILabel *getDirections = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, addressContainer.width, 20)];
//        getDirections.text = @"GET DIRECTIONS";
//        getDirections.textAlignment = NSTextAlignmentCenter;
//        getDirections.textColor = [[ThemeManager sharedTheme] redColor];
//        getDirections.font = [ThemeManager lightFontOfSize:13];
//        [addressContainer addSubview:getDirections];
//        
//        if (hasHappyHourVenueDescription) {
//            directionsIcon.y = self.venueTextLabel.y + self.venueTextLabel.height + 10;
//        } else {
//            directionsIcon.y = dealTextLabel.y + dealTextLabel.height + 10;
//        }
//        directionHeadingLabel.y = directionsIcon.y + directionsIcon.height;
//        mapImageView.y = directionHeadingLabel.y + directionHeadingLabel.height;
//        
//        [self.mainScroll addSubview:mapImageView];
//        
//        self.mainScroll.contentSize = CGSizeMake(self.view.width, mapImageView.y + mapImageView.height + 50);
//
//    }];
//    
//    [self.view addSubview:self.mainScroll];
//    
//    //if (self.isPresent) {
//        [self.getDealButton setTitle:@"CHECK IN" forState:UIControlStateNormal];
//    //} else {
//    //    [self.getDealButton setTitle:@"I'M GOING HERE" forState:UIControlStateNormal];
//    //}
//    
//    self.dealPrompt.text = @"Tap below to share your activity";
//    
//    [self.getDealButtonContainer addSubview:self.getDealButton];
//    [self.view addSubview:self.getDealButtonContainer];
//    
//    if (self.happyHour.isFollowed) {
//        [self makeFollowButtonActive];
//    } else {
//        [self makeFollowButtonInactive];
//    }
//    
//    [[APIClient sharedClient] trackView:self.happyHour.ID ofType:kHappyHourViewType success:nil failure:nil];
//
    
    [self.tableView reloadData];
    
    [[APIClient sharedClient] trackView:self.venue.venueID ofType:kDealPlaceViewType success:nil failure:nil];
}

-(void) publicToggleButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Select 'Friends' so your friends know where you’re going. Select 'Only Me' if you don’t want your friends to see your activity."];
    [actionSheet bk_addButtonWithTitle:@"Friends" handler:^{
        self.isPublic = YES;
        [self.publicToggleButton setTitle:@"Friends" forState:UIControlStateNormal];
        [self.publicToggleButtonIcon setImage:[UIImage imageNamed:@"publicGlobe"]];
    }];
    [actionSheet bk_addButtonWithTitle:@"Only Me" handler:^{
        self.isPublic = NO;
        [self.publicToggleButton setTitle:@"Only Me" forState:UIControlStateNormal];
        [self.publicToggleButtonIcon setImage:[UIImage imageNamed:@"privateLock"]];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

- (void) getDealButtonTouched:(id)sender
{
    NSDate *now = [NSDate date];
    if (![self.venue.deal isAvailableAtDateAndTime:now] && self.venue.deal != nil) {

        NSString *message = [NSString stringWithFormat:@"This deal is available %@", self.venue.deal.hoursAvailableString];
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Sorry" message:message];
        [alertView bk_setCancelButtonWithTitle:@"OK" handler:^{
//            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alertView show];

        //        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
        //        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        UIView *view = appDelegate.window.rootViewController.view;
        MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
        if (self.venue.deal != nil){
           [[APIClient sharedClient] checkInForDeal:self.venue.deal isPresent:self.isPresent isPublic:self.isPublic success:^(Beacon *beacon) {
                [loadingIndicator hide:YES];
                AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
                [[AnalyticsManager sharedManager] setDeal:self.venue.deal.dealID.stringValue withPlaceName:self.venue.name numberOfInvites:0];
            } failure:^(NSError *error) {
                [loadingIndicator hide:YES];
                [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
//        } else {
//            [[APIClient sharedClient] checkInForHappyHour:self.happyHour isPresent:self.isPresent isPublic:self.isPublic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                [loadingIndicator hide:YES];
//                self.getDealButton.backgroundColor = [UIColor unnormalizedColorWithRed:162 green:60 blue:233 alpha:255];
//                if (self.isPresent) {
//                    [self.getDealButton setTitle:@"CHECKED IN" forState:UIControlStateNormal];
//                } else {
//                    [self.getDealButton setTitle:@"GOING" forState:UIControlStateNormal];
//                }
//    //            [[AnalyticsManager sharedManager] setDeal:self.happyHour.ID.stringValue withPlaceName:self.happyHour.venue.name numberOfInvites:0];
//            } failure:^(NSError *error) {
//                [loadingIndicator hide:YES];
//                [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            }];
//        }
    }
    
    
    
//    [[AnalyticsManager sharedManager] invitedFriendsDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name];
    
//    SetDealViewController *dealViewController = [[SetDealViewController alloc] init];
//    dealViewController.deal = self.deal;
//    [self.navigationController pushViewController:dealViewController animated:YES];
    
//    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
//    findFriendsViewController.delegate = self;
//    findFriendsViewController.deal = self.deal;
//    findFriendsViewController.textMoreFriends = NO;
//    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (void)followButtonTouched:(id)sender
{
    
    self.isFollowed = !self.isFollowed;
    [self updateFavoriteButton];
    
    NSNumber *venueID = [[NSNumber alloc] init];
    venueID = self.venue.venueID;
    [[APIClient sharedClient] toggleFavorite:venueID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isFollowed = [responseObject[@"is_favorited"] boolValue];
        [self updateFavoriteButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];
    } failure:nil];
}

- (void) makeFollowButtonActive
{
    [self.followButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(75, 22);
//    self.followButton.x = self.contentView.width - 95;
    self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.backgroundColor = [[ThemeManager sharedTheme] greenColor];
}

- (void) makeFollowButtonInactive
{
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(55, 22);
    self.followButton.layer.borderColor = [UIColor blackColor].CGColor;
//    self.followButton.x = self.contentView.width - 85;
    [self.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.backgroundColor = [UIColor clearColor];
}


- (void) updateFavoriteButton
{
    if (self.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
}

- (void)updateVenueData
{
    if (!isEmpty(self.venue.deal)) {
        self.deal = self.venue.deal;
    } else {
        self.deal = nil;
    }
    
    if (!isEmpty(self.venue.happyHour)) {
        self.happyHour = self.venue.happyHour;
    } else {
        self.happyHour = nil;
    }
    
    if (self.venue.events.count > 0) {
        self.events = self.venue.events;
    } else {
        self.events = nil;
    }
}

//-(NSInteger)getNumberOfRows
//{
//    [self updateVenueData];
//
//    NSInteger numberOfRows = 6;
//    
//    return numberOfRows;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 151;
    if (indexPath.row == self.imageContainer) {
        height = 201;
    } else if (indexPath.row == self.mapContainer) {
        height = 230;
    } else if (indexPath.row == self.dealContainer || indexPath.row==self.tutorialContainer) {
        if (!self.deal) {
            height = 0;
        } else {
            if (indexPath.row == self.dealContainer) {
                NSString *dealTextLabel = [self getDealTextLabel];
                NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
                CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
                CGRect dealTextHeight = [dealTextLabel boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13.5]} context:context];
                self.dealTextLabel.height = dealTextHeight.size.height + 5;
//                self.dealTime.y = self.dealTextLabel.y + self.dealTextLabel.height + 3;
                height = dealTextHeight.size.height + 55;
            } else {
                height = 128;
            }
        }
    } else if (indexPath.row == self.happyHourContainer) {
        if (!self.happyHour) {
            height = 0;
        } else {
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
            CGRect happyHourDescriptionHeight = [self.happyHour.happyHourDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]} context:context];
            
            self.happyHourTextLabel.height = happyHourDescriptionHeight.size.height + 5;
//            self.happyHourTime.y = self.happyHourTextLabel.y + self.happyHourTextLabel.height + 3;
            height = happyHourDescriptionHeight.size.height + 55;
        }
    } else if (indexPath.row == self.venueContainer) {
        if (!self.hasVenueDescription) {
            height = 0;
        } else {
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
            CGRect venueDescriptionHeight = [self.venue.placeDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]} context:context];
            
            self.venueTextLabel.height = venueDescriptionHeight.size.height + 5;
            height = venueDescriptionHeight.size.height + 50;
        }
    }
    return height;
}

-(NSString *) getDealTextLabel
{
    NSString *dealTextLabel;
    if (self.deal.isRewardItem) {
        dealTextLabel = [NSString stringWithFormat:@"You get a %@ for free. %@", [self.venue.deal.itemName lowercaseString], self.venue.deal.additionalInfo];
    } else {
        if ([[self.deal.itemName lowercaseString] hasPrefix:@"any"]) {
            dealTextLabel = [NSString stringWithFormat:@"You get %@ for $%@. %@", [self.venue.deal.itemName lowercaseString], self.venue.deal.itemPrice, self.venue.deal.additionalInfo];
        } else {
            dealTextLabel = [NSString stringWithFormat:@"You get a %@ for $%@. %@", [self.venue.deal.itemName lowercaseString], self.venue.deal.itemPrice, self.venue.deal.additionalInfo];
        }
    }
    return dealTextLabel;
}

-(void)updateButtonText
{
    if (self.deal.isRewardItem) {
        [self.getDealButton setTitle:@"USE FREE DRINK HERE" forState:UIControlStateNormal];
    } else {
        [self.getDealButton setTitle:@"CHECK IN AND GET VOUCHER" forState:UIControlStateNormal];
    }
}

-(UITableViewCell *) getDealCell
{
    static NSString *CellIdentifier = @"dealCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, cell.contentView.size.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [cell.contentView addSubview:topBorder];
    
    UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHotspotIcon"]];
    dealIcon.x = 22;
    dealIcon.y = 15;
    [cell.contentView addSubview:dealIcon];
    
    UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
//    dealHeadingLabel.centerX = self.view.width/2;
    dealHeadingLabel.text = @"HOTSPOT SPECIAL";
    dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    dealHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:dealHeadingLabel];
    
    self.dealTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 35, self.view.width - 50, 60)];
//    self.dealTextLabel.centerX = self.view.width/2;
    self.dealTextLabel.font = [ThemeManager lightFontOfSize:12];
    self.dealTextLabel.textAlignment = NSTextAlignmentLeft;
    self.dealTextLabel.numberOfLines = 0;
    
    self.dealTextLabel.text = [self getDealTextLabel];
    
    self.dealTime = [[UILabel alloc] initWithFrame:CGRectMake(167, 16, self.view.width - 50, 20)];
//    self.dealTime.centerX = self.view.width/2;
    self.dealTime.font = [ThemeManager lightFontOfSize:9];
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 1;
    self.dealTime.textColor = [UIColor darkGrayColor];
    self.dealTime.text = [self.venue.deal.dealStartString uppercaseString];
    [cell.contentView addSubview:self.dealTime];
    
    [cell.contentView addSubview:self.dealTextLabel];
    
    [self updateButtonText];
    
    return cell;
}

-(UITableViewCell *) getImageCell
{
    static NSString *CellIdentifier = @"imageCell";
    DealDetailImageCell *cell = [[DealDetailImageCell alloc] init];
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[DealDetailImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.venue = self.venue;
    
    return cell;
}

-(UITableViewCell *) getHappyHourCell
{
    static NSString *CellIdentifier = @"happyHourCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, cell.contentView.size.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [cell.contentView addSubview:topBorder];
    
    UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHappyHourIcon"]];
    dealIcon.x = 22;
    dealIcon.y = 15;
    [cell.contentView addSubview:dealIcon];
    
    UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
    dealHeadingLabel.text = @"HAPPY HOUR";
    dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    dealHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:dealHeadingLabel];
    
    self.happyHourTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 35, self.view.width - 50, 60)];
    self.happyHourTextLabel.font = [ThemeManager lightFontOfSize:12];
    self.happyHourTextLabel.textAlignment = NSTextAlignmentLeft;
    self.happyHourTextLabel.numberOfLines = 0;
    self.happyHourTextLabel.text = [NSString stringWithFormat:@"%@", self.happyHour.happyHourDescription];
    
    self.happyHourTime = [[UILabel alloc] initWithFrame:CGRectMake(135, 16, self.view.width - 50, 20)];
//    self.happyHourTime.centerX = self.view.width/2;
    self.happyHourTime.font = [ThemeManager lightFontOfSize:9];
    self.happyHourTime.textColor = [UIColor darkGrayColor];
    self.happyHourTime.textAlignment = NSTextAlignmentLeft;
    self.happyHourTime.numberOfLines = 1;
    self.happyHourTime.text = [self.venue.happyHour.happyHourStartString uppercaseString];
    [cell.contentView addSubview:self.happyHourTime];
    
    [cell.contentView addSubview:self.happyHourTextLabel];
    
    return cell;
}

-(UITableViewCell *) getVenueCell
{
    static NSString *CellIdentifier = @"venueCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newVenueIcon"]];
    venueIcon.x = 22;
    venueIcon.y = 15;
    [cell.contentView addSubview:venueIcon];
    
    UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
//    venueHeadingLabel.centerX = self.view.width/2;
    venueHeadingLabel.text = @"THE VENUE";
    venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    venueHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:venueHeadingLabel];
    
//    UIView *yelpContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.width, 25)];
//    [cell.contentView addSubview:yelpContainer];
//    if (![self.venue.yelpRating isEmpty]) {
//        UIImageView *yelpReview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2.5, 83, 15)];
//        yelpReview.centerX = self.view.width/2;
//        [yelpReview sd_setImageWithURL:self.venue.yelpRating];
//        
//        UIImageView *poweredByYelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelpLogo"]];
//        poweredByYelp.y = 1.5;
//        poweredByYelp.x = self.view.width - 48;
//        [yelpContainer addSubview:poweredByYelp];
//        
//        UILabel *yelpReviewCount = [[UILabel alloc] initWithFrame:CGRectMake(203, 2.5, 67, 15)];
//        yelpReviewCount.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//        yelpReviewCount.font = [ThemeManager lightFontOfSize:10];
//        yelpReviewCount.textAlignment = NSTextAlignmentRight;
//        yelpReviewCount.text = [NSString stringWithFormat:@"%@ reviews on", self.venue.yelpReviewCount];
//        [yelpContainer addSubview:yelpReviewCount];
//        
//        [yelpContainer addSubview:yelpReview];
//    } else {
//        yelpContainer.height = 0;
//    }
    
    self.venueTextLabel = [[UILabel alloc] init];
    self.venueTextLabel.x = 25;
    self.venueTextLabel.width = self.view.width - 50;
//    self.venueTextLabel.y = venueHeadingLabel.y + yelpContainer.height + 20;
    self.venueTextLabel.y = venueHeadingLabel.y + 25;
    self.venueTextLabel.font = [ThemeManager lightFontOfSize:12];
//    self.venueTextLabel.centerX = self.view.width/2;
    self.venueTextLabel.numberOfLines = 0;
    self.venueTextLabel.textAlignment = NSTextAlignmentLeft;
    self.venueTextLabel.text = self.venue.placeDescription;
    
//    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 5, cell.contentView.size.width - 50, 1)];
//    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
//    [cell.contentView addSubview:topBorder];
    
    UILabel *venueType = [[UILabel alloc] initWithFrame:CGRectMake(122, 16, self.view.width - 50, 20)];
    venueType.font = [ThemeManager lightFontOfSize:9];
    venueType.textColor = [UIColor darkGrayColor];
    venueType.textAlignment = NSTextAlignmentLeft;
    venueType.numberOfLines = 1;
    venueType.text = [self.venue.placeType uppercaseString];
    [cell.contentView addSubview:venueType];
    
    [cell.contentView addSubview:self.venueTextLabel];
    
    return cell;
}

-(UITableViewCell *) getTutorialCell
{
    static NSString *CellIdentifier = @"tutorialCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, cell.contentView.size.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [cell.contentView addSubview:topBorder];
    
    UIImageView *docIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHowThisWorksIcon"]];
    docIcon.y = 15;
    docIcon.x = 22;
    [cell.contentView addSubview:docIcon];

    UILabel *docHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
    docHeadingLabel.text = @"HOW THIS WORKS";
    docHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    docHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:docHeadingLabel];

    UILabel *docTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.view.width, 80)];
    docTextLabel.x = 25;
    docTextLabel.font = [ThemeManager lightFontOfSize:12];
    docTextLabel.width = self.view.width - 50;
    docTextLabel.y = docHeadingLabel.y + 25;
    docTextLabel.numberOfLines = 0;
    docTextLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:docTextLabel];
    
    if (self.venue.deal.isRewardItem) {
        docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'USE FREE DRINK HERE' to get your free drink voucher. To receive drink, just show this voucher to the server.", self.venue.name];
    } else {
        docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'CHECK IN AND GET VOUCHER' to get a drink voucher. You'll only be charged once, through the app, when your server taps to redeem.", self.venue.name];
    }
    
    return cell;
}

-(UITableViewCell *) getMapCell
{
    static NSString *CellIdentifier = @"mapCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, cell.contentView.size.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [cell.contentView addSubview:topBorder];
    
    UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newDirectionsIcon"]];
    locationIcon.y = 15;
    locationIcon.x = 22;
    [cell.contentView addSubview:locationIcon];
    
    UILabel *locationHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
    locationHeadingLabel.text = @"LOCATION";
    locationHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    locationHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:locationHeadingLabel];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    CLLocationCoordinate2D center = self.venue.coordinate;
    options.region = MKCoordinateRegionMakeWithDistance(self.venue.coordinate, 300, 300);
    center.latitude -= options.region.span.latitudeDelta * 0.12;
    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(self.view.width, 200);
    
    UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, self.view.width, 200)];

    MKMapSnapshotter *mapSnapshot = [[MKMapSnapshotter alloc] initWithOptions:options];
    [mapSnapshot startWithCompletionHandler:^(MKMapSnapshot *mapSnap, NSError *error) {
        //mapSnapshotImage = mapSnap.image;
        //UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 55, 25, 120, 120)];
        [mapImageView setImage:mapSnap.image];
        //[mapImageView setImage:[UIImage imageNamed:@"mapMarker"]];
        //CALayer *imageLayer = mapImageView.layer;
        //[imageLayer setCornerRadius:200/2];
        //[imageLayer setBorderWidth:3];
        //[imageLayer setBorderColor:[[UIColor whiteColor] CGColor]];
        //[imageLayer setBorderColor:[[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9] CGColor]];
        //[imageLayer setMasksToBounds:YES];

        UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((mapImageView.frame.size.width/2) - 20, (mapImageView.frame.size.height/2) - 20 - 30, 40, 40)];
        UIImage *markerImage = [UIImage imageNamed:@"bluePin"];
        [markerImageView setImage:markerImage];
        [mapImageView addSubview:markerImageView];

        [mapImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon:)];
        [singleTap setNumberOfTapsRequired:1];
        [mapImageView addGestureRecognizer:singleTap];

        CGSize textSize = [self.venue.address sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]}];

        int addressContainerWidth;
        if (textSize.width < (self.view.width - 10)) {
            addressContainerWidth = textSize.width + 100;
        } else {
            addressContainerWidth = self.view.width - 10;
        }

        UIView *addressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, mapImageView.height - 60, addressContainerWidth, 50)];
        addressContainer.backgroundColor = [UIColor whiteColor];
        addressContainer.centerX = self.view.width/2;
        [mapImageView addSubview:addressContainer];

        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, addressContainer.width, 20)];
        address.text = [self.venue.address uppercaseString];
        address.textAlignment = NSTextAlignmentCenter;
        address.font = [ThemeManager lightFontOfSize:13];
        [addressContainer addSubview:address];

        UILabel *getDirections = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, addressContainer.width, 20)];
        getDirections.text = @"GET DIRECTIONS";
        getDirections.textAlignment = NSTextAlignmentCenter;
        getDirections.textColor = [[ThemeManager sharedTheme] redColor];
        getDirections.font = [ThemeManager lightFontOfSize:13];
        [addressContainer addSubview:getDirections];
    }];
    
    [cell.contentView addSubview:mapImageView];
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dealCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == self.imageContainer) {
        return [self getImageCell];
    } else if (indexPath.row == self.dealContainer && self.deal) {
        return [self getDealCell];
    } else if (indexPath.row == self.happyHourContainer && self.happyHour) {
        return [self getHappyHourCell];
    } else if (indexPath.row == self.venueContainer && self.hasVenueDescription) {
        return [self getVenueCell];
    } else if (indexPath.row == self.tutorialContainer && self.deal) {
        return [self getTutorialCell];
    } else if (indexPath.row == self.mapContainer) {
        return [self getMapCell];
    }
    
    return cell;
}

@end