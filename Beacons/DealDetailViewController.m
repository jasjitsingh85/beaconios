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
#import "Event.h"
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
#import "SocialNotificationPopupView.h"
#import "WebViewController.h"
#import "FaqViewController.h"

@interface DealDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *getDealButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UIView *getDealButtonContainer;
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
@property (assign, nonatomic) BOOL isDealActive;

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

@property (strong, nonatomic) UITableViewCell *mapCell;
@property (strong, nonatomic) DealDetailImageCell *imageCell;
@property (strong, nonatomic) UITableViewCell *dealCell;
@property (strong, nonatomic) UITableViewCell *tutorialCell;
@property (strong, nonatomic) UITableViewCell *happyHourCell;
@property (strong, nonatomic) UITableViewCell *venueCell;
@property (strong, nonatomic) UITableViewCell *eventsCell;

@property (strong, nonatomic) UILabel *togglePrompt;
@property (strong, nonatomic) UIButton *togglePromptHelpButton;

@property (strong, nonatomic) UIButton *openYelpButton;
@property (strong, nonatomic) WebViewController *webView;
@property (strong, nonatomic) FaqViewController *faqViewController;
@property (strong, nonatomic) UIView *checkInLabelContainer;
@property (strong, nonatomic) UILabel *checkInText;
@property (strong, nonatomic) UIImageView *checkInIcon;

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.webView = [[WebViewController alloc] init];
    self.faqViewController = [[FaqViewController alloc] initForModal];
    
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
    
    self.getDealButtonContainer = [[UIView alloc] init];
    self.getDealButtonContainer.backgroundColor = [UIColor whiteColor];
    self.getDealButtonContainer.width = self.view.width;
    self.getDealButtonContainer.height = 100;
    self.getDealButtonContainer.y = self.view.height - 100;
    self.getDealButtonContainer.userInteractionEnabled = YES;
    [self.view addSubview:self.getDealButtonContainer];
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.width - 70, 7.5, 100, 30)];
    switchView.on = YES;
    switchView.transform = CGAffineTransformMakeScale(0.75, .75);
    switchView.onTintColor = [[ThemeManager sharedTheme] redColor];
    [switchView addTarget:self action:@selector(updateToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.getDealButtonContainer addSubview:switchView];
    
    self.togglePrompt = [[UILabel alloc] initWithFrame:CGRectMake(25, 12.5, self.view.width, 20)];
    self.togglePrompt.font = [ThemeManager lightFontOfSize:12];
    self.togglePrompt.textAlignment = NSTextAlignmentLeft;
//    self.togglePrompt.text = @"Friends - Your friends see where you're going";
    [self.getDealButtonContainer addSubview:self.togglePrompt];
    
    self.togglePromptHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.togglePromptHelpButton.size = CGSizeMake(24, 24);
    self.togglePromptHelpButton.y = 12;
    [self.togglePromptHelpButton setImage:[UIImage imageNamed:@"blackHelpButton"] forState:UIControlStateNormal];
//    [self.mapListToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.mapListToggleButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.togglePromptHelpButton addTarget:self action:@selector(showHelpModal:) forControlEvents:UIControlEventTouchUpInside];
    [self.getDealButtonContainer addSubview:self.togglePromptHelpButton];
    
    self.checkInText = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, self.view.width, 20)];
    self.checkInText.textAlignment = NSTextAlignmentCenter;
    self.checkInText.font = [ThemeManager lightFontOfSize:12];
    
    [self updateToggle:switchView];
    
    self.isDealActive = YES;
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
//    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:204 green:204 blue:204 alpha:255];
    topBorder.backgroundColor = [UIColor blackColor];
    [self.getDealButtonContainer addSubview:topBorder];
    
    //    self.publicToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    self.publicToggleButton.size = CGSizeMake(65, 25);
    //    self.publicToggleButton.x = self.view.width - 90;
    //    self.publicToggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //    self.publicToggleButton.y = 45;
    //    [self.publicToggleButton setTitle:@"Friends" forState:UIControlStateNormal];
    //    [self.publicToggleButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    //    [self.publicToggleButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    //    self.publicToggleButton.titleLabel.font = [ThemeManager mediumFontOfSize:9];
    //    self.publicToggleButton.backgroundColor = [UIColor clearColor];
    //    self.publicToggleButton.titleLabel.textColor = [[ThemeManager sharedTheme] redColor];
    //    [self.publicToggleButton addTarget:self action:@selector(publicToggleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.getDealButtonContainer addSubview:self.publicToggleButton];
    //
    //    self.publicToggleButtonIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publicGlobe"]];
    //    self.publicToggleButtonIcon.frame = CGRectMake(16, 5, 16, 16);
    //    [self.publicToggleButton addSubview:self.publicToggleButtonIcon];
    
    self.getDealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getDealButton.size = CGSizeMake(self.view.width - 50, 35);
    self.getDealButton.centerX = self.view.width/2.0;
    self.getDealButton.y = 45;
    self.getDealButton.layer.cornerRadius = 4;
    self.getDealButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
    [self.getDealButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getDealButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    self.checkInIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkInIcon"]];
    self.checkInIcon.y = 5.75;
    self.checkInIcon.x = 69;
    
    self.checkInLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.view.width, 25)];
    [self.checkInLabelContainer addSubview:self.checkInIcon];
    [self.checkInLabelContainer addSubview:self.checkInText];
    [self.getDealButtonContainer addSubview:self.checkInLabelContainer];
    
    [self.getDealButtonContainer addSubview:self.getDealButton];
    
    self.getDealButton.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [self.getDealButton addTarget:self action:@selector(getDealButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
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

-(NSInteger) eventsContainer {
    return 4;
}

-(NSInteger) venueContainer {
    return 1;
}

-(NSInteger) mapContainer {
    return 6;
}

-(NSInteger) tutorialContainer {
    return 5;
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

- (void) setVenue:(Venue *)venue

{
    _venue = venue;
    
    self.hasVenueDescription = !isEmpty(self.venue.placeDescription);
    
    [self updateIsUserPresent];
    [self updateVenueData];
    
    [self getDealCell];
    [self getMapCell];
    [self getTutorialCell];
    [self getHappyHourCell];
    [self getVenueCell];
    [self getEventsCell];
    [self getImageCell];
    
//    self.dealPrompt = [[UILabel alloc] initWithFrame:CGRectMake(25, 47, 150, 16)];
//    self.dealPrompt.font = [ThemeManager mediumFontOfSize:9];
//    self.dealPrompt.textColor = [UIColor unnormalizedColorWithRed:38 green:38 blue:38 alpha:255];
//    self.dealPrompt.text = @"Tap below to get voucher";
//    [self.getDealButtonContainer addSubview:self.dealPrompt];
    
    if (!self.deal) {
        [self.getDealButtonContainer setHidden:YES];
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    } else {
        [self.getDealButtonContainer setHidden:NO];
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 110.0, 0.0);
    }

    if ([self.deal.checkInCount intValue] > 24) {
        self.getDealButtonContainer.height = 110;
        self.getDealButtonContainer.y = self.view.height - 110;
        self.checkInText.text = [NSString stringWithFormat:@"%@ people have checked-in here", self.venue.deal.checkInCount];
        self.checkInLabelContainer.hidden = NO;
    } else {
        self.getDealButtonContainer.height = 97;
        self.getDealButtonContainer.y = self.view.height - 97;
        self.checkInLabelContainer.hidden = YES;
    }
    
    [self updateButtonText];
    
    [self.tableView reloadData];
    
    [[APIClient sharedClient] trackView:self.venue.venueID ofType:kDealPlaceViewType success:nil failure:nil];
    
    [[APIClient sharedClient] getIsDealActive:self.venue.venueID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isDealActive = [responseObject[@"active"] boolValue];
    } failure:nil];

}

//-(void) publicToggleButtonTouched:(id)sender
//{
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"Select 'Friends' so your friends know where you’re going. Select 'Only Me' if you don’t want your friends to see your activity."];
//    [actionSheet bk_addButtonWithTitle:@"Friends" handler:^{
//        self.isPublic = YES;
//        [self.publicToggleButton setTitle:@"Friends" forState:UIControlStateNormal];
//        [self.publicToggleButtonIcon setImage:[UIImage imageNamed:@"publicGlobe"]];
//    }];
//    [actionSheet bk_addButtonWithTitle:@"Only Me" handler:^{
//        self.isPublic = NO;
//        [self.publicToggleButton setTitle:@"Only Me" forState:UIControlStateNormal];
//        [self.publicToggleButtonIcon setImage:[UIImage imageNamed:@"privateLock"]];
//    }];
//    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
//    [actionSheet showInView:self.view];
//}

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
        if (self.isDealActive) {
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
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Limit Reached" message:@"You already used Hotspot here today. You can only redeem one Hotspot drink special per venue per day." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 186;
    if (indexPath.row == self.imageContainer) {
        height = 201;
    } else if (indexPath.row == self.mapContainer) {
        height = 250;
        
    } else if (indexPath.row == self.eventsContainer) {
        if (self.venue.events.count > 0) {
            height = 50 + (self.venue.events.count * 38);
        } else {
            height = 0;
        }
    } else if (indexPath.row == self.dealContainer || indexPath.row==self.tutorialContainer) {
        if (!self.deal) {
            height = 0;
        } else {
            if (indexPath.row == self.dealContainer) {
                NSString *dealTextLabel = [self getDealTextLabel];
                NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
                CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
                CGRect dealTextHeight = [dealTextLabel boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:12.5]} context:context];
                self.dealTextLabel.height = dealTextHeight.size.height + 5;
//                self.dealTime.y = self.dealTextLabel.y + self.dealTextLabel.height + 3;
                height = dealTextHeight.size.height + 55;
            } else {
                height = 138;
            }
        }
    } else if (indexPath.row == self.happyHourContainer) {
        if (!self.happyHour) {
            height = 0;
        } else {
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
            CGRect happyHourDescriptionHeight = [self.happyHour.happyHourDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:12]} context:context];
            
            self.happyHourTextLabel.height = happyHourDescriptionHeight.size.height + 5;
