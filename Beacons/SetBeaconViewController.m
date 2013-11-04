//
//  SetBeaconViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/28/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SetBeaconViewController.h"
#import "JADatePicker.h"
#import "JAPlaceholderTextView.h"
#import "Theme.h"
#import "SelectLocationViewController.h"
#import "LocationTracker.h"
#import "Venue.h"
#import "FindFriendsViewController.h"
#import "Beacon.h"
#import "AppDelegate.h"
#import "LoadingIndictor.h"
#import "BeaconManager.h"
#import "CenterNavigationController.h"
#import "MapViewController.h"
#import "BeaconProfileViewController.h"
#import "Contact.h"
#import "BeaconStatus.h"
#import "Utilities.h"
#import "RandomObjectManager.h"
#import "AnalyticsManager.h"

#define MAX_CHARACTER_COUNT 40

@interface SetBeaconViewController () <UITextViewDelegate, JAPlaceholderTextViewDelegate, SelectLocationViewControllerDelegate, FindFriendsViewControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *descriptionContainerView;
@property (strong, nonatomic) UIView *dateContainerView;
@property (strong, nonatomic) UIView *locationContainerView;
@property (strong, nonatomic) UILabel *characterCountLabel;
@property (strong, nonatomic) JAPlaceholderTextView *descriptionTextView;
@property (strong, nonatomic) JADatePicker *datePicker;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIButton *setBeaconButton;
@property (strong, nonatomic) NSString *descriptionPlaceholderText;
@property (strong, nonatomic) NSString *currentLocationAddress;
@property (assign, nonatomic) CLLocationCoordinate2D beaconCoordinate;
@property (assign, nonatomic) BOOL useCurrentLocation;

@end

