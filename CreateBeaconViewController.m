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
@end

@implementation CreateBeaconViewController

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
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeTouched:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.timeValueLabel addGestureRecognizer:tapGestureRecognizer];
    self.timeValueLabel.userInteractionEnabled = YES;
    
}

- (void)locationTouched:(id)sender
{
    SelectLocationViewController *selectLocationViewController = [SelectLocationViewController new];
    selectLocationViewController.delegate = self;
    [self.navigationController presentViewController:selectLocationViewController animated:YES completion:nil];
}

- (void)timeTouched:(id)sender
{
    self.datePicker = [[UIDatePicker alloc] init];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.view.frame.size.width, 150);
    frame.origin = CGPointMake(0, self.view.frame.size.height - frame.size.height);
    self.datePicker.frame = frame;
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    UIView *datePickerHeader = [[UIView alloc] init];
    frame = CGRectZero;
    frame.size = CGSizeMake(self.datePicker.frame.size.width, 30);
    frame.origin.y = -frame.size.height;
    datePickerHeader.frame = frame;
    datePickerHeader.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.datePicker addSubview:datePickerHeader];
    UIButton *datePickerDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    datePickerDoneButton.frame = CGRectMake(100, 0, 50, datePickerHeader.frame.size.height);
    [datePickerDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [datePickerHeader addSubview:datePickerDoneButton];
    [self.view addSubview:self.datePicker];
    [self showDatePicker];
}

- (void)showDatePicker
{
    self.datePicker.alpha = 0;
    self.datePicker.transform = CGAffineTransformMakeTranslation(0, self.datePicker.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.datePicker.transform = CGAffineTransformIdentity;
        self.datePicker.alpha = 1.0;
    }];
}

- (void)hideDatePicker
{
    
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
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