//            self.happyHourTime.y = self.happyHourTextLabel.y + self.happyHourTextLabel.height + 3;
            height = happyHourDescriptionHeight.size.height + 50;
        }
    } else if (indexPath.row == self.venueContainer) {
        if (!self.hasVenueDescription) {
            height = 0;
        } else {
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGSize labelSize = (CGSize){self.view.width - 50, FLT_MAX};
            CGRect venueDescriptionHeight = [self.venue.placeDescription boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:12]} context:context];
            self.venueTextLabel.height = venueDescriptionHeight.size.height + 5;
            self.openYelpButton.y = self.venueTextLabel.y + self.venueTextLabel.height;
            if (![self.venue.yelpRating isEmpty]) {
                height = venueDescriptionHeight.size.height + 70;
            } else {
                height = venueDescriptionHeight.size.height + 50;
            }
            
            if (!isEmpty(self.venue.yelpID)) {
                height = height + 23;
            }
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

-(void) getDealCell
{
    static NSString *CellIdentifier = @"dealCell";
    self.dealCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.dealCell) {
        self.dealCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.dealCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (!isEmpty(self.venue.deal)) {
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.dealCell.contentView.size.width - 50, 0.5)];
        topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        [self.dealCell.contentView addSubview:topBorder];
        
        UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHotspotIcon"]];
        dealIcon.x = 22;
        dealIcon.y = 15;
        [self.dealCell.contentView addSubview:dealIcon];
        
        UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
        //    dealHeadingLabel.centerX = self.view.width/2;
        dealHeadingLabel.text = @"HOTSPOT SPECIAL";
        dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
        dealHeadingLabel.textAlignment = NSTextAlignmentLeft;
        [self.dealCell.contentView addSubview:dealHeadingLabel];
        
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
        [self.dealCell.contentView addSubview:self.dealTime];
        
        [self.dealCell.contentView addSubview:self.dealTextLabel];
    }
}