@implementation SetBeaconViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:234/255.0 green:109/255.0 blue:90/255.0 alpha:1.0];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 504);
    [self.view addSubview:self.scrollView];
    
    self.descriptionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 190)];
    self.descriptionContainerView.backgroundColor = [UIColor colorWithRed:234/255.0 green:109/255.0 blue:90/255.0 alpha:1.0];
    [self.scrollView addSubview:self.descriptionContainerView];
    
    self.dateContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.descriptionContainerView.frame), self.view.frame.size.width, 162)];
    self.dateContainerView.backgroundColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    [self.scrollView addSubview:self.dateContainerView];
    
    self.locationContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dateContainerView.frame), self.view.frame.size.width, 108)];
    self.locationContainerView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationTouched:)];
    locationTap.numberOfTapsRequired =1;
    [self.locationContainerView addGestureRecognizer:locationTap];
    [self.scrollView addSubview:self.locationContainerView];
    
    self.setBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.locationContainerView.frame), self.view.frame.size.width, 44)];
    [self.setBeaconButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    self.setBeaconButton.backgroundColor = [UIColor colorWithRed:236/255.0 green:228/255.0 blue:216/255.0 alpha:1.0];
    [self.setBeaconButton setTitleColor:[UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.setBeaconButton addTarget:self action:@selector(setBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.setBeaconButton];
    
    self.datePicker = [[JADatePicker alloc] initWithFrame:CGRectMake(130, 0, 135, self.dateContainerView.frame.size.height)];
    self.datePicker.date = [NSDate date];
    [self.dateContainerView addSubview:self.self.datePicker];
    
    UILabel *descriptionSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 150, 19)];
    descriptionSectionLabel.text = @"What's going on?";
    descriptionSectionLabel.textColor = [UIColor whiteColor];
    descriptionSectionLabel.font = [ThemeManager regularFontOfSize:15];
    [self.descriptionContainerView addSubview:descriptionSectionLabel];
    
    self.characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(212, 71, 100, 17)];
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d/%d characters",0, MAX_CHARACTER_COUNT];
    self.characterCountLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.characterCountLabel.font = [ThemeManager regularFontOfSize:10];
    self.characterCountLabel.hidden = YES;
    [self.descriptionContainerView addSubview:self.characterCountLabel];
    
    UILabel *dateSectionLabel = [[UILabel alloc] init];
    dateSectionLabel.text = @"When?";
    dateSectionLabel.font = [ThemeManager regularFontOfSize:15];
    dateSectionLabel.textColor = [UIColor whiteColor];
    CGRect dateSectionLabelFrame;
    dateSectionLabelFrame.size = [dateSectionLabel.text sizeWithAttributes:@{NSFontAttributeName : dateSectionLabel.font}];
    dateSectionLabelFrame.origin.x = 40;
    dateSectionLabelFrame.origin.y = 0.5*(self.dateContainerView.frame.size.height - dateSectionLabelFrame.size.height);
    dateSectionLabel.frame = dateSectionLabelFrame;
    [self.dateContainerView addSubview:dateSectionLabel];
    
    UILabel *locationDescriptionLabel = [[UILabel alloc] init];
    locationDescriptionLabel.text = @"Where?";
    locationDescriptionLabel.font = [ThemeManager regularFontOfSize:15];
    locationDescriptionLabel.textColor = [UIColor blackColor];
    CGRect locationDescriptionLabelFrame;
    locationDescriptionLabelFrame.size = [locationDescriptionLabel.text sizeWithAttributes:@{NSFontAttributeName : locationDescriptionLabel.font}];
    locationDescriptionLabelFrame.origin.x = 40;
    locationDescriptionLabelFrame.origin.y = 0.5*(self.locationContainerView.frame.size.height - locationDescriptionLabelFrame.size.height);
    locationDescriptionLabel.frame = locationDescriptionLabelFrame;
    [self.locationContainerView addSubview:locationDescriptionLabel];
    
    NSString *placeholder = [[RandomObjectManager sharedManager] randomSetBeaconPlaceholder];
    self.descriptionPlaceholderText = [@"e.g. " stringByAppendingString:placeholder];
    self.descriptionTextView = [[JAPlaceholderTextView alloc] initWithFrame:CGRectMake(40, 100, 240, 80)];
    self.descriptionTextView.returnKeyType = UIReturnKeyDone;
    self.descriptionTextView.placeholder = self.descriptionPlaceholderText;
    self.descriptionTextView.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.descriptionTextView.font = [ThemeManager regularFontOfSize:15];
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
    self.descriptionTextView.delegate = self;
    [self.descriptionContainerView addSubview:self.descriptionTextView];
    
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.font = [ThemeManager regularFontOfSize:15];
    self.locationLabel.text = @"Current Location";
    self.locationLabel.textColor = [UIColor colorWithRed:241/255.0 green:183/255.0 blue:172/255.0 alpha:1.0];
    CGRect locationLabelFrame;
    locationLabelFrame.size.height = [self.locationLabel.text sizeWithAttributes:@{NSFontAttributeName : self.locationLabel.font}].height;
    locationLabelFrame.size.width = 150;
    locationLabelFrame.origin.x = 147;
    locationLabelFrame.origin.y = 0.5*(self.locationContainerView.frame.size.height - locationLabelFrame.size.height);
    self.locationLabel.frame = locationLabelFrame;
    [self.locationContainerView addSubview:self.locationLabel];
    
    //by default set selected location as current location
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
    self.useCurrentLocation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self view];
    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    NSString *placeholder = [[RandomObjectManager sharedManager] randomSetBeaconPlaceholder];
    self.descriptionPlaceholderText = [@"e.g. " stringByAppendingString:placeholder];
}

- (void)updateCharacterCountLabel
{
    self.characterCountLabel.hidden = self.descriptionTextView.text.length < 20;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d/%d characters", self.descriptionTextView.text.length, MAX_CHARACTER_COUNT];
    self.characterCountLabel.textColor = self.descriptionTextView.text.length == MAX_CHARACTER_COUNT ? [UIColor whiteColor] : [[UIColor whiteColor] colorWithAlphaComponent:0.7];
}

- (void)locationTouched:(id)sender
{
    SelectLocationViewController *selectLocationViewController = [SelectLocationViewController new];
    selectLocationViewController.delegate = self;
    [self.navigationController pushViewController:selectLocationViewController animated:YES];
}

