//
//  VoucherViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 3/16/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwipeViewController.h"
#import "APIClient.h"
#import "SponsoredEvent.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoManager.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "DatingProfile.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@interface SwipeViewController ()

@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *headerExplanationText;
@property (strong, nonatomic) UIView *setupView;
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UISegmentedControl *userGender;
@property (strong, nonatomic) UISegmentedControl *userPreference;
@property (strong, nonatomic) UIImageView *profilePicture;
@property (strong, nonatomic) UIImageView *changePicture;
@property (strong, nonatomic) NSURL *profilePictureImageUrl;
@property (assign, nonatomic) BOOL *pictureAdded;
@property (strong, nonatomic) DatingProfile *datingProfile;
@property (strong, nonatomic) NSArray *datingQueue;
@property (strong, nonatomic) MDCSwipeToChooseViewOptions *options;

@end

@implementation SwipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.datingQueue = [[NSArray alloc] init];
    
    self.mainView = [[UIView alloc] initWithFrame:self.view.frame];
    self.mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainView];
    
    self.setupView = [[UIView alloc] initWithFrame:self.view.frame];
    self.setupView.backgroundColor = [UIColor whiteColor];
    self.setupView.hidden = YES;
    [self.view addSubview:self.setupView];
    
    self.headerTitle = [[UILabel alloc] init];
    self.headerTitle.height = 20;
    self.headerTitle.width = self.view.width;
    self.headerTitle.textAlignment = NSTextAlignmentCenter;
    self.headerTitle.font = [ThemeManager boldFontOfSize:14];
    self.headerTitle.y = 110;
    self.headerTitle.text = @"Check back soon!";
    [self.mainView addSubview:self.headerTitle];
    
    self.headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(50, 90, self.view.width - 100, 120)];
    self.headerExplanationText.font = [ThemeManager lightFontOfSize:13];
    self.headerExplanationText.textAlignment = NSTextAlignmentCenter;
    self.headerExplanationText.numberOfLines = 0;
    self.headerExplanationText.text = @"You're out of matches for now. Check back later to see more people!";
    [self.mainView addSubview:self.headerExplanationText];
    
    UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, self.view.width, 20)];
    genderLabel.textAlignment = NSTextAlignmentLeft;
    genderLabel.font = [ThemeManager mediumFontOfSize:12];
    genderLabel.text = @"Select your gender:";
    [self.setupView addSubview:genderLabel];
    
    self.userGender = [[UISegmentedControl alloc] initWithItems:@[@"MALE", @"FEMALE"]];
    [self.userGender setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor unnormalizedColorWithRed:112 green:112 blue:112 alpha:255], NSFontAttributeName : [ThemeManager boldFontOfSize:11]} forState:UIControlStateNormal];
//    [self.userGender setSelectedSegmentIndex:0];
    self.userGender.width = 280;
    self.userGender.height = 25;
    self.userGender.centerX = self.view.width/2;
    self.userGender.tintColor = [[ThemeManager sharedTheme] redColor];
    self.userGender.y = 35;
    [self.userGender addTarget:self
                        action:@selector(segmentedUserGenderControlSelectedIndexChanged:)
              forControlEvents:UIControlEventValueChanged];
    [self.setupView addSubview:self.userGender];
    
    UILabel *preferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 72, self.view.width, 20)];
    preferenceLabel.textAlignment = NSTextAlignmentLeft;
    preferenceLabel.font = [ThemeManager mediumFontOfSize:12];
    preferenceLabel.text = @"Show me:";
    [self.setupView addSubview:preferenceLabel];
    
    self.userPreference = [[UISegmentedControl alloc] initWithItems:@[@"MALES", @"FEMALES"]];
    [self.userPreference setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor unnormalizedColorWithRed:112 green:112 blue:112 alpha:255], NSFontAttributeName : [ThemeManager boldFontOfSize:11]} forState:UIControlStateNormal];