-(void) getImageCell
{
    self.imageCell = [[DealDetailImageCell alloc] init];
    self.imageCell.venue = self.venue;
    self.imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void) getHappyHourCell
{
    static NSString *CellIdentifier = @"happyHourCell";
    self.happyHourCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.happyHourCell) {
        self.happyHourCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.happyHourCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (!isEmpty(self.happyHour)) {
        if (self.hasVenueDescription) {
            UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.happyHourCell.contentView.size.width - 50, 0.5)];
            topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
            [self.happyHourCell.contentView addSubview:topBorder];
        }
        
        UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHappyHourIcon"]];
        dealIcon.x = 22;
        dealIcon.y = 15;
        [self.happyHourCell.contentView addSubview:dealIcon];
        
        UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
        dealHeadingLabel.text = @"HAPPY HOUR";
        dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
        dealHeadingLabel.textAlignment = NSTextAlignmentLeft;
        [self.happyHourCell.contentView addSubview:dealHeadingLabel];
        
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
        [self.happyHourCell.contentView addSubview:self.happyHourTime];
        
        [self.happyHourCell.contentView addSubview:self.happyHourTextLabel];
    }
}

-(void) getVenueCell
{
    static NSString *CellIdentifier = @"venueCell";
    self.venueCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.venueCell) {
        self.venueCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.venueCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.hasVenueDescription) {
        UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newVenueIcon"]];
        venueIcon.x = 22;
        venueIcon.y = 15;
        [self.venueCell.contentView addSubview:venueIcon];
        
        UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
        //    venueHeadingLabel.centerX = self.view.width/2;
        venueHeadingLabel.text = [self.venue.name uppercaseString];
        venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
        venueHeadingLabel.textAlignment = NSTextAlignmentLeft;
        [self.venueCell.contentView addSubview:venueHeadingLabel];
        
        UIView *yelpContainer = [[UIView alloc] initWithFrame:CGRectMake(0, venueHeadingLabel.y + 26.5, self.view.width, 25)];
        [self.venueCell.contentView addSubview:yelpContainer];
        if (![self.venue.yelpRating isEmpty]) {
            UIImageView *yelpReview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2.5, 83, 15)];
            yelpReview.x = 25;
            [yelpReview sd_setImageWithURL:self.venue.yelpRating];
    
            UIImageView *poweredByYelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelpLogo"]];
            poweredByYelp.y = 1.5;
            poweredByYelp.x = 181;
            [yelpContainer addSubview:poweredByYelp];
    
            UILabel *yelpReviewCount = [[UILabel alloc] initWithFrame:CGRectMake(112, 2.5, 67, 15)];
            yelpReviewCount.textColor = [[ThemeManager sharedTheme] darkGrayColor];
            yelpReviewCount.font = [ThemeManager lightFontOfSize:10];
            yelpReviewCount.textAlignment = NSTextAlignmentRight;
            yelpReviewCount.text = [NSString stringWithFormat:@"%@ reviews on", self.venue.yelpReviewCount];
            [yelpContainer addSubview:yelpReviewCount];
    
            [yelpContainer addSubview:yelpReview];
        } else {
            yelpContainer.height = 0;
        }
        
        self.venueTextLabel = [[UILabel alloc] init];
        self.venueTextLabel.x = 25;
        self.venueTextLabel.width = self.view.width - 50;
        self.venueTextLabel.y = venueHeadingLabel.y + yelpContainer.height + 23;
