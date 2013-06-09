//
//  createBeaconViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/6/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CreateBeaconViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Foursquare-iOS-API/BZFoursquare.h>
#import "SelectLocationViewController.h"
#import "LocationTracker.h"
#import "FourSquareAPIClient.h"
#import "Venue.h"


static NSString * const kBeaconDescriptionPlaceholder = @"enter beacon description";

@interface CreateBeaconViewController () <UITextViewDelegate, SelectLocationViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *beaconDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *postBeaconButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *locationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeValueLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIView *datePickerContainerView;
@property (strong, nonatomic) NSDate *selectedDate;
@end

@implementation CreateBeaconViewController

- (NSDate *)selectedDate
{
    if (!_selectedDate) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
}

- (void)locationTouched:(id)sender
{
    SelectLocationViewController *selectLocationViewController = [SelectLocationViewController new];
    selectLocationViewController.delegate = self;
    [self.navigationController presentViewController:selectLocationViewController animated:YES completion:nil];
}

- (void)timeTouched:(id)sender
{
    CGRect frame = CGRectZero;
    UIView *datePickerHeader = [[UIView alloc] init];
    frame.size = CGSizeMake(self.view.frame.size.width, 30);
    datePickerHeader.frame = frame;
    datePickerHeader.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];

    
    UIButton *datePickerDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    datePickerDoneButton.frame = CGRectMake(100, 0, 50, datePickerHeader.frame.size.height);
    [datePickerDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [datePickerDoneButton addTarget:self action:@selector(timePickerDoneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [datePickerHeader addSubview:datePickerDoneButton];
    
    self.datePicker = [[UIDatePicker alloc] init];
    frame = CGRectZero;
    frame.size = CGSizeMake(self.view.frame.size.width, 150);
    frame.origin.y = datePickerHeader.frame.size.height;
    self.datePicker.frame = frame;
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.datePicker addTarget:self
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    self.datePicker.date = [NSDate date];
    
    self.datePickerContainerView = [[UIView alloc] init];
    frame.size.width = self.datePicker.frame.size.width;
    frame.size.height = self.datePicker.frame.size.height + datePickerHeader.frame.size.height;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.datePickerContainerView.frame = frame;
    [self.datePickerContainerView addSubview:self.datePicker];
    [self.datePickerContainerView addSubview:datePickerHeader];
    
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
    self.selectedDate = datePicker.date;
    [self updateDateValue];
}

- (void)timePickerDoneButtonTouched:(id)sender
{
    [self hideDatePicker];
}

- (void)updateDateValue
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];

    NSString *dateString = [formatter stringFromDate:self.selectedDate];
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
    self.locationValueLabel.text = venue.name;
}

- (void)didSelectCurrentLocation
{
    self.locationValueLabel.text = @"Current Location";
}


@end
