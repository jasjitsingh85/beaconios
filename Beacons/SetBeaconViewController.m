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
#import "ExplanationPopupView.h"
#import "DatePickerModalView.h"

#define MAX_CHARACTER_COUNT 40

@interface SetBeaconViewController () <UITextViewDelegate, JAPlaceholderTextViewDelegate, JADatePickerDelegate, SelectLocationViewControllerDelegate, FindFriendsViewControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *descriptionContainerView;
@property (strong, nonatomic) UIView *dateContainerView;
@property (strong, nonatomic) UIView *locationContainerView;
@property (strong, nonatomic) UILabel *characterCountLabel;
@property (strong, nonatomic) JAPlaceholderTextView *descriptionTextView;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UILabel *dateLabel;
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
    
    self.descriptionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 208)];
    self.descriptionContainerView.backgroundColor = [UIColor colorWithRed:234/255.0 green:109/255.0 blue:90/255.0 alpha:1.0];
    UITapGestureRecognizer *descriptionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionTouched:)];
    descriptionTap.numberOfTapsRequired = 1;
    [self.descriptionContainerView addGestureRecognizer:descriptionTap];
    [self.scrollView addSubview:self.descriptionContainerView];
    
    self.dateContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.descriptionContainerView.frame), self.view.frame.size.width, 126)];
    self.dateContainerView.backgroundColor = [UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0];
    UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateTouched:)];
    dateTap.numberOfTapsRequired = 1;
    [self.dateContainerView addGestureRecognizer:dateTap];
    [self.scrollView addSubview:self.dateContainerView];
    
    self.locationContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dateContainerView.frame), self.view.frame.size.width, 126)];
    self.locationContainerView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationTouched:)];
    locationTap.numberOfTapsRequired =1;
    [self.locationContainerView addGestureRecognizer:locationTap];
    [self.scrollView addSubview:self.locationContainerView];
    
    self.setBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.locationContainerView.frame), self.view.frame.size.width, 44)];
    [self.setBeaconButton setTitle:@"Select Friends" forState:UIControlStateNormal];
    [self.setBeaconButton setTitleColor:[UIColor colorWithRed:119/255.0 green:182/255.0 blue:199/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.setBeaconButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.setBeaconButton.titleLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    self.setBeaconButton.backgroundColor = [UIColor colorWithRed:236/255.0 green:228/255.0 blue:216/255.0 alpha:1.0];
    [self.setBeaconButton addTarget:self action:@selector(setBeaconButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.setBeaconButton];
    
    UIImage *arrowImage = [UIImage imageNamed:@"rightArrowBlue"];
    [self.setBeaconButton setImage:arrowImage forState:UIControlStateNormal];
    self.setBeaconButton.imageEdgeInsets = UIEdgeInsetsMake(0, 270, 0, 0);
    self.setBeaconButton.titleEdgeInsets = UIEdgeInsetsMake(0, -arrowImage.size.width + 51, 0, 0);
    
    UILabel *descriptionSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 70, 150, 19)];
    descriptionSectionLabel.text = @"What's going on?";
    descriptionSectionLabel.textColor = [UIColor whiteColor];
    descriptionSectionLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    [self.descriptionContainerView addSubview:descriptionSectionLabel];
    
    self.characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(212, 71, 100, 17)];
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d/%d characters",0, MAX_CHARACTER_COUNT];
    self.characterCountLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.characterCountLabel.font = [ThemeManager regularFontOfSize:10];
    self.characterCountLabel.hidden = YES;
    [self.descriptionContainerView addSubview:self.characterCountLabel];
    
    UILabel *dateSectionLabel = [[UILabel alloc] init];
    dateSectionLabel.text = @"When?";
    dateSectionLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    dateSectionLabel.textColor = [UIColor whiteColor];
    CGRect dateSectionLabelFrame;
    dateSectionLabelFrame.size = [dateSectionLabel.text sizeWithAttributes:@{NSFontAttributeName : dateSectionLabel.font}];
    dateSectionLabelFrame.origin.x = 51;
    dateSectionLabelFrame.origin.y = 40;
    dateSectionLabel.frame = dateSectionLabelFrame;
    [self.dateContainerView addSubview:dateSectionLabel];
    
    UILabel *locationDescriptionLabel = [[UILabel alloc] init];
    locationDescriptionLabel.text = @"Where?";
    locationDescriptionLabel.font = [ThemeManager lightFontOfSize:1.3*12];
    locationDescriptionLabel.textColor = [UIColor colorWithWhite:94/255.0 alpha:1.0];
    CGRect locationDescriptionLabelFrame;
    locationDescriptionLabelFrame.size = [locationDescriptionLabel.text sizeWithAttributes:@{NSFontAttributeName : locationDescriptionLabel.font}];
    locationDescriptionLabelFrame.origin.x = 51;
    locationDescriptionLabelFrame.origin.y = 40;
    locationDescriptionLabel.frame = locationDescriptionLabelFrame;
    [self.locationContainerView addSubview:locationDescriptionLabel];
    
    self.descriptionTextView = [[JAPlaceholderTextView alloc] initWithFrame:CGRectMake(51, 100, 240, 60)];
    //hide descriptiontextview while we wait to get placeholder strings from server
    self.descriptionTextView.placeholder = @"  ";
    self.descriptionTextView.alpha = 0;
    self.descriptionTextView.returnKeyType = UIReturnKeyDone;
    self.descriptionTextView.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.descriptionTextView.font = [ThemeManager lightFontOfSize:1.3*12];
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
    self.descriptionTextView.delegate = self;
    [self.descriptionContainerView addSubview:self.descriptionTextView];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [ThemeManager regularFontOfSize:15];
    self.dateLabel.textColor = [UIColor colorWithRed:195/255.0 green:221/255.0 blue:228/255.0 alpha:1.0];
    self.dateLabel.height = 18;
    self.dateLabel.x = 51;
    self.dateLabel.y = 64;
    self.dateLabel.width = self.view.width - self.dateLabel.x - 10;
    [self.dateContainerView addSubview:self.dateLabel];
    
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.font = [ThemeManager lightFontOfSize:15];
    self.locationLabel.textColor = [UIColor colorWithWhite:180/255.0 alpha:1.0];
    self.locationLabel.text = @"Current Location";
    CGRect locationLabelFrame;
    locationLabelFrame.origin.x = 51;
    locationLabelFrame.origin.y = 64;
    locationLabelFrame.size.height = [self.locationLabel.text sizeWithAttributes:@{NSFontAttributeName : self.locationLabel.font}].height;
    locationLabelFrame.size.width = self.view.width - locationLabelFrame.origin.x - 10;
    self.locationLabel.frame = locationLabelFrame;
    [self.locationContainerView addSubview:self.locationLabel];
    
    [self resetToEmpty];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kDidUpdateLocationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(randomStringsUpdated:) name:kRandomStringsUpdated object:nil];
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
    [self updateDescriptionPlaceholder];
}