//        self.venueTextLabel.y = venueHeadingLabel.y + 25;
        self.venueTextLabel.font = [ThemeManager lightFontOfSize:12];
        //    self.venueTextLabel.centerX = self.view.width/2;
        self.venueTextLabel.numberOfLines = 0;
        self.venueTextLabel.textAlignment = NSTextAlignmentLeft;
        self.venueTextLabel.text = self.venue.placeDescription;
        
        //    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 5, cell.contentView.size.width - 50, 1)];
        //    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        //    [cell.contentView addSubview:topBorder];
        
        CGSize textSize = [venueHeadingLabel.text sizeWithAttributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:12]}];
        
        if (self.venue.placeType) {
            UILabel *venueType = [[UILabel alloc] initWithFrame:CGRectMake(122, 16.5, self.view.width - 50, 20)];
            venueType.font = [ThemeManager lightFontOfSize:9];
            venueType.textColor = [UIColor darkGrayColor];
            venueType.textAlignment = NSTextAlignmentLeft;
            venueType.numberOfLines = 1;
            venueType.text = [self.venue.placeType uppercaseString];
            venueType.x = venueHeadingLabel.x + textSize.width + 4;
            [self.venueCell.contentView addSubview:venueType];
            [self.venueCell.contentView addSubview:self.venueTextLabel];
        }
    }
    
    if (!isEmpty(self.venue.yelpID)) {
        self.openYelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.openYelpButton.frame = CGRectMake(25, 0, self.venueCell.contentView.width - 50, 25);
        [self.openYelpButton setTitle:@"See in Yelp" forState:UIControlStateNormal];
        self.openYelpButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
        self.openYelpButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.openYelpButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:1.] forState:UIControlStateNormal];
        [self.openYelpButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        self.openYelpButton.layer.cornerRadius = 3;
//        self.openYelpButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
//        self.openYelpButton.layer.borderWidth = 1.5;
        [self.openYelpButton addTarget:self action:@selector(openYelpButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.venueCell.contentView addSubview:self.openYelpButton];
    }
}

