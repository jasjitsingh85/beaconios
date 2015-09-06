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
#import <SDWebImage/UIImageView+WebCache.h>
#import <MapKit/MapKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Utilities.h"
//#import "FindFriendsViewController.h"
#import "AnalyticsManager.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "LoadingIndictor.h"
#import "DealView.h"
#import "HappyHourView.h"

@interface DealDetailViewController ()

@property (strong, nonatomic) UIButton *getDealButton;
@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UIImageView *getDealButtonContainer;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *dealTime;
@property (strong, nonatomic) UIScrollView *mainScroll;
@property (strong, nonatomic) UIButton *followButton;
@property (strong, nonatomic) UIButton *publicToggleButton;
@property (strong, nonatomic) UIImageView *publicToggleButtonIcon;

@property (strong, nonatomic) UILabel *venueTextLabel;
@property (assign, nonatomic) BOOL isFollowed;
@property (assign, nonatomic) BOOL isPresent;
@property (assign, nonatomic) BOOL isPublic;

@end

@implementation DealDetailViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.mainScroll.scrollEnabled = YES;
    self.mainScroll.userInteractionEnabled = YES;
    
    self.mainScroll.showsVerticalScrollIndicator = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mainScroll.contentSize = CGSizeMake(self.view.width, 800);
    
    self.isPublic = YES;
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followButton.size = CGSizeMake(65, 25);
    self.followButton.x = 0;
    self.followButton.y = 0;
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[[ThemeManager sharedTheme] redColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.titleLabel.font = [ThemeManager regularFontOfSize:10];
    self.followButton.backgroundColor = [UIColor clearColor];
    self.followButton.titleLabel.textColor = [[ThemeManager sharedTheme] redColor];
    self.followButton.layer.cornerRadius = 4;
    self.followButton.layer.borderColor = [[[ThemeManager sharedTheme] redColor] CGColor];
    self.followButton.layer.borderWidth = 1.0;
    [self.followButton addTarget:self action:@selector(followButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.followButton];
    
}

-(void) updateIsUserPresent
{
    if (self.deal.venue.distance < 0.1) {
        self.isPresent = YES;
    } else {
        self.isPresent = NO;
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
        [Utilities launchGoogleMapsDirectionsToCoordinate:self.deal.venue.coordinate addressDictionary:nil destinationName:self.deal.venue.name];
    }];
    [actionSheet bk_addButtonWithTitle:@"Apple Maps" handler:^{
        [Utilities launchAppleMapsDirectionsToCoordinate:self.deal.venue.coordinate addressDictionary:nil destinationName:self.deal.venue.name];
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

- (void) setDeal:(Deal *)deal

{
    _deal = deal;
    
    [self updateIsUserPresent];
    
    bool hasVenueDescription = ![self.deal.venue.placeDescription isEqual: @""];
    
    DealView *dealView = [[DealView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 146)];
    dealView.deal = self.deal;
    [self.mainScroll addSubview:dealView];
    
    self.getDealButtonContainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonBackground"]];
    self.getDealButtonContainer.height = 120;
    self.getDealButtonContainer.y = self.view.height - 120;
    self.getDealButtonContainer.userInteractionEnabled = YES;
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 1)];
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
    
    self.getDealButton.titleLabel.font = [ThemeManager boldFontOfSize:15];
    [self.getDealButton addTarget:self action:@selector(getDealButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *dealPrompt = [[UILabel alloc] initWithFrame:CGRectMake(25, 47, 150, 16)];
    dealPrompt.font = [ThemeManager mediumFontOfSize:9];
    dealPrompt.textColor = [UIColor unnormalizedColorWithRed:38 green:38 blue:38 alpha:255];
    dealPrompt.text = @"Tap below to get voucher";
    [self.getDealButtonContainer addSubview:dealPrompt];
    
    UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dollarSign"]];
    dealIcon.centerX = self.view.width/2;
    dealIcon.y = 165;
    [self.mainScroll addSubview:dealIcon];
    
    UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 185, self.view.width, 30)];
    dealHeadingLabel.centerX = self.view.width/2;
    dealHeadingLabel.text = @"THE DEAL";
    dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    dealHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainScroll addSubview:dealHeadingLabel];
    
    UILabel *dealTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, self.view.width - 50, 60)];
    dealTextLabel.centerX = self.view.width/2;
    dealTextLabel.font = [ThemeManager lightFontOfSize:13];
    dealTextLabel.textAlignment = NSTextAlignmentCenter;
    dealTextLabel.numberOfLines = 0;
    
    if (deal.isRewardItem) {
        [self.getDealButton setTitle:@"USE FREE DRINK HERE" forState:UIControlStateNormal];
        dealTextLabel.text = [NSString stringWithFormat:@"You get a %@ for free. %@", [self.deal.itemName lowercaseString], self.deal.additionalInfo];
    } else {
        if (self.isPresent) {
            [self.getDealButton setTitle:@"CHECK IN HERE" forState:UIControlStateNormal];
        } else {
            [self.getDealButton setTitle:@"I'M GOING HERE" forState:UIControlStateNormal];
        }
        if ([[self.deal.itemName lowercaseString] hasPrefix:@"any"]) {
            dealTextLabel.text = [NSString stringWithFormat:@"You get %@ for $%@. %@", [self.deal.itemName lowercaseString], self.deal.itemPrice, self.deal.additionalInfo];
        } else {
            dealTextLabel.text = [NSString stringWithFormat:@"You get a %@ for $%@. %@", [self.deal.itemName lowercaseString], self.deal.itemPrice, self.deal.additionalInfo];
        }
    }
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
    CGRect dealTextHeight = [dealTextLabel.text boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13.5]} context:context];

    
    dealTextLabel.height = dealTextHeight.size.height;
    [self.mainScroll addSubview:dealTextLabel];
    
    if (hasVenueDescription) {
        
        UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"venueIcon"]];
        venueIcon.centerX = self.view.width/2;
        venueIcon.y = dealTextLabel.y + dealTextLabel.height + 10;
        [self.mainScroll addSubview:venueIcon];
        
        UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueIcon.y + 20, self.view.width, 30)];
        venueHeadingLabel.centerX = self.view.width/2;
        venueHeadingLabel.text = @"THE VENUE";
        venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
        venueHeadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.mainScroll addSubview:venueHeadingLabel];
        
        UIView *yelpContainer = [[UIView alloc] initWithFrame:CGRectMake(0, venueHeadingLabel.y + 25, self.view.width, 25)];
        [self.mainScroll addSubview:yelpContainer];
        NSLog(@"yelpRating: %@", self.deal.venue.yelpRating);
        if (![self.deal.venue.yelpRating isEmpty]) {
            UIImageView *yelpReview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 83, 15)];
            yelpReview.centerX = self.view.width/2;
            [yelpReview sd_setImageWithURL:self.deal.venue.yelpRating];
            
            UIImageView *poweredByYelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelpLogo"]];
            poweredByYelp.y = 4;
            poweredByYelp.x = self.view.width - 48;
            [yelpContainer addSubview:poweredByYelp];
            
            UILabel *yelpReviewCount = [[UILabel alloc] initWithFrame:CGRectMake(203, 5, 67, 15)];
            yelpReviewCount.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
            yelpReviewCount.font = [ThemeManager lightFontOfSize:10];
            yelpReviewCount.textAlignment = NSTextAlignmentRight;
            yelpReviewCount.text = [NSString stringWithFormat:@"%@ reviews on", self.deal.venue.yelpReviewCount];
            [yelpContainer addSubview:yelpReviewCount];
            
            [yelpContainer addSubview:yelpReview];
        } else {
            yelpContainer.height = 0;
        }
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
        CGRect venueDescriptionHeight = [self.deal.venue.placeDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:14]} context:context];
        
        self.venueTextLabel = [[UILabel alloc] init];
        self.venueTextLabel.x = 0;
        self.venueTextLabel.width = self.view.width - 50;
        self.venueTextLabel.y = venueHeadingLabel.y + yelpContainer.height + 25;
        self.venueTextLabel.height = venueDescriptionHeight.size.height;
        self.venueTextLabel.font = [ThemeManager lightFontOfSize:13];
        self.venueTextLabel.centerX = self.view.width/2;
        self.venueTextLabel.numberOfLines = 0;
        self.venueTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.mainScroll addSubview:self.venueTextLabel];
        
    }
    
    UIImageView *docIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentIcon"]];
    docIcon.centerX = self.view.width/2;
    [self.mainScroll addSubview:docIcon];
    
    UILabel *docHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    docHeadingLabel.centerX = self.view.width/2;
    docHeadingLabel.text = @"HOW THIS WORKS";
    docHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    docHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainScroll addSubview:docHeadingLabel];
    
    UILabel *docTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
    docTextLabel.centerX = self.view.width/2;
    docTextLabel.font = [ThemeManager lightFontOfSize:13];
    docTextLabel.width = self.view.width - 50;
    docTextLabel.centerX = self.view.width/2;
    docTextLabel.numberOfLines = 0;
    docTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainScroll addSubview:docTextLabel];
    
    if (hasVenueDescription) {
        docIcon.y = self.venueTextLabel.y + self.venueTextLabel.size.height + 15;
        docHeadingLabel.y = docIcon.y + 20;
        docTextLabel.y = docIcon.y + 40;
    } else {
        docIcon.y = dealTextLabel.y + dealTextLabel.size.height + 10;
        docHeadingLabel.y = docIcon.y + 20;
        docTextLabel.y = docIcon.y + 40;
    }
    
    UIImageView *directionsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directionsIcon"]];
    directionsIcon.centerX = self.view.width/2;
    directionsIcon.y = docTextLabel.y + docTextLabel.size.height + 10;
    [self.mainScroll addSubview:directionsIcon];
    
    UILabel *directionHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    directionHeadingLabel.y = docTextLabel.y + docTextLabel.size.height + 30;
    directionHeadingLabel.centerX = self.view.width/2;
    directionHeadingLabel.text = @"DIRECTIONS";
    directionHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    directionHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainScroll addSubview:directionHeadingLabel];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    CLLocationCoordinate2D center = self.deal.venue.coordinate;
    options.region = MKCoordinateRegionMakeWithDistance(self.deal.venue.coordinate, 300, 300);
    center.latitude -= options.region.span.latitudeDelta * 0.12;
    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(self.view.width, 200);
    
    MKMapSnapshotter *mapSnapshot = [[MKMapSnapshotter alloc] initWithOptions:options];
    [mapSnapshot startWithCompletionHandler:^(MKMapSnapshot *mapSnap, NSError *error) {
        //mapSnapshotImage = mapSnap.image;
        //UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 55, 25, 120, 120)];
        UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, docTextLabel.y + docTextLabel.size.height + 60, self.view.width, 200)];
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
        
        CGSize textSize = [self.deal.venue.address sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]}];
        
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
        address.text = [self.deal.venue.address uppercaseString];
        address.textAlignment = NSTextAlignmentCenter;
        address.font = [ThemeManager lightFontOfSize:13];
        [addressContainer addSubview:address];
        
        UILabel *getDirections = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, addressContainer.width, 20)];
        getDirections.text = @"GET DIRECTIONS";
        getDirections.textAlignment = NSTextAlignmentCenter;
        getDirections.textColor = [[ThemeManager sharedTheme] redColor];
        getDirections.font = [ThemeManager lightFontOfSize:13];
        [addressContainer addSubview:getDirections];
        
        self.mainScroll.contentSize = CGSizeMake(self.view.width, mapImageView.y + mapImageView.height + 90);
        
        [self.mainScroll addSubview:mapImageView];
    }];
    