//[self.userPreference setSelectedSegmentIndex:0];
    self.userPreference.width = 280;
    self.userPreference.height = 25;
    self.userPreference.centerX = self.view.width/2;
    self.userPreference.tintColor = [[ThemeManager sharedTheme] redColor];
    self.userPreference.y = 95;
    [self.userPreference addTarget:self
                        action:@selector(segmentedUserPreferenceControlSelectedIndexChanged:)
              forControlEvents:UIControlEventValueChanged];
    [self.setupView addSubview:self.userPreference];
    
    self.profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 145, 200, 200)];
    self.profilePicture.centerX = self.view.width/2.0;
    self.profilePicture.layer.cornerRadius = 4;
    self.profilePicture.layer.borderColor = [UIColor unnormalizedColorWithRed:125 green:125 blue:125 alpha:255].CGColor;
    self.profilePicture.layer.borderWidth = 1;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.userInteractionEnabled = YES;
//    self.profilePicture.backgroundColor = [UIColor unnormalizedColorWithRed:215 green:215 blue:215 alpha:255];
    [self.profilePicture setImage:[UIImage imageNamed:@"takePictureButtonLarge"]];
    [self.setupView addSubview:self.profilePicture];
    
    self.changePicture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takePictureButtonSmall"]];
    self.changePicture.y = 5;
    self.changePicture.x = 160;
    self.changePicture.hidden = YES;
    [self.profilePicture addSubview:self.changePicture];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonTouched:)];
    [self.profilePicture addGestureRecognizer:tap];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.size = CGSizeMake(self.view.width - 40, 35);
    saveButton.centerX = self.view.width/2.0;
    saveButton.y = 375;
    saveButton.layer.cornerRadius = 4;
    saveButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [saveButton setTitle:@"SAVE" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [saveButton addTarget:self action:@selector(saveButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.setupView addSubview:saveButton];
    
    self.options = [MDCSwipeToChooseViewOptions new];
    self.options.likedText = @"LIKE";
    self.options.likedColor = [[ThemeManager sharedTheme] redColor];
    self.options.nopeColor = [[ThemeManager sharedTheme] lightBlueColor];
    self.options.nopeText = @"NOPE";
    self.options.onPan = ^(MDCPanState *state){
        if (state.thresholdRatio == 1.f && state.direction == MDCSwipeDirectionLeft) {
            NSLog(@"Let go now to delete the photo!");
        }
    };
    
    UILabel *matchHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 315, self.view.width, 20)];
    matchHeader.textAlignment = NSTextAlignmentLeft;
    matchHeader.font = [ThemeManager boldFontOfSize:12];
    matchHeader.text = @"Matches";
    [self.mainView addSubview:matchHeader];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 335, self.view.width, 1)];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:205 green:205 blue:205 alpha:255];
    [self.mainView addSubview:topBorder];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.size = CGSizeMake(30, 30);
    settingsButton.x = self.view.width - 40;
    settingsButton.y = 307;
    [settingsButton setImage:[UIImage imageNamed:@"settingsButton"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:settingsButton];
}

-(void) loadDatingProfilesInMainView
{
    for (DatingProfile *profile in self.datingQueue) {
        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:CGRectMake(30, 30, self.view.width - 60, self.view.width - 60) options:self.options];
        NSData *imageData = [NSData dataWithContentsOfURL:profile.imageURL];
        view.imageView.image = [UIImage imageWithData:imageData];
        [self.mainView addSubview:view];
    }
}

#pragma mark - MDCSwipeToChooseDelegate Callbacks

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Couldn't decide, huh?");
}

// Sent before a choice is made. Cancel the choice by returning `NO`. Otherwise return `YES`.
- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft) {
        return YES;
    } else {
        // Snap the view back and cancel the choice.
        [UIView animateWithDuration:0.16 animations:^{
            view.transform = CGAffineTransformIdentity;
            view.center = [view superview].center;
        }];
        return NO;
    }
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"Photo deleted!");
    } else {
        NSLog(@"Photo saved!");
    }
}