-(void) getEventsCell
{
    
    static NSString *CellIdentifier = @"eventCell";
    self.eventsCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.eventsCell) {
        self.eventsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.eventsCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.venue.events.count > 0) {
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.eventsCell.contentView.size.width - 50, 0.5)];
        topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        [self.eventsCell.contentView addSubview:topBorder];
        
        UIImageView *eventIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"happeningsIcon"]];
        eventIcon.y = 15;
        eventIcon.x = 22;
        [self.eventsCell.contentView addSubview:eventIcon];
        
        UILabel *eventHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
        eventHeadingLabel.text = @"HAPPENINGS";
        eventHeadingLabel.font = [ThemeManager boldFontOfSize:12];
        eventHeadingLabel.textAlignment = NSTextAlignmentLeft;
        [self.eventsCell.contentView addSubview:eventHeadingLabel];
        
        for (int i = 0; i < [self.venue.events count]; i++)
        {
            Event *event = self.venue.events[i];
            UILabel *eventTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 38 + (38 * i), self.view.width - 50, 20)];
            eventTextLabel.tag = i;
            eventTextLabel.font = [ThemeManager boldFontOfSize:12];
            eventTextLabel.numberOfLines = 1;
            eventTextLabel.textAlignment = NSTextAlignmentLeft;
            eventTextLabel.text = [NSString stringWithFormat:@"\u2022 %@", [event.title capitalizedString]];
            [self.eventsCell.contentView addSubview:eventTextLabel];
            
            UILabel *eventTimeTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 53 + (38 * i), self.view.width - 50, 20)];
            eventTimeTextLabel.tag = i;
            eventTimeTextLabel.font = [ThemeManager italicFontOfSize:11];
            eventTimeTextLabel.numberOfLines = 1;
            eventTimeTextLabel.textAlignment = NSTextAlignmentLeft;
            eventTimeTextLabel.text = event.getDateAsString;
            [self.eventsCell.contentView addSubview:eventTimeTextLabel];
            
            UITapGestureRecognizer *eventHeaderGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapped:)];
            eventHeaderGestureRecognizer.numberOfTapsRequired = 1;
            [eventTextLabel addGestureRecognizer:eventHeaderGestureRecognizer];
            eventTextLabel.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *eventBodyGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapped:)];
            eventBodyGestureRecognizer.numberOfTapsRequired = 1;
            [eventTimeTextLabel addGestureRecognizer:eventBodyGestureRecognizer];
            eventTimeTextLabel.userInteractionEnabled = YES;
        }
    }
}