//    UILabel *dealButtonSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 77, self.view.width, 15)];
//    dealButtonSubtitle.text = @"(You won't be charged yet)";
//    dealButtonSubtitle.centerX = self.view.width/2;
//    dealButtonSubtitle.textAlignment = NSTextAlignmentCenter;
//    dealButtonSubtitle.font = [ThemeManager lightFontOfSize:12];
//    [self.getDealButtonContainer addSubview:dealButtonSubtitle];
    
    //NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.deal.venue.name];
    //self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    //self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    //[self.venueImageView sd_setImageWithURL:self.deal.venue.imageURL];
    //self.distanceLabel.text = [self stringForDistance:self.deal.venue.distance];
    //self.dealTime.text = [self.deal.dealStartString uppercaseString];
    self.venueTextLabel.text = self.deal.venue.placeDescription;
    
    if (deal.isRewardItem) {
        docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'USE FREE DRINK HERE' to get your free drink voucher. To receive drink, just show this voucher to the server.", self.deal.venue.name];
    } else {
        if (self.isPresent) {
            docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'CHECK IN HERE' to get a drink voucher. You'll only be charged once, through the app, when your server taps to redeem.", self.deal.venue.name];
        } else  {
            docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'I'M GOING HERE' to get a drink voucher. You'll only be charged once, through the app, when your server taps to redeem.", self.deal.venue.name];
        }
    }
    
    [self.view addSubview:self.mainScroll];
    
    //[self.view addSubview:self.getDealButton];
    
    [self.getDealButtonContainer addSubview:self.getDealButton];
    [self.view addSubview:self.getDealButtonContainer];
    

    
    if (self.deal.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
    
    [[AnalyticsManager sharedManager] viewedDeal:deal.dealID.stringValue withPlaceName:deal.venue.name];
}

