//
//  createBeaconViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/6/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "CreateBeaconViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Facebook-iOS-SDK/FacebookSDK/FBPlacePickerViewController.h>
#import "SelectLocationViewController.h"
#import "LocationTracker.h"


static NSString * const kBeaconDescriptionPlaceholder = @"enter beacon description";

@interface CreateBeaconViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *beaconDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *postBeaconButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *locationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeValueLabel;
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
    
    
	UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationTouched:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	[self.locationValueLabel addGestureRecognizer:tapGestureRecognizer];
    self.locationValueLabel.userInteractionEnabled = YES;
    
}

- (void)locationTouched:(id)sender
{
    CLLocation *location = [LocationTracker sharedTracker].locationManager.location;
    FBPlacePickerViewController *placePickerViewController = [[FBPlacePickerViewController alloc]
                                  initWithNibName:nil bundle:nil];
    placePickerViewController.locationCoordinate = location.coordinate;
    placePickerViewController.radiusInMeters = 1000;
    placePickerViewController.resultsLimit = 50;
    placePickerViewController.searchText = @"restaurant";
    [placePickerViewController loadData];
    [self.navigationController pushViewController:placePickerViewController animated:YES];
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

@end