-(void)eventTapped:(UITapGestureRecognizer *)sender
{
    UIView *view = sender.view; //cast pointer to the derived class if needed
    NSLog(@"%ld", (long)view.tag);
    
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    Event *event = self.events[view.tag];
    if (isInstalled) {;
        [[UIApplication sharedApplication] openURL:event.deepLinkURL];
    } else {
        self.webView.websiteUrl = event.websiteURL;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webView];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}

-(void) getTutorialCell
{
    
    static NSString *CellIdentifier = @"tutorialCell";
    self.tutorialCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.tutorialCell) {
        self.tutorialCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.tutorialCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.tutorialCell.contentView.size.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [self.tutorialCell.contentView addSubview:topBorder];
    
    UIImageView *docIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHowThisWorksIcon"]];
    docIcon.y = 15;
    docIcon.x = 22;
    [self.tutorialCell.contentView addSubview:docIcon];

    UILabel *docHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
    docHeadingLabel.text = @"HOW THIS WORKS";
    docHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    docHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [self.tutorialCell.contentView addSubview:docHeadingLabel];

    UILabel *docTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.view.width, 80)];
    docTextLabel.x = 25;
    docTextLabel.font = [ThemeManager lightFontOfSize:12];
    docTextLabel.width = self.view.width - 50;
    docTextLabel.y = docHeadingLabel.y + 25;
    docTextLabel.numberOfLines = 0;
    docTextLabel.textAlignment = NSTextAlignmentLeft;
    [self.tutorialCell.contentView addSubview:docTextLabel];
    
    if (self.venue.deal.isRewardItem) {
        docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'USE FREE DRINK HERE' to get your free drink voucher. To receive drink, just show this voucher to the server.", self.venue.name];
    } else {
        docTextLabel.text = [NSString stringWithFormat:@"We buy drinks wholesale from %@ to save you money. Tap 'CHECK IN AND GET VOUCHER' to get a drink voucher. You'll only be charged once, through the app, when your server taps to redeem.", self.venue.name];
    }
    
    UIButton *faqButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faqButton.frame = CGRectMake(25, 108, self.tutorialCell.contentView.width - 50, 25);
    [faqButton setTitle:@"Read FAQ" forState:UIControlStateNormal];
    faqButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
    faqButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [faqButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:1.] forState:UIControlStateNormal];
    [faqButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    //        self.openYelpButton.layer.cornerRadius = 3;
    //        self.openYelpButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
    //        self.openYelpButton.layer.borderWidth = 1.5;
    [faqButton addTarget:self action:@selector(faqButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.tutorialCell.contentView addSubview:faqButton];
}

-(void) faqButtonTouched:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.faqViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

-(void) getMapCell
{
    static NSString *CellIdentifier = @"mapCell";
    self.mapCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.mapCell) {
        self.mapCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.mapCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.mapCell.contentView.size.width - 50, 0.5)];
    topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [self.mapCell.contentView addSubview:topBorder];
    
    UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newDirectionsIcon"]];
    locationIcon.y = 15;
    locationIcon.x = 22;
    [self.mapCell.contentView addSubview:locationIcon];
    
    UILabel *locationHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.width, 30)];
    locationHeadingLabel.text = @"LOCATION";
    locationHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    locationHeadingLabel.textAlignment = NSTextAlignmentLeft;
    [self.mapCell.contentView addSubview:locationHeadingLabel];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    CLLocationCoordinate2D center = self.venue.coordinate;
    options.region = MKCoordinateRegionMakeWithDistance(self.venue.coordinate, 300, 300);
    center.latitude += options.region.span.latitudeDelta * .12;
    options.region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(self.view.width, 150);
    
    UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, self.view.width, 150)];

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

        UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((mapImageView.frame.size.width/2) - 20, (mapImageView.frame.size.height/2) - 20, 40, 40)];
        UIImage *markerImage = [UIImage imageNamed:@"bigRedPin"];
        [markerImageView setImage:markerImage];
        [mapImageView addSubview:markerImageView];

        [mapImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDirectionsToBeacon:)];
        [singleTap setNumberOfTapsRequired:1];
        [mapImageView addGestureRecognizer:singleTap];

//        CGSize textSize = [self.venue.address sizeWithAttributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:13]}];