- (void)setBeaconButtonTouched:(id)sender
{
    if (!self.descriptionTextView.text || !self.descriptionTextView.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Baby, you're going too fast!" message:@"Don't forget to set a Hotspot description" delegate:nil cancelButtonTitle:@"I'll slow down" otherButtonTitles:nil] show];
        return;
    }
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
    findFriendsViewController.autoCheckSuggested = NO;
    findFriendsViewController.delegate = self;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
    findFriendsViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(didSelectCurrentLocation)];
}

- (void)didUpdateLocation:(NSNotification *)notification
{
    CLLocation *location = notification.userInfo[@"location"];
    if (self.useCurrentLocation) {
        self.beaconCoordinate = location.coordinate;
        [Utilities reverseGeoCodeLocation:location completion:^(NSString *addressString, NSError *error) {
            self.currentLocationAddress = addressString;
        }];
    }
}

- (NSDate *)dateForBeacon
{
    NSInteger hour = self.datePicker.hour;
    NSInteger minute = self.datePicker.minute;
    NSInteger timeForBeacon = hour*60*60 + minute*60;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    NSInteger timeNow = components.hour*60*60 + components.minute*60;
    NSTimeInterval intervalUntilBeacon = timeForBeacon - timeNow;

    if (intervalUntilBeacon < 0) {
        intervalUntilBeacon += 24*60*60;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:intervalUntilBeacon];
    return date;
}

#pragma mark - SelectLocationViewControllerDelegate
- (void)didSelectVenue:(Venue *)venue
{
    self.useCurrentLocation = NO;
    self.locationLabel.text = venue.name;
    self.beaconCoordinate = venue.coordinate;
}

- (void)didSelectCurrentLocation
{
    self.useCurrentLocation = YES;
    self.locationLabel.text = @"Current Location";
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
}

- (void)didSelectCustomLocation:(CLLocation *)location withName:(NSString *)locationName
{
    self.useCurrentLocation = NO;
    self.locationLabel.text = locationName;
    if (location) {
        self.beaconCoordinate = location.coordinate;
    }
    else {
        self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        //scroll to show invite button for iPhone 4
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        return NO;
    }
    
    NSString *resultantText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (resultantText.length > MAX_CHARACTER_COUNT) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateCharacterCountLabel];
}


#pragma mark - FindFriendsViewControllerDelegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
{
    [self setBeaconOnServerWithInvitedContacts:contacts];
}

#pragma mark - Networking
- (void)setBeaconOnServerWithInvitedContacts:(NSArray *)contacts
{
    NSString *beaconDescription = self.descriptionTextView.text;
    
    
    Beacon *beacon = [[Beacon alloc] init];
    beacon.coordinate = self.beaconCoordinate;
    beacon.time = [self dateForBeacon];
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    for (Contact *contact in contacts) {
        BeaconStatus *status = [[BeaconStatus alloc] init];
        status.contact = contact;
        status.beaconStatusOption = BeaconStatusOptionInvited;
        [invited addObject:status];
    }
    
    beacon.guestStatuses = [NSDictionary dictionaryWithObjects:invited forKeys:[invited valueForKeyPath:@"contact.normalizedPhoneNumber"]];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    beacon.creator = [User loggedInUser];
    beacon.beaconDescription = beaconDescription;
    beacon.address = [self.locationLabel.text isEqualToString:@"Current Location"] ? self.currentLocationAddress : self.locationLabel.text;
    UIView *view = appDelegate.window.rootViewController.view;
    MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
    [[BeaconManager sharedManager] postBeacon:beacon success:^{
        [loadingIndicator hide:YES];
        
        //add user as going. this isn't done earlier to avoid inviting user to own beacon
        BeaconStatus *status = [[BeaconStatus alloc] init];
        status.user = [User loggedInUser];
        status.beaconStatusOption = BeaconStatusOptionGoing;
        NSMutableDictionary *guestStatuses = [[NSMutableDictionary alloc] initWithDictionary:beacon.guestStatuses];
        [guestStatuses setObject:status forKey:status.user.normalizedPhoneNumber];
        beacon.guestStatuses = guestStatuses;
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
        [[AnalyticsManager sharedManager] createBeacon:beacon];
    } failure:^(NSError *error) {
        [loadingIndicator hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

@end
