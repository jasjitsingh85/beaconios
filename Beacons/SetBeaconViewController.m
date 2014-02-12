//
//  SetBeaconViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/28/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SetBeaconViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UIButton+HSNavButton.h"
#import "JADatePicker.h"
#import "JAPlaceholderTextView.h"
#import "JAInsetLabel.h"
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
#import "ContactManager.h"
#import "LockedViewController.h"

#define MAX_CHARACTER_COUNT 40

@interface SetBeaconViewController () <UITextViewDelegate, JAPlaceholderTextViewDelegate, JADatePickerDelegate, SelectLocationViewControllerDelegate, FindFriendsViewControllerDelegate>

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
@property (assign, nonatomic) BOOL didUpdateTime;
@property (assign, nonatomic) BOOL didUpdateLocation;
@property (assign, nonatomic) BOOL didUpdateDescription;

@end

@implementation SetBeaconViewController

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
    UITapGestureRecognizer *descriptionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionTouched:)];
    descriptionTap.numberOfTapsRequired = 1;
    [self.descriptionContainerView addGestureRecognizer:descriptionTap];
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
    JAInsetLabel *selectFriendsLabel = [[JAInsetLabel alloc] initWithFrame:self.setBeaconButton.bounds];
    selectFriendsLabel.edgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    selectFriendsLabel.text = @"Select Friends";
    selectFriendsLabel.font = [ThemeManager regularFontOfSize:15];
    selectFriendsLabel.textColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    [self.setBeaconButton addSubview:selectFriendsLabel];
    self.setBeaconButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.setBeaconButton.titleLabel.font = [ThemeManager regularFontOfSize:15];
    self.setBeaconButton.backgroundColor = [UIColor colorWithRed:236/255.0 green:228/255.0 blue:216/255.0 alpha:1.0];
    [self.setBeaconButton addTarget:self action:@selector(setBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.setBeaconButton];
    
    [self.setBeaconButton setImage:[UIImage imageNamed:@"rightArrowBlue"] forState:UIControlStateNormal];
    self.setBeaconButton.imageEdgeInsets = UIEdgeInsetsMake(0, 270, 0, 0);
    
    self.datePicker = [[JADatePicker alloc] initWithFrame:CGRectMake(130, 0, 135, self.dateContainerView.frame.size.height)];
    self.datePicker.datePickerDelegate = self;
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
    [self updateCurrentLocationAddressFromLocation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)setBeaconCoordinate:(CLLocationCoordinate2D)beaconCoordinate
{
    _beaconCoordinate = beaconCoordinate;
    if (self.beacon) {
        CLLocation *originalLocation = [[CLLocation alloc] initWithLatitude:self.beacon.coordinate.latitude longitude:self.beacon.coordinate.longitude];
        CLLocation *updatedLocation = [[CLLocation alloc] initWithLatitude:self.beaconCoordinate.latitude longitude:self.beaconCoordinate.longitude];
        CLLocationDistance distance = [originalLocation distanceFromLocation:updatedLocation];
        if (distance > 10) {
            self.didUpdateLocation = YES;
        }
    }
}

- (void)setEditMode:(BOOL)editMode
{
    [self view];
    _editMode = editMode;
    if (editMode) {
        UIButton *deleteButton = [UIButton navButtonWithTitle:@"Delete"];
        [deleteButton addTarget:self action:@selector(deleteBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    }
    [self.setBeaconButton setTitle:@"Update Hotspot" forState:UIControlStateNormal];
}

- (void)setBeacon:(Beacon *)beacon
{
    [self view];
    _beacon = beacon;
    
    self.descriptionTextView.text = beacon.beaconDescription;
    self.locationLabel.text = beacon.address;
    self.datePicker.date = beacon.time;
    self.useCurrentLocation = NO;
    self.beaconCoordinate = self.beacon.coordinate;
}

- (void)scrollToShowSetBeaconButton
{
    //scroll to show invite button for iPhone 4
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

- (void)cancelBeacon
{
    __weak typeof(self) weakSelf = self;
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[BeaconManager sharedManager] cancelBeacon:self.beacon success:^{
        [LoadingIndictor hideLoadingIndicatorForView:weakSelf.view animated:NO];
        if ([weakSelf.delegate respondsToSelector:@selector(setBeaconViewController:didCancelBeacon:)]) {
            [weakSelf.delegate setBeaconViewController:weakSelf didCancelBeacon:weakSelf.beacon];
        }
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}


- (void)updateCharacterCountLabel
{
    self.characterCountLabel.hidden = self.descriptionTextView.text.length < 20;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d/%d characters", self.descriptionTextView.text.length, MAX_CHARACTER_COUNT];
    self.characterCountLabel.textColor = self.descriptionTextView.text.length == MAX_CHARACTER_COUNT ? [UIColor whiteColor] : [[UIColor whiteColor] colorWithAlphaComponent:0.7];
}

- (void)descriptionTouched:(id)sender
{
    [self.descriptionTextView becomeFirstResponder];
}

- (void)locationTouched:(id)sender
{
    SelectLocationViewController *selectLocationViewController = [SelectLocationViewController new];
    selectLocationViewController.delegate = self;
    [self.navigationController pushViewController:selectLocationViewController animated:YES];
}

- (void)deleteBeaconButtonTouched:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete this Hotspot?" message:@"Are you sure you want to delete this Hotspot? This cannot be undone."];
    [alertView addButtonWithTitle:@"Yes" handler:^{
        [self cancelBeacon];
    }];
    [alertView setCancelButtonWithTitle:@"No" handler:nil];
    [alertView show];
}

- (void)setBeaconButtonTouched:(id)sender
{
    if (self.editMode) {
        [self updateBeacon];
        return;
    }
    
    if (!self.descriptionTextView.text || !self.descriptionTextView.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Baby, you're going too fast!" message:@"Don't forget to set a Hotspot description" delegate:nil cancelButtonTitle:@"I'll slow down" otherButtonTitles:nil] show];
        return;
    }
    
    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
    if (contactAuthStatus == kABAuthorizationStatusDenied) {
        LockedViewController *lockedViewController = [[LockedViewController alloc] init];
        [self.navigationController presentViewController:lockedViewController animated:YES completion:nil];
        return;
    }
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
    findFriendsViewController.autoCheckSuggested = NO;
    findFriendsViewController.delegate = self;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (void)updateBeacon
{
    [self.descriptionTextView resignFirstResponder];
    
    NSString *beaconDescription = self.descriptionTextView.text;
    
    BOOL timeUpdated = self.didUpdateTime;
    NSDate *beaconTime = timeUpdated ? [self dateForBeacon] : self.beacon.time;
    
    self.beacon.beaconDescription = beaconDescription;
    self.beacon.time = beaconTime;
    self.beacon.address = [self.locationLabel.text isEqualToString:@"Current Location"] ? self.currentLocationAddress : self.locationLabel.text;
    self.beacon.coordinate = self.beaconCoordinate;
    if (self.didUpdateLocation || self.didUpdateTime || self.didUpdateDescription) {
        __weak typeof(self) weakSelf = self;
        [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
        [[BeaconManager sharedManager] updateBeacon:self.beacon success:^(Beacon *updatedBeacon) {
            [LoadingIndictor hideLoadingIndicatorForView:weakSelf.view animated:NO];
            if ([weakSelf.delegate respondsToSelector:@selector(setBeaconViewController:didUpdateBeacon:)]) {
                [weakSelf.delegate setBeaconViewController:weakSelf didUpdateBeacon:updatedBeacon];
            }
        } failure:^(NSError *error) {
            [LoadingIndictor hideLoadingIndicatorForView:weakSelf.view animated:NO];
            [[[UIAlertView alloc] initWithTitle:@"Sorry" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(setBeaconViewController:didUpdateBeacon:)]) {
            [self.delegate setBeaconViewController:self didUpdateBeacon:self.beacon];
        }
    }
}

- (void)updateCurrentLocationAddressFromLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.beaconCoordinate.latitude longitude:self.beaconCoordinate.longitude];
    [Utilities reverseGeoCodeLocation:location completion:^(NSString *addressString, NSError *error) {
        self.currentLocationAddress = addressString;
    }];
}

- (void)didUpdateLocation:(NSNotification *)notification
{
    CLLocation *location = notification.userInfo[@"location"];
    if (self.useCurrentLocation) {
        self.beaconCoordinate = location.coordinate;
        [self updateCurrentLocationAddressFromLocation];
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

    //if time is less than x min in the past, set for next day
    if (intervalUntilBeacon < -15*60) {
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
    [self scrollToShowSetBeaconButton];
}

- (void)didSelectCurrentLocation
{
    self.useCurrentLocation = YES;
    self.locationLabel.text = @"Current Location";
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
    [self scrollToShowSetBeaconButton];
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
    [self scrollToShowSetBeaconButton];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        [self scrollToShowSetBeaconButton];
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
    if (self.beacon) {
        self.didUpdateDescription = ![textView.text isEqualToString:self.beacon.beaconDescription];
    }
    
    [self updateCharacterCountLabel];
}


#pragma mark - FindFriendsViewControllerDelegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
{
    [self setBeaconOnServerWithInvitedContacts:contacts];
}

#pragma mark - JADatePickerDelegate
- (void)userDidUpdateDatePicker:(JADatePicker *)datePicker
{
    self.didUpdateTime = YES;
    [self scrollToShowSetBeaconButton];
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
    MRProgressOverlayView *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
    __weak typeof(self) weakSelf = self;
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
        [[AnalyticsManager sharedManager] createBeaconWithDescription:beacon.beaconDescription location:weakSelf.locationLabel.text date:beacon.time numInvites:beacon.guestStatuses.count];
    } failure:^(NSError *error) {
        [loadingIndicator hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

@end