//        int addressContainerWidth;
//        if (textSize.width < (self.view.width - 10)) {
//            addressContainerWidth = textSize.width + 100;
//        } else {
//            addressContainerWidth = self.view.width - 10;
//        }

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
        
        UIButton *getDirectionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        getDirectionsButton.frame = CGRectMake(25, 225, self.mapCell.contentView.width - 50, 25);
        [getDirectionsButton setTitle:@"Get Directions" forState:UIControlStateNormal];
        getDirectionsButton.titleLabel.font = [ThemeManager boldFontOfSize:12];
        getDirectionsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [getDirectionsButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:1.] forState:UIControlStateNormal];
        [getDirectionsButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        getDirectionsButton.layer.cornerRadius = 3;
//        getDirectionsButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
//        getDirectionsButton.layer.borderWidth = 1.5;
        [getDirectionsButton addTarget:self action:@selector(getDirectionsToBeacon:) forControlEvents:UIControlEventTouchUpInside];
        [self.mapCell.contentView addSubview:getDirectionsButton];
    }];
    
    NSString *locationString;
    if (!isEmpty(self.venue.neighborhood)) {
        locationString = [NSString stringWithFormat:@"%@ - %@ | %@", self.venue.address, self.venue.neighborhood, [self stringForDistance:self.venue.distance]];
    } else {
        locationString = [NSString stringWithFormat:@"%@ - %@", self.venue.address, [self stringForDistance:self.venue.distance]];
    }
    
    UILabel *locationInfo = [[UILabel alloc] initWithFrame:CGRectMake(25, 38, self.mapCell.contentView.width - 50, 16)];
    locationInfo.font = [ThemeManager lightFontOfSize:12];
//    locationInfo.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    locationInfo.textColor = [UIColor blackColor];
    locationInfo.text = locationString;
    [self.mapCell.contentView addSubview:locationInfo];

    NSRange range = [locationString rangeOfString:self.venue.address];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:locationString];
    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    locationInfo.attributedText = attributedText;
    
    [self.mapCell.contentView addSubview:mapImageView];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.imageContainer) {
        return self.imageCell;
    } else if (indexPath.row == self.dealContainer && self.deal) {
        return self.dealCell;
    } else if (indexPath.row == self.happyHourContainer && self.happyHour) {
        return self.happyHourCell;
    } else if (indexPath.row == self.venueContainer && self.hasVenueDescription) {
        return self.venueCell;
    } else if (indexPath.row == self.tutorialContainer && self.deal) {
        return self.tutorialCell;
    } else if (indexPath.row == self.mapContainer) {
        return self.mapCell;
    } else if (indexPath.row == self.eventsContainer) {
        return self.eventsCell;
    } else {
        static NSString *CellIdentifier = @"genericCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)updateToggle:(UISwitch *)_switch{
    if ([_switch isOn]) {
        self.isPublic = YES;
        self.togglePromptHelpButton.x = 223;
        self.togglePrompt.text = @"Friends - I'm down with friends joining";
        NSRange range = [self.togglePrompt.text rangeOfString:@"Friends"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.togglePrompt.text];
        [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
        self.togglePrompt.attributedText = attributedText;
    } else {
        self.isPublic = NO;
        self.togglePromptHelpButton.x = 213;
        self.togglePrompt.text = @"Only Me - I want to keep this private";
        NSRange range = [self.togglePrompt.text rangeOfString:@"Only Me"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.togglePrompt.text];
        [attributedText addAttribute:NSFontAttributeName value:[ThemeManager boldFontOfSize:12] range:range];
        self.togglePrompt.attributedText = attributedText;
    }
}

- (void) showHelpModal:(id)sender
{
    SocialNotificationPopupView *modal = [[SocialNotificationPopupView alloc] init];
    [modal show];
}

- (void) openYelpButtonTouched:(id)sender
{
    if ([self isYelpInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"yelp:///biz/%@", self.venue.yelpID]]];
    } else {
        self.webView.websiteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://yelp.com/biz/%@", self.venue.yelpID]];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webView];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}

- (BOOL)isYelpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp://"]];
}

@end