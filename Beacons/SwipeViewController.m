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
#import "User.h"

@interface SwipeViewController ()

@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *headerExplanationText;
@property (strong, nonatomic) UIView *setupView;
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UIView *queueView;
@property (strong, nonatomic) UIView *blackBackground;
@property (strong, nonatomic) UISegmentedControl *userGender;
@property (strong, nonatomic) UISegmentedControl *userPreference;
@property (strong, nonatomic) UIImageView *profilePicture;
@property (strong, nonatomic) UILabel *changePicture;
@property (strong, nonatomic) NSURL *profilePictureImageUrl;
@property (assign, nonatomic) BOOL *pictureAdded;
@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) UIScrollView *matchesView;
@property (strong, nonatomic) MDCSwipeToChooseViewOptions *options;
@property (strong, nonatomic) DatingProfile *datingProfile;
@property (strong, nonatomic) NSArray *datingQueue;

@end

@implementation SwipeViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.datingQueue = [[NSArray alloc] init];
    self.matches = [[NSArray alloc] init];
    
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
    
    self.queueView = [[UIView alloc] initWithFrame:self.view.frame];
    self.queueView.backgroundColor = [UIColor clearColor];
    [self.mainView addSubview:self.queueView];
    
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
    
    self.blackBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 175, 200, 25)];
    self.blackBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.blackBackground.hidden = YES;
    [self.profilePicture addSubview:self.blackBackground];
    
    self.changePicture = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.changePicture.font = [ThemeManager boldFontOfSize:10];
    self.changePicture.textColor = [UIColor whiteColor];
    self.changePicture.text = @"CHANGE PICTURE";
    self.changePicture.textAlignment = NSTextAlignmentCenter;
    [self.blackBackground addSubview:self.changePicture];
    
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
    self.options.delegate = self;
    self.options.likedColor = [[ThemeManager sharedTheme] greenColor];
    self.options.nopeColor = [[ThemeManager sharedTheme] redColor];
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
    
    self.matchesView= [[UIScrollView alloc] init];
    self.matchesView.frame=CGRectMake(0, 336, self.view.frame.size.width, 94);
    self.matchesView.delegate = self;
    self.matchesView.backgroundColor = [UIColor whiteColor];
    self.matchesView.scrollEnabled = YES;
    self.matchesView.showsHorizontalScrollIndicator = NO;
    [self.mainView addSubview:self.matchesView];
    
    [self.matchesView setUserInteractionEnabled:YES];
    [self.mainView addGestureRecognizer:self.matchesView.panGestureRecognizer];
}

-(void) loadSwipeView
{
    [[APIClient sharedClient] getDatingData:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *datingProfile = responseObject[@"dating_profile"];
        if ([datingProfile count] == 0) {
            self.datingProfile = nil;
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
            
            NSMutableArray *matchesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *datingProfileJSON in responseObject[@"matches"]) {
                DatingProfile *datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfileJSON];
                [matchesArray addObject:datingProfile];
            }
            self.matches = matchesArray;
            [self loadMatches];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED");
    }];
}

-(void)loadMatches
{
    int count = 0;
    [self.matchesView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for(int index=0; index < 4 || index < self.matches.count; index++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.5 + (count * 75), 10 , 70, 70)];
        imageView.layer.cornerRadius = 35;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.tag = index;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(matchTapped:)];
        [imageView addGestureRecognizer:singleFingerTap];
        if (index < self.matches.count) {
            DatingProfile *datingProfile = self.matches[index];
            [imageView sd_setImageWithURL:datingProfile.imageURL];
        } else {
            imageView.image = [UIImage imageNamed:@"blankMatch"];
        }
        
        [self.matchesView addSubview:imageView];
        
        count += 1;
    }
    
    self.matchesView.contentSize = CGSizeMake(80 * count, 80);
}