-(NSString *)getValueFromIndex:(NSInteger)index
{
    if (index == 0) {
        return @"M";
    } else if (index == 1) {
        return @"F";
    } else {
        return nil;
    }
}

-(void) loadDatingProfileInSetupView
{
    self.profilePictureImageUrl = self.datingProfile.imageURL;
    [self showPictureInView];
}

- (void)saveButtonTouched:(id)sender
{
    NSString *userGender = [self getValueFromIndex:self.userGender.selectedSegmentIndex];
    NSString *userPreference = [self getValueFromIndex:self.userPreference.selectedSegmentIndex];
    if (self.profilePictureImageUrl && userGender && userPreference) {
        [[APIClient sharedClient] postDatingProfile:[self.profilePictureImageUrl absoluteString] andGender:userGender andPreference:userPreference andEventID:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *datingProfile = responseObject[@"dating_profile"][0];
            self.datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfile];
            NSMutableArray *datingQueueArray = [[NSMutableArray alloc] init];
            for (NSDictionary *datingProfileJSON in responseObject[@"dating_queue"]) {
                DatingProfile *datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfileJSON];
                [datingQueueArray addObject:datingProfile];
            }
            self.datingQueue = datingQueueArray;
            [self loadAndShowMainView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"FAILED");
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Profile Incomplete" message:@"Please ensure you've selected your gender, preference, and added an image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)cameraButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Do you want to take a photo or add one from your library?"];
    [actionSheet bk_addButtonWithTitle:@"Take a (Sexy) Selfie" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet bk_addButtonWithTitle:@"Add From Library" handler:^{
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)source
{
    [[PhotoManager sharedManager] presentImagePickerForSourceTypeFrontCamera:source fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        if (image) {
            UIImage *finalImage;
            if (source == UIImagePickerControllerSourceTypeCamera) {
                finalImage = [UIImage imageWithCGImage:image.CGImage
                                                     scale:image.scale
                                               orientation:UIImageOrientationUpMirrored];
            } else {
                finalImage = image;
            }
            [[APIClient sharedClient] postImage:finalImage withImageName:@"user_picture" success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.profilePictureImageUrl = [NSURL URLWithString:responseObject[@"image_url"]];
                [self showPictureInView];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed");
            }];
        }
    }];
}

-(void) showPictureInView
{
    self.changePicture.hidden = NO;
    [self.profilePicture sd_setImageWithURL:self.profilePictureImageUrl];
}

- (void)segmentedUserGenderControlSelectedIndexChanged:(id)sender {
//    [self computeTotalAndUpdateText];
}

- (void)segmentedUserPreferenceControlSelectedIndexChanged:(id)sender {
    //    [self computeTotalAndUpdateText];
}

-(void) settingsButtonTouched:(id)sender
{
    [self loadAndShowSetupView];
}

-(void)loadAndShowSetupView
{
    [UIView transitionWithView:self.setupView
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.setupView.hidden = NO;
}

-(void)loadAndShowMainView
{
    [self loadDatingProfilesInMainView];
    [UIView transitionWithView:self.setupView
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.setupView.hidden = YES;
}

-(void)setSponsoredEvent:(SponsoredEvent *)sponsoredEvent
{
    _sponsoredEvent = sponsoredEvent;
    
    [[APIClient sharedClient] getDatingData:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"dating_profile"] isEmpty]) {
            [self loadAndShowSetupView];
        } else {
            NSDictionary *datingProfile = responseObject[@"dating_profile"][0];
            self.datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfile];
            [self loadDatingProfileInSetupView];
            NSMutableArray *datingQueueArray = [[NSMutableArray alloc] init];
            for (NSDictionary *datingProfileJSON in responseObject[@"dating_queue"]) {
                DatingProfile *datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfileJSON];
                [datingQueueArray addObject:datingProfile];
            }
            self.datingQueue = datingQueueArray;
            [self loadAndShowMainView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED");
    }];
}

@end