- (void)willEnterForeground:(NSNotification *)notification
{
    [self view];
    if (self.date && self.date.timeIntervalSinceNow < -60*15) {
        [self resetToEmpty];
    }
}

- (void)resetToEmpty
{
    self.didUpdateDescription = NO;
    self.didUpdateLocation = NO;
    self.didUpdateTime = NO;
    self.descriptionTextView.text = nil;
    //round date to nearest 15 min
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate: now];
    NSInteger minutesToAdd = 15 - (comps.minute % 15);
    if (minutesToAdd) {
        self.date = [now dateByAddingTimeInterval:60*minutesToAdd];
    }
    else {
        self.date = now;
    }
    //by default set selected location as current location
    self.locationLabel.text = @"Current Location";
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
    self.useCurrentLocation = YES;
    [self updateCurrentLocationAddressFromLocation];
}


- (void)setDate:(NSDate *)date
{
    _date = date;
    self.dateLabel.text = date.fullFormattedDate;
}

- (void)updateDescriptionPlaceholder
{
    if (![RandomObjectManager sharedManager].hasUpdatedFromServer) {
        return;
    }
    else {
        NSString *placeholder = [[RandomObjectManager sharedManager] randomSetBeaconPlaceholder];
        self.descriptionPlaceholderText = [@"e.g. " stringByAppendingString:placeholder];
        self.descriptionTextView.placeholder = self.descriptionPlaceholderText;
    }
    if (!self.descriptionTextView.alpha) {
        [UIView animateWithDuration:0.3 animations:^{
            self.descriptionTextView.alpha = 1;
        }];
    }
}

- (void)randomStringsUpdated:(NSNotification *)notification
{
    [self updateDescriptionPlaceholder];
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
    self.date = beacon.time;
    self.useCurrentLocation = NO;
    self.beaconCoordinate = self.beacon.coordinate;
}