-(void) matchTapped:(id)sender
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
    if (tapRecognizer.view.tag < self.matches.count) {
        DatingProfile *datingProfile = self.matches[tapRecognizer.view.tag];
        NSString *message = [NSString stringWithFormat:@"You've matched with %@. So you know be social and when you see them, make sure to say hi.", datingProfile.user.fullName];
        [[[UIAlertView alloc] initWithTitle:@"Matched!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void) loadDatingProfilesInMainView
{
    [self.queueView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (DatingProfile *profile in self.datingQueue) {
        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:CGRectMake(30, 30, self.view.width - 60, self.view.width - 60) options:self.options];
        view.tag = [profile.datingProfileID integerValue];
        [view.imageView sd_setImageWithURL:profile.imageURL];
        [self.queueView addSubview:view];
    }
}

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Couldn't decide, huh?");
}

// Sent before a choice is made. Cancel the choice by returning `NO`. Otherwise return `YES`.
- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
//    if (direction == MDCSwipeDirectionLeft) {
//        return YES;
//    } else {
//        // Snap the view back and cancel the choice.
//        [UIView animateWithDuration:0.16 animations:^{
//            view.transform = CGAffineTransformIdentity;
//            view.center = [view superview].center;
//        }];
//        return NO;
//    }
    return YES;
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    NSNumber *datingProfileID = [NSNumber numberWithInteger:view.tag];
    if (direction == MDCSwipeDirectionLeft) {
        [self swipeComplete:datingProfileID withSelection:NO];
    } else {
        [self swipeComplete:datingProfileID withSelection:YES];
    }
}

-(void)reloadMatches
{
    [[APIClient sharedClient] getDatingData:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableArray *matchesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *datingProfileJSON in responseObject[@"matches"]) {
                DatingProfile *datingProfile = [[DatingProfile alloc] initWithDictionary:datingProfileJSON];
                [matchesArray addObject:datingProfile];
            }
            self.matches = matchesArray;
            [self loadMatches];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED");
    }];
}

-(void)swipeComplete:(NSNumber *)datingProfileID withSelection:(BOOL)isSelected
{
    [[APIClient sharedClient] swipeComplete:datingProfileID withSelection:isSelected forEvent:self.sponsoredEvent.eventID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (isSelected) {
            if (![responseObject[@"dating_profile_match"] isEmpty]) {
                NSDictionary *datingProfile = responseObject[@"dating_profile_match"][0];
                DatingProfile *profile = [[DatingProfile alloc] initWithDictionary:datingProfile];
                NSString *message = [NSString stringWithFormat:@"You've matched with %@. So you know be social and when you see them, make sure to say hi.", profile.user.fullName];
                [[[UIAlertView alloc] initWithTitle:@"Matched!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [self reloadMatches];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
    }];
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

-(void) updateUserGenderInSetupView
{
    if ([self.datingProfile.userGender isEqualToString:@"M" ]) {
        [self.userGender setSelectedSegmentIndex:0];
    } else if ([self.datingProfile.userGender isEqualToString:@"F"]) {
        [self.userGender setSelectedSegmentIndex:1];
    }
}

-(void) updateUserPreferenceInSetupView
{
    if ([self.datingProfile.userPreference isEqualToString:@"M" ]) {
        [self.userPreference setSelectedSegmentIndex:0];
    } else if ([self.datingProfile.userPreference isEqualToString:@"F"]) {
        [self.userPreference setSelectedSegmentIndex:1];
    }
}

-(void) loadDatingProfileInSetupView
{
    [self updateUserGenderInSetupView];
    [self updateUserPreferenceInSetupView];
    self.profilePictureImageUrl = self.datingProfile.imageURL;
    [self showPictureInView];
}

- (void)saveButtonTouched:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLoadingForEvent object:self userInfo:nil];
    NSLog(@"IMAGE URL: %@", self.profilePictureImageUrl);
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kEndLoadingForEvent object:self userInfo:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEndLoadingForEvent object:self userInfo:nil];
            NSLog(@"FAILED");
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEndLoadingForEvent object:self userInfo:nil];
        [[[UIAlertView alloc] initWithTitle:@"Profile Incomplete" message:@"Please ensure you've selected your gender, preference, and added an image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)cameraButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Do you want to take a photo or add one from your library?"];
    [actionSheet bk_addButtonWithTitle:@"Take a Selfie" handler:^{
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
            NSString *imageName = [self randomStringWithLength:10];
            [[APIClient sharedClient] postImage:finalImage withImageName:imageName success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.profilePictureImageUrl = [NSURL URLWithString:responseObject[@"image_url"]];
                [self showPictureInView];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed");
            }];
        }
    }];
}

-(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void) showPictureInView
{
    self.blackBackground.hidden = NO;
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
                      duration:0.4
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
    
    [self loadSwipeView];
}

@end

