//
//  createBeaconViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/6/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CreateBeaconViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <Foursquare-iOS-API/BZFoursquare.h>
#import "SelectLocationViewController.h"
#import "FindFriendsViewController.h"
#import "LocationTracker.h"
#import "FourSquareAPIClient.h"
#import "Venue.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "CenterNavigationController.h"
#import "MapViewController.h"
#import "Contact.h"

static NSString * const kBeaconDescriptionPlaceholder = @"Enter Beacon message";

@interface CreateBeaconViewController () <UITextViewDelegate, SelectLocationViewControllerDelegate, FindFriendsViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *beaconDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *postBeaconButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *locationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeValueLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIView *datePickerContainerView;
@property (strong, nonatomic) NSDate *beaconDate;
@property (assign, nonatomic) CLLocationCoordinate2D beaconCoordinate;
@property (strong, nonatomic) NSArray *contacts;
@property (assign, nonatomic) BOOL useCurrentLocation;
@property (assign, nonatomic) BOOL keyboardHidden;
@property (assign, nonatomic) BOOL makingServerCall;
@end

@implementation CreateBeaconViewController

- (NSDate *)beaconDate
{
    if (!_beaconDate) {
        _beaconDate = [NSDate date];
    }
    return _beaconDate;
}

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
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    self.beaconDescriptionTextView.layer.cornerRadius = 2;
    self.beaconDescriptionTextView.layer.borderWidth = 1;
    self.beaconDescriptionTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.beaconDescriptionTextView.returnKeyType = UIReturnKeyDone;
    self.beaconDescriptionTextView.delegate = self;
    self.beaconDescriptionTextView.text = kBeaconDescriptionPlaceholder;
    self.beaconDescriptionTextView.textColor = [UIColor lightGrayColor];
    
    self.containerView.layer.cornerRadius = 2;
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    self.locationValueLabel.adjustsFontSizeToFitWidth = YES;
	UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationTouched:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	[self.locationValueLabel addGestureRecognizer:tapGestureRecognizer];
    self.locationValueLabel.userInteractionEnabled = YES;
    self.locationValueLabel.text = @"Current Location";
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeTouched:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.timeValueLabel addGestureRecognizer:tapGestureRecognizer];
    self.timeValueLabel.userInteractionEnabled = YES;
    [self updateDateValue];
    
    //by default set selected location as current location
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
    self.useCurrentLocation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:kNotificationDidUpdateLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Create Beacon";
    [self.beaconDescriptionTextView becomeFirstResponder];
}

- (void)didUpdateLocation:(NSNotification *)notification
{
    CLLocation *location = notification.userInfo[@"location"];
    if (self.useCurrentLocation) {
        self.beaconCoordinate = location.coordinate;
    }
}

- (IBAction)nextButtonTouched:(id)sender
{
    FindFriendsViewController *findFriendsViewController = [FindFriendsViewController new];
    findFriendsViewController.delegate = self;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (void)locationTouched:(id)sender
{
    SelectLocationViewController *selectLocationViewController = [SelectLocationViewController new];
    selectLocationViewController.delegate = self;
    [self.navigationController presentViewController:selectLocationViewController animated:YES completion:nil];
}

- (void)timeTouched:(id)sender
{
    if (!self.keyboardHidden || (self.datePickerContainerView && self.datePickerContainerView.superview)) {
        return;
    }
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.view.frame.size.width, 30);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:frame];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *timeDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(timePickerDoneButtonTouched:)];
    toolBar.items = @[timeDoneButton];
    
    
    self.datePicker = [[UIDatePicker alloc] init];
    frame = CGRectZero;
    frame.size = CGSizeMake(self.view.frame.size.width, 150);
    frame.origin.y = toolBar.frame.size.height;
    self.datePicker.frame = frame;
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.datePicker addTarget:self
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    self.datePicker.minuteInterval = 30;
    self.datePicker.date = [NSDate date];
    
    self.datePickerContainerView = [[UIView alloc] init];
    frame.size.width = self.datePicker.frame.size.width;
    frame.size.height = self.datePicker.frame.size.height + toolBar.frame.size.height;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.datePickerContainerView.frame = frame;
    [self.datePickerContainerView addSubview:self.datePicker];
    [self.datePickerContainerView addSubview:toolBar];
    
    [self.view addSubview:self.datePickerContainerView];
    [self showDatePicker];
}

- (void)showDatePicker
{
    self.datePickerContainerView.alpha = 0;
    self.datePickerContainerView.transform = CGAffineTransformMakeTranslation(0, self.datePickerContainerView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerContainerView.transform = CGAffineTransformIdentity;
        self.datePickerContainerView.alpha = 1.0;
    }];
}

- (void)hideDatePicker
{
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerContainerView.transform = CGAffineTransformMakeTranslation(0, self.datePickerContainerView.frame.size.height);
        self.datePickerContainerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.datePickerContainerView removeFromSuperview];
    }];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    self.beaconDate = datePicker.date;
    [self updateDateValue];
}

- (void)timePickerDoneButtonTouched:(id)sender
{
    [self hideDatePicker];
}

- (void)updateDateValue
{
    NSString *dateString;
    //if beaconDate is within 1 minutes of current time just say now
    if (ABS([self.beaconDate timeIntervalSinceDate:[NSDate date]]) < 60*1) {
        dateString = @"Now";
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        dateString = [formatter stringFromDate:self.beaconDate];
    }
    
    self.timeValueLabel.text = dateString;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kBeaconDescriptionPlaceholder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    NSInteger maxLength = 100;
    if (textView.text.length > maxLength) {
        return NO;
    }
    return YES;
}

#pragma mark - SelectLocationViewControllerDelegate
- (void)didSelectVenue:(Venue *)venue
{
    self.useCurrentLocation = NO;
    self.locationValueLabel.text = venue.name;
    self.beaconCoordinate = venue.coordinate;
}

- (void)didSelectCurrentLocation
{
    self.useCurrentLocation = YES;
    self.locationValueLabel.text = @"Current Location";
    self.beaconCoordinate = [LocationTracker sharedTracker].currentLocation.coordinate;
}

#pragma mark - FindFriendsViewControllerDelegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
{
    if (!self.makingServerCall) {
        self.contacts = contacts;
        [self setBeaconOnServer];
    }
}

#pragma mark - Networking
- (void)setBeaconOnServer
{
    NSString *beaconDescription = [self.beaconDescriptionTextView.text isEqualToString:kBeaconDescriptionPlaceholder] ? @"" : self.beaconDescriptionTextView.text;
    
    NSMutableArray *invites = [NSMutableArray new];
    for (Contact *contact in self.contacts) {
        NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
        [invites addObject:contactString];
    }
    
    self.makingServerCall = YES;
    NSDictionary *parameters = @{@"description" : beaconDescription,
                                 @"time" : @(self.beaconDate.timeIntervalSince1970),
                                 @"latitude" : @(self.beaconCoordinate.latitude),
                                 @"longitude" : @(self.beaconCoordinate.longitude),
                                 @"invite" : invites};
    [[APIClient sharedClient] postPath:@"beacon/me/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   [[[UIAlertView alloc] initWithTitle:@"Nice!" message:@"You successfully posted a Beacon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                                   [appDelegate.centerNavigationController setSelectedViewController:appDelegate.mapViewController animated:YES];
                                   self.makingServerCall = NO;
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   self.makingServerCall = NO;
                               }];
}

#pragma mark - keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardHidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardHidden = YES;
}

@end