- (void)preloadWithRecommendation:(NSNumber *)recommendationID
{
    [self view];
    
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getPath:@"recommendation/" parameters:@{@"recommendation_id" : recommendationID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        Venue *venue = [[Venue alloc] initWithData:responseObject];
        if (venue.name) {
            self.locationLabel.text = venue.name;
        }
        else if (venue.address) {
            self.locationLabel.text = venue.address;
        }
        self.useCurrentLocation = NO;
        self.beaconCoordinate = venue.coordinate;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

- (void)preloadWithDescription:(NSString *)description venueName:(NSString *)venueName coordinate:(CLLocationCoordinate2D)coordinate
{
    [self view];
    self.descriptionTextView.text = description;
    self.locationLabel.text = venueName;
    self.useCurrentLocation = NO;
    self.beaconCoordinate = coordinate;
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
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d/%d characters", (int)self.descriptionTextView.text.length, MAX_CHARACTER_COUNT];
    self.characterCountLabel.textColor = self.descriptionTextView.text.length == MAX_CHARACTER_COUNT ? [UIColor whiteColor] : [[UIColor whiteColor] colorWithAlphaComponent:0.7];
}

- (void)descriptionTouched:(id)sender
{
    if (self.descriptionTextView.isFirstResponder) {
        [self.descriptionTextView resignFirstResponder];
    }
    else {
        [self.descriptionTextView becomeFirstResponder];
    }
}

- (void)dateTouched:(id)sender
{
    //don't do anything if other text field active
    if (self.descriptionTextView.isFirstResponder) {
        [self.descriptionTextView resignFirstResponder];
        return;
    }
    DatePickerModalView *datePicker = [[DatePickerModalView alloc] init];
    datePicker.datePicker.date = self.date;
    datePicker.datePicker.minuteInterval = 15;
    [datePicker.datePicker addTarget:self action:@selector(datePickerUpdated:) forControlEvents:UIControlEventValueChanged];
    [datePicker show];
}

- (void)locationTouched:(id)sender
{
    SelectLocationViewController *selectLocationViewController = [SelectLocationViewController new];
    selectLocationViewController.delegate = self;
    [self.navigationController pushViewController:selectLocationViewController animated:YES];
}

- (void)deleteBeaconButtonTouched:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Delete this Hotspot?" message:@"Are you sure you want to delete this Hotspot? This cannot be undone."];
    [alertView bk_addButtonWithTitle:@"Yes" handler:^{
        [self cancelBeacon];
    }];
    [alertView bk_setCancelButtonWithTitle:@"No" handler:nil];
    [alertView show];
}

- (void)datePickerUpdated:(UIDatePicker *)datePicker
{
    self.date = datePicker.date;
    self.didUpdateTime = YES;
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
    
//    can't set a hotspot far in the past
    if (self.date.timeIntervalSinceNow < -60*60*2) {
        [[[UIAlertView alloc] initWithTitle:@"Hello? Anybody home, McFly?" message:@"You can't set a Hotspot so far in the past" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    [self showExplanationPopup];
}

- (void)showExplanationPopup
{
    NSString *timeString = self.date.fullFormattedDate;
    ExplanationPopupView *explanationPopupView = [[ExplanationPopupView alloc] init];
    NSString *address = [self.locationLabel.text isEqualToString:@"Current Location"] ? self.currentLocationAddress : self.locationLabel.text;
    NSString *inviteText = [NSString stringWithFormat:@"%@: %@ \n%@ @ %@", [User loggedInUser].firstName, self.descriptionTextView.text, timeString, address];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:inviteText];
    [attributedText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[inviteText rangeOfString:address]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[inviteText rangeOfString:address]];
    explanationPopupView.attributedInviteText = attributedText;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasShownHotspotExplanation]) {
        [explanationPopupView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasShownHotspotExplanation];
    }
}

- (void)updateBeacon
{
    [self.descriptionTextView resignFirstResponder];
    
    NSString *beaconDescription = self.descriptionTextView.text;
    
    BOOL timeUpdated = self.didUpdateTime;
    NSDate *beaconTime = timeUpdated ? self.date : self.beacon.time;
    
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

- (void)didSelectToBeDetermined
{
    self.useCurrentLocation = YES;
    self.locationLabel.text = @"To Be Decided";
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
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
    //don't allow user to set hotspot if they didn't pick any contacts. (ignore in debug)
    BOOL shouldSetHotspot = ![contacts isEmpty];
#ifdef DEBUG
    shouldSetHotspot = YES;
#endif
    if (shouldSetHotspot) {
        [self setBeaconOnServerWithInvitedContacts:contacts];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Anti-social much?" message:@"Select friends to invite them to this Hotspot!" delegate:nil cancelButtonTitle:@"My bad" otherButtonTitles:nil] show];
    }
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
    beacon.time = self.date;
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
    __weak typeof(self) weakSelf = self;
    [[BeaconManager sharedManager] postBeacon:beacon success:^{
        [loadingIndicator hide:YES];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
        [[AnalyticsManager sharedManager] createBeaconWithDescription:beacon.beaconDescription location:weakSelf.locationLabel.text date:beacon.time numInvites:beacon.guestStatuses.count];
        
        [self resetToEmpty];
    } failure:^(NSError *error) {
        [loadingIndicator hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

@end