- (void) setHappyHour:(HappyHour *)happyHour
{
    _happyHour = happyHour;
    
    HappyHourView *happyHourView = [[HappyHourView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 146)];
    happyHourView.happyHour = self.happyHour;
    [self.mainScroll addSubview:happyHourView];
    
    bool hasHappyHourVenueDescription = ![self.happyHour.venue.placeDescription isEqual: @""];
    
    UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dollarSign"]];
    dealIcon.centerX = self.view.width/2;
    dealIcon.y = 165;
    [self.mainScroll addSubview:dealIcon];
    
    UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 185, self.view.width, 30)];
    dealHeadingLabel.centerX = self.view.width/2;
    dealHeadingLabel.text = @"HAPPY HOUR DEAL";
    dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    dealHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainScroll addSubview:dealHeadingLabel];
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
    CGRect happyHourDescriptionHeight = [self.happyHour.happyHourDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]} context:context];
    
    UILabel *dealTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, self.view.width - 50, happyHourDescriptionHeight.size.height)];
    dealTextLabel.centerX = self.view.width/2;
    dealTextLabel.font = [ThemeManager lightFontOfSize:13];
    dealTextLabel.textAlignment = NSTextAlignmentCenter;
    dealTextLabel.numberOfLines = 0;
    
    [self.mainScroll addSubview:dealTextLabel];
    
    UIImageView *directionsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directionsIcon"]];
    directionsIcon.centerX = self.view.width/2;
    directionsIcon.y = 0;
    [self.mainScroll addSubview:directionsIcon];
    
    UILabel *directionHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    directionHeadingLabel.y = 0;
    directionHeadingLabel.centerX = self.view.width/2;
    directionHeadingLabel.text = @"DIRECTIONS";
    directionHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    directionHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainScroll addSubview:directionHeadingLabel];
    
    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.happyHour.venue.name];
    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    [self.venueImageView sd_setImageWithURL:self.happyHour.venue.imageURL];
    self.distanceLabel.text = [self stringForDistance:self.happyHour.venue.distance];
    self.dealTime.text = [self.happyHour.happyHourStartString uppercaseString];
    dealTextLabel.text = [NSString stringWithFormat:@"%@", self.happyHour.happyHourDescription];
    
    if (hasHappyHourVenueDescription) {
        UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"venueIcon"]];
        venueIcon.centerX = self.view.width/2;
        venueIcon.y = dealTextLabel.y + dealTextLabel.height + 5;
        [self.mainScroll addSubview:venueIcon];
        
        UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueIcon.y + 20, self.view.width, 30)];
        venueHeadingLabel.centerX = self.view.width/2;
        venueHeadingLabel.text = @"THE VENUE";
        venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
        venueHeadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.mainScroll addSubview:venueHeadingLabel];
        
        UIView *yelpContainer = [[UIView alloc] initWithFrame:CGRectMake(0, venueHeadingLabel.y + 20, self.view.width, 25)];
        [self.mainScroll addSubview:yelpContainer];
        if (![self.happyHour.venue.yelpRating isEmpty]) {
            UIImageView *yelpReview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 83, 15)];
            yelpReview.centerX = self.view.width/2;
            [yelpReview sd_setImageWithURL:self.happyHour.venue.yelpRating];
            
            UIImageView *poweredByYelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelpLogo"]];
            poweredByYelp.y = 4;
            poweredByYelp.x = self.view.width - 48;
            [yelpContainer addSubview:poweredByYelp];
            
            UILabel *yelpReviewCount = [[UILabel alloc] initWithFrame:CGRectMake(203, 5, 67, 15)];
            yelpReviewCount.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
            yelpReviewCount.font = [ThemeManager lightFontOfSize:10];
            yelpReviewCount.textAlignment = NSTextAlignmentRight;
            yelpReviewCount.text = [NSString stringWithFormat:@"%@ reviews on", self.happyHour.venue.yelpReviewCount];
            [yelpContainer addSubview:yelpReviewCount];
            
            [yelpContainer addSubview:yelpReview];
        } else {
            yelpContainer.height = 0;
        }
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
        CGRect happyHourVenueHeight = [self.happyHour.venue.placeDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]} context:context];
        
        self.venueTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueIcon.y + yelpContainer.height + 40, self.view.width - 50, happyHourVenueHeight.size.height)];
        self.venueTextLabel.centerX = self.view.width/2;
        self.venueTextLabel.font = [ThemeManager lightFontOfSize:13];
        self.venueTextLabel.centerX = self.view.width/2;
        self.venueTextLabel.numberOfLines = 0;
        self.venueTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.mainScroll addSubview:self.venueTextLabel];
        
        self.venueTextLabel.text = self.happyHour.venue.placeDescription;
    }
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    CLLocationCoordinate2D center = self.happyHour.venue.coordinate;
    options.region = MKCoordinateRegionMakeWithDistance(self.deal.venue.coordinate, 300, 300);
    center.latitude -= options.region.span.latitudeDelta * 0.12;
    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(self.view.width, 200);
    
    MKMapSnapshotter *mapSnapshot = [[MKMapSnapshotter alloc] initWithOptions:options];
    [mapSnapshot startWithCompletionHandler:^(MKMapSnapshot *mapSnap, NSError *error) {
        //mapSnapshotImage = mapSnap.image;
        //UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 55, 25, 120, 120)];
        UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
        [mapImageView setImage:mapSnap.image];
        //[mapImageView setImage:[UIImage imageNamed:@"mapMarker"]];
        //CALayer *imageLayer = mapImageView.layer;
        //[imageLayer setCornerRadius:200/2];
        //[imageLayer setBorderWidth:3];
        //[imageLayer setBorderColor:[[UIColor whiteColor] CGColor]];
        //[imageLayer setBorderColor:[[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9] CGColor]];
        //[imageLayer setMasksToBounds:YES];
        
        UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((mapImageView.frame.size.width/2) - 20, (mapImageView.frame.size.height/2) - 20 - 30, 40, 40)];
        UIImage *markerImage = [UIImage imageNamed:@"purplePin"];
        [markerImageView setImage:markerImage];
        [mapImageView addSubview:markerImageView];
        
        [mapImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon:)];
        [singleTap setNumberOfTapsRequired:1];
        [mapImageView addGestureRecognizer:singleTap];
        
        CGSize textSize = [self.happyHour.venue.address sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]}];
        
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
        address.text = [self.happyHour.venue.address uppercaseString];
        address.textAlignment = NSTextAlignmentCenter;
        address.font = [ThemeManager lightFontOfSize:13];
        [addressContainer addSubview:address];
        
        UILabel *getDirections = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, addressContainer.width, 20)];
        getDirections.text = @"GET DIRECTIONS";
        getDirections.textAlignment = NSTextAlignmentCenter;
        getDirections.textColor = [[ThemeManager sharedTheme] redColor];
        getDirections.font = [ThemeManager lightFontOfSize:13];
        [addressContainer addSubview:getDirections];
        
        if (hasHappyHourVenueDescription) {
            directionsIcon.y = self.venueTextLabel.y + self.venueTextLabel.height + 10;
        } else {
            directionsIcon.y = dealTextLabel.y + dealTextLabel.height + 10;
        }
        directionHeadingLabel.y = directionsIcon.y + directionsIcon.height;
        mapImageView.y = directionHeadingLabel.y + directionHeadingLabel.height;
        
        [self.mainScroll addSubview:mapImageView];
        
        self.mainScroll.contentSize = CGSizeMake(self.view.width, mapImageView.y + mapImageView.height + 50);
    }];
    
    [self.view addSubview:self.mainScroll];
    
    if (self.happyHour.isFollowed) {
        [self makeFollowButtonActive];
    } else {
        [self makeFollowButtonInactive];
    }
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
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIView *view = appDelegate.window.rootViewController.view;
    MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
    [[APIClient sharedClient] checkInForDeal:self.deal isPresent:self.isPresent isPublic:self.isPublic success:^(Beacon *beacon) {
        [loadingIndicator hide:YES];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
//        [[AnalyticsManager sharedManager] setDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name numberOfInvites:contacts.count];
    } failure:^(NSError *error) {
        [loadingIndicator hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
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
    if (self.deal != nil) {
        venueID = self.deal.venue.venueID;
    } else  {
        venueID = self.happyHour.venue.venueID;
    }
    
    [[APIClient sharedClient] toggleFavorite:venueID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isFollowed = [responseObject[@"is_favorited"] boolValue];
        [self updateFavoriteButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUpdateNotification object:self];
    } failure:nil];
}

- (void) makeFollowButtonActive
{
    [self.followButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(85, 25);
//    self.followButton.x = self.contentView.width - 95;
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    self.followButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
}

- (void) makeFollowButtonInactive
{
    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    self.followButton.size = CGSizeMake(65, 25);
//    self.followButton.x = self.contentView.width - 85;
    [self.followButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[[[ThemeManager sharedTheme] redColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
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

@end