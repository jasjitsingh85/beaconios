//
//  SetDealViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 8/7/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "SetDealViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+FormattedDate.h"
#import "UIView+Shadow.h"
#import "DatePickerModalView.h"
#import "Deal.h"
#import "Venue.h"
#import "User.h"
#import "APIClient.h"
#import "FindFriendsViewController.h"
#import "AnalyticsManager.h"
#import "AppDelegate.h"
#import "LoadingIndictor.h"
#import "ExplanationPopupView.h"
//#import <AVFoundation/AVFoundation.h>
#import "UIImage+Resize.h"
#import "UIView+UIImage.h"
#import "RewardsViewController.h"
#import "UIButton+HSNavButton.h"

typedef NS_ENUM(NSUInteger, DealSection)  {
    DealSectionDescription,
    DealSectionInviteMessage,
    DealSectionTime,
    DealSectionInvite
};

@interface SetDealViewController () <UITextViewDelegate, FindFriendsViewControllerDelegate>

@property (strong, nonatomic) UIView *dealDescriptionView;
@property (strong, nonatomic) UIView *dealContentView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
//@property (strong, nonatomic) UIImageView *fallBackImageView;
@property (strong, nonatomic) UIImage *image;
//@property (strong, nonatomic) UILabel *venueLabelLineOne;
//@property (strong, nonatomic) UILabel *venueLabelLineTwo;
//@property (strong, nonatomic) UILabel *eventLabelLineOne;
//@property (strong, nonatomic) UILabel *eventLabelLineTwo;
//@property (strong, nonatomic) UILabel *distanceLabel;
//@property (strong, nonatomic) UIView *cameraPreview;
//@property (strong, nonatomic) UILabel *descriptionLabel;
//@property (strong, nonatomic) UILabel *descriptionDetailLabel;

@property (strong, nonatomic) UIView *composeMessageView;
@property (strong, nonatomic) UIView *composeMessageContentView;
@property (strong, nonatomic) UILabel *composeMessageTitleLabel;
@property (strong, nonatomic) UITextView *composeMessageTextView;

@property (strong, nonatomic) UIView *dateView;
@property (strong, nonatomic) UIView *dateContentView;
@property (strong, nonatomic) UILabel *dateTitleLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) UIView *inviteFriendsView;
@property (strong, nonatomic) UIButton *inviteFriendsButton;
//@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
//@property (assign, nonatomic) BOOL haveImage;
//@property (assign, nonatomic) BOOL frontCamera;
//@property (strong, nonatomic) NSString *imageUrl;
//@property (strong, nonatomic) UIButton *retakePictureButton;
//@property (strong, nonatomic) UIButton *takePicture;
//@property (strong, nonatomic) UIButton *toggleCamera;
//@property (strong, nonatomic) AVCaptureSession *session;
//@property (strong, nonatomic) UILabel *topPictureLabel;
//@property (strong, nonatomic) UILabel *bottomPictureLabel;
//@property (strong, nonatomic) RewardsViewController *rewardsViewController;

@property (strong, nonatomic) NSDate *date;

@property (assign, nonatomic) BOOL modifiedMessage;


@end

@implementation SetDealViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIImage *titleImage = [UIImage imageNamed:@"hotspotLogoNav"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
//    self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
//    [self addChildViewController:self.rewardsViewController];
//    [self.rewardsViewController updateRewardsScore];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *skipButton = [UIButton navButtonWithTitle:@"SKIP"];
    [skipButton addTarget:self action:@selector(skipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:skipButton];
    
    self.dealDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
    //self.dealContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dealDescriptionView.width, 243)];
    [self.dealDescriptionView addSubview:self.dealContentView];
//    [self.dealContentView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    
    UIImageView *groupIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupIcon"]];
    groupIcon.centerX = self.view.width/2;
    groupIcon.y = 20;
    [self.dealDescriptionView addSubview:groupIcon];
    
    UILabel *groupHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 30)];
    groupHeadingLabel.centerX = self.view.width/2;
    groupHeadingLabel.text = @"GET FRIENDS TOGETHER";
    groupHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    groupHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.dealDescriptionView addSubview:groupHeadingLabel];
    
    UILabel *groupTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, self.view.width - 50, 60)];
    groupTextLabel.centerX = self.view.width/2;
    groupTextLabel.font = [ThemeManager lightFontOfSize:13];
    groupTextLabel.textAlignment = NSTextAlignmentCenter;
    groupTextLabel.numberOfLines = 2;
    groupTextLabel.text = @"Edit a message, pick a time, and select friends to text through Hotspot. This is optional.";
    [self.dealDescriptionView addSubview:groupTextLabel];
    
//    self.imageView = [[UIImageView alloc] init];
//    self.imageView.height = self.dealDescriptionView.height - 10;
//    self.imageView.width = self.view.width;
//    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.imageView.clipsToBounds = YES;
//    [self.dealContentView addSubview:self.imageView];
    
    //    CGFloat originForVenuePreview = 0;
//    self.backgroundView = [[UIView alloc] initWithFrame:self.dealContentView.bounds];
//    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
//    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    [self.dealContentView addSubview:self.backgroundView];
//    
//    self.venueLabelLineOne = [[UILabel alloc] init];
//    self.venueLabelLineOne.width = self.view.width - 20;
//    self.venueLabelLineOne.x = 10;
//    self.venueLabelLineOne.height = 24;
//    self.venueLabelLineOne.y = 68;
//    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:20];
//    self.venueLabelLineOne.textColor = [UIColor whiteColor];
////    [self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
//    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
//    self.venueLabelLineOne.numberOfLines = 1;
//    [self.dealContentView addSubview:self.venueLabelLineOne];
//    
//    self.venueLabelLineTwo = [[UILabel alloc] init];
//    self.venueLabelLineTwo.width = self.view.width - 20;
//    self.venueLabelLineTwo.x = 10;
//    self.venueLabelLineTwo.height = 40;
//    self.venueLabelLineTwo.y = 86;
//    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:50];
//    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
//    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
//    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
//    self.venueLabelLineTwo.numberOfLines = 1;
//    [self.dealContentView addSubview:self.venueLabelLineTwo ];
//    
//    self.eventLabelLineOne = [[UILabel alloc] init];
//    self.eventLabelLineOne.width = self.view.width - 20;
//    self.eventLabelLineOne.x = 10;
//    self.eventLabelLineOne.height = 24;
//    self.eventLabelLineOne.y = 68;
//    self.eventLabelLineOne.font = [ThemeManager boldFontOfSize:16];
//    self.eventLabelLineOne.textColor = [UIColor whiteColor];
//    //    [self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
//    self.eventLabelLineOne.textAlignment = NSTextAlignmentLeft;
//    self.eventLabelLineOne.numberOfLines = 1;
//    [self.dealContentView addSubview:self.eventLabelLineOne];
//    
//    self.eventLabelLineTwo = [[UILabel alloc] init];
//    self.eventLabelLineTwo.width = self.view.width - 20;
//    self.eventLabelLineTwo.font = [ThemeManager boldFontOfSize:26];
//    self.eventLabelLineTwo.textColor = [UIColor whiteColor];
//    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
//    self.eventLabelLineTwo.textAlignment = NSTextAlignmentLeft;
//    [self.dealContentView addSubview:self.eventLabelLineTwo];
    
//    self.cameraPreview = [[UIView alloc] init];
//    self.cameraPreview.size = CGSizeMake(self.view.width, self.dealContentView.height);
//    self.cameraPreview.bottom = self.dealContentView.height;
//    self.cameraPreview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    [self.dealContentView addSubview:self.cameraPreview];
    
//    UIImage *topGradientImage = [UIImage imageNamed:@"topPictureGradient"];
//    UIImageView *topGradient = [[UIImageView alloc] initWithImage:topGradientImage];
//    topGradient.size = CGSizeMake(self.view.width, self.dealContentView.height);
//    topGradient.bottom = self.dealContentView.height - 3;
//    [self.dealContentView addSubview:topGradient];
    
//    self.topPictureLabel = [[UILabel alloc] init];
//    self.topPictureLabel.height = 20;
//    self.topPictureLabel.width = self.view.width - 100;
//    self.topPictureLabel.centerX = self.cameraPreview.width/2.0;
//    self.topPictureLabel.y = 10;
//    self.topPictureLabel.font = [ThemeManager regularFontOfSize:14];
//    self.topPictureLabel.textAlignment = NSTextAlignmentCenter;
//    self.topPictureLabel.textColor = [UIColor whiteColor];
//    self.topPictureLabel.text = @"Add Picture (Optional)";
//    [self.dealContentView addSubview:self.topPictureLabel];
    
//    self.toggleCamera = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *toggleCameraImage = [UIImage imageNamed:@"toggleCamera"];
//    [self.toggleCamera setImage:toggleCameraImage forState:UIControlStateNormal];
//    self.toggleCamera.frame = CGRectMake(self.dealContentView.width - 53, -12, 60, 60);
//    //[btnTwo setTitle:@"vc2:v1" forState:UIControlStateNormal];
//    [self.toggleCamera addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
//    [self.dealContentView addSubview:self.toggleCamera];
//    
//    self.takePicture = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *takePictureImage = [UIImage imageNamed:@"takePictureButton"];
//    [self.takePicture setImage:takePictureImage forState:UIControlStateNormal];
//    self.takePicture.frame = CGRectMake(0, self.dealContentView.height - 60 , 100, 60);
//    self.takePicture.centerX = self.dealContentView.width/2;
//    //[btnTwo setTitle:@"vc2:v1" forState:UIControlStateNormal];
//    [self.takePicture addTarget:self action:@selector(captureImage) forControlEvents:UIControlEventTouchUpInside];
//    [self.dealContentView addSubview:self.takePicture];
    
    
//    self.imageView = [[UIImageView alloc] init];
//    self.imageView.size = CGSizeMake(self.view.width, self.dealContentView.height);
//    self.imageView.bottom = self.dealContentView.height;
//    //self.imageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
//    [self.dealContentView addSubview:self.imageView];
    
//    UIImage *bottomGradientImage = [UIImage imageNamed:@"bottomPictureGradient"];
//    UIImageView *bottomGradient = [[UIImageView alloc] initWithImage:bottomGradientImage];
//    bottomGradient.size = CGSizeMake(self.view.width, 80);
//    bottomGradient.bottom = self.dealContentView.height;
//    [self.dealContentView addSubview:bottomGradient];
    
//    self.retakePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *retakePicture = [UIImage imageNamed:@"retakePicture"];
//    [self.retakePictureButton setImage:retakePicture forState:UIControlStateNormal];
//    self.retakePictureButton.size = CGSizeMake(60, 45);
//    self.retakePictureButton.x = self.dealContentView.width - 55;
//    self.retakePictureButton.bottom = self.dealContentView.height - 0;
//    self.retakePictureButton.hidden = YES;
//    [self.retakePictureButton addTarget:self action:@selector(retakePicture:) forControlEvents:UIControlEventTouchUpInside];
//    [self.dealContentView addSubview:self.retakePictureButton];
    
//    self.bottomPictureLabel = [[UILabel alloc] init];
//    self.bottomPictureLabel.height = 20;
//    self.bottomPictureLabel.width = self.view.width - 100;
//    self.bottomPictureLabel.centerX = self.cameraPreview.width/2.0;
//    self.bottomPictureLabel.bottom = 10;
//    self.topPictureLabel.font = [ThemeManager regularFontOfSize:14];
//    self.topPictureLabel.textAlignment = NSTextAlignmentCenter;
//    self.topPictureLabel.textColor = [UIColor whiteColor];
//    self.topPictureLabel.text = @"Picture Added!";
//    [self.dealContentView addSubview:self.topPictureLabel];
    
//    self.imageUrl = @"";
//    self.frontCamera = YES;
    
//    self.fallBackImageView = [[UIImageView alloc] init];
//    //self.fallBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriends"]];
//    self.fallBackImageView.size = CGSizeMake(self.view.width, self.dealContentView.height);
//    self.fallBackImageView.bottom = self.dealContentView.height;
//    //self.fallBackImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
//    [self.dealContentView addSubview:self.fallBackImageView];
    
//    self.descriptionLabel = [[UILabel alloc] init];
//    self.descriptionLabel.height = 10;
//    self.descriptionLabel.width = self.view.width - 40;
//    self.descriptionLabel.centerX = self.descriptionBackground.width/2.0;
//    self.descriptionLabel.font = [ThemeManager boldFontOfSize:1.3*12];
//    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
//    self.descriptionLabel.textColor = [UIColor whiteColor];
//    self.descriptionLabel.numberOfLines = 2;
//    [self.descriptionBackground addSubview:self.descriptionLabel];
    
    self.composeMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 175)];
    self.composeMessageContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 127)];
    self.composeMessageContentView.backgroundColor = [UIColor whiteColor];
//    [self.composeMessageContentView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    [self.composeMessageView addSubview:self.composeMessageContentView];
    
    UIImageView *composeMessageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"composeMessageIcon"]];
    composeMessageIcon.centerX = self.view.width/2;
    composeMessageIcon.y = 10;
    [self.composeMessageView addSubview:composeMessageIcon];
    
    UILabel *composeHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.width, 30)];
    composeHeadingLabel.centerX = self.view.width/2;
    composeHeadingLabel.text = @"MESSAGE TO FRIENDS";
    composeHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    composeHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [self.composeMessageView addSubview:composeHeadingLabel];
    
//    self.composeMessageTitleLabel = [[UILabel alloc] init];
//    self.composeMessageTitleLabel.height = 40;
//    self.composeMessageTitleLabel.x = 21;
//    self.composeMessageTitleLabel.width = self.composeMessageContentView.width - self.composeMessageTitleLabel.x;
//    self.composeMessageTitleLabel.text = @"Message to friends:";
//    self.composeMessageTitleLabel.textColor = [[ThemeManager sharedTheme] brownColor];
//    self.composeMessageTitleLabel.font = [ThemeManager regularFontOfSize:1.3*11];
//    [self.composeMessageContentView addSubview:self.composeMessageTitleLabel];
    
    UIImageView *topDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapDivider"]];
    //topDivider.backgroundColor = [UIColor colorWithWhite:229/255.0 alpha:1.0];
    topDivider.width = self.composeMessageContentView.width;
    topDivider.height = 12;
    topDivider.y = 65;
    [self.composeMessageView addSubview:topDivider];
    
//    UIImageView *editMessageBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"editMessageBackground"]];
//    editMessageBackground.height = 100;
//    [self.composeMessageView addSubview:editMessageBackground];
    
    UIImageView *bottomDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomDivider"]];
    //topDivider.backgroundColor = [UIColor colorWithWhite:229/255.0 alpha:1.0];
    //    bottomDivider.width = self.composeMessageContentView.width;
    //    bottomDivider.height = 12;
    bottomDivider.y = 185;
    [self.composeMessageView addSubview:bottomDivider];
    
    self.composeMessageTextView = [[UITextView alloc] init];
    self.composeMessageTextView.width = self.view.width - 150;
    self.composeMessageTextView.height = 70;
    self.composeMessageTextView.x = 0;
    self.composeMessageTextView.y = 0;
    self.composeMessageTextView.textContainerInset = UIEdgeInsetsMake(8, 19, 8, 19);
    self.composeMessageTextView.textAlignment = NSTextAlignmentCenter;
    self.composeMessageTextView.font = [UIFont systemFontOfSize:14];
//    self.composeMessageTextView.textColor = [UIColor blackColor];
    self.composeMessageTextView.textColor = [UIColor blackColor];
    self.composeMessageTextView.delegate = self;
    self.composeMessageTextView.returnKeyType = UIReturnKeyDone;
    [self.composeMessageView addSubview:self.composeMessageTextView];
    
//    UIView *bottomDivider = [[UIView alloc] init];
//    bottomDivider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2];
//    bottomDivider.width = self.composeMessageContentView.width;
//    bottomDivider.height = 0.5;
//    bottomDivider.y = 165;
//    [self.composeMessageView addSubview:bottomDivider];
    
    self.dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 135)];
    //self.dateContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    //self.dateContentView.backgroundColor = [UIColor whiteColor];
//    [self.dateContentView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    //[self.dateView addSubview:self.dateContentView];
    
    UIImageView *timeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeIcon"]];
    timeIcon.centerX = self.view.width/2;
    timeIcon.y = 40;
    [self.dateView addSubview:timeIcon];
    
    self.dateTitleLabel = [[UILabel alloc] init];
    self.dateTitleLabel.height = 50;
    self.dateTitleLabel.x = 0;
    self.dateTitleLabel.y = 50;
    self.dateTitleLabel.width = self.view.width;
    self.dateTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.dateTitleLabel.font = [ThemeManager boldFontOfSize:12];
    self.dateTitleLabel.textColor = self.composeMessageTitleLabel.textColor;
    self.dateTitleLabel.text = @"CHOOSE TIME TO MEET";
    [self.dateView addSubview:self.dateTitleLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.height = 50;
    self.dateLabel.y = 95;
    self.dateLabel.x = 79;
    self.dateLabel.width = self.view.width;
    self.dateLabel.textColor = [UIColor blackColor];
    self.dateLabel.font = [ThemeManager lightFontOfSize:15];
    [self.dateView addSubview:self.dateLabel];
    
    self.inviteFriendsView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, self.view.width, 70)];
    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inviteFriendsButton.size = CGSizeMake(self.view.width, 40);
    self.inviteFriendsButton.centerX = self.inviteFriendsView.width/2.0;
    self.inviteFriendsButton.y = 0;
    self.inviteFriendsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.inviteFriendsButton setTitle:@"SELECT FRIENDS" forState:UIControlStateNormal];
    //UIImage *chevronImage = [UIImage imageNamed:@"whiteChevron"];
    //[self.inviteFriendsButton setImage:[UIImage imageNamed:@"whiteChevron"] forState:UIControlStateNormal];
    //self.inviteFriendsButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteFriendsButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    //self.inviteFriendsButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., chevronImage.size.width);
    self.inviteFriendsButton.titleLabel.font = [ThemeManager boldFontOfSize:15];
    [self.inviteFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.inviteFriendsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.inviteFriendsButton addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.inviteFriendsView addSubview:self.inviteFriendsButton];
    
//    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    skipButton.size = CGSizeMake(self.view.width, 35);
//    skipButton.centerX = self.view.width/2.0;
//    skipButton.y = 35;
//    skipButton.backgroundColor = [UIColor whiteColor];
//    [skipButton setTitle:@"OR, FLY SOLO. GET THIS DEAL" forState:UIControlStateNormal];
//    skipButton.titleLabel.font = [ThemeManager lightFontOfSize:13];
//    [skipButton setTitleColor:[UIColor unnormalizedColorWithRed:240 green:122 blue:101 alpha:255] forState:UIControlStateNormal];
//    [skipButton setTitleColor:[[UIColor unnormalizedColorWithRed:240 green:122 blue:101 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//    [skipButton addTarget:self action:@selector(skipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [self.inviteFriendsView addSubview:skipButton];
}

- (void)preloadWithDealID:(NSNumber *)dealID
{
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
    [[APIClient sharedClient] getDealWithID:dealID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
        Deal *deal = [[Deal alloc] initWithDictionary:responseObject[@"deals"]];
        self.deal = deal;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

- (void)setDeal:(Deal *)deal
{
    _deal = deal;
    [self view];
    [self resetDate];
    
//    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    
//    if(status == AVAuthorizationStatusAuthorized) {
//        [self initializeCamera];
//    } else if(status == AVAuthorizationStatusDenied){
//        [self cameraUnavailable];
//    } else if(status == AVAuthorizationStatusRestricted){
//        [self cameraUnavailable];
//    } else if(status == AVAuthorizationStatusNotDetermined){
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            if(granted){
//                [self initializeCamera];
//            } else {
//                [self cameraUnavailable];
//            }
//        }];
//    }
    
    
      //NSString *ImageURL = @"https://s3-us-west-2.amazonaws.com/hotspot-venue-images/screenshot_220.png";
      //NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
      //self.imageView.image = [UIImage imageWithData:imageData];

    //[self.imageView sd_setImageWithURL:deal.venue.imageURL];
    //self.venueLabelLineOne.text = deal.venue.name;
//    self.descriptionLabel.text = deal.dealDescription;
//    [self.descriptionLabel sizeToFit];
//    self.descriptionLabel.centerX = self.descriptionBackground.width/2.0;
//    self.descriptionLabel.y = 8;
//    self.descriptionBackground.height = self.descriptionLabel.height + 40;
//    self.descriptionBackground.bottom = self.dealContentView.height;
//    
    if ([deal.dealType  isEqual: @"DT"]) {
//        self.venueLabelLineTwo.y = self.dealContentView.height - self.descriptionBackground.height - 45;
//        self.venueLabelLineTwo.x = 5;
//        self.venueLabelLineOne.y = self.venueLabelLineTwo.y - 20;
//        self.venueLabelLineOne.x = 5;
//        
//        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:deal.venue.name];
//        self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
//        self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    } else {
//        self.eventLabelLineOne.text = [[NSString stringWithFormat:@"%@ @ %@", deal.hoursAvailableString, deal.venue.name] uppercaseString];
//        self.eventLabelLineOne.y = 15;
//        self.eventLabelLineOne.x = 5;
//        
//        self.eventLabelLineTwo.width = self.dealDescriptionView.width - 10;
//        self.eventLabelLineTwo.height = 150;
//        self.eventLabelLineTwo.numberOfLines = 0;
//        self.eventLabelLineTwo.text = [deal.additionalInfo uppercaseString];
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.eventLabelLineTwo.text];
//        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//        paragrahStyle.lineSpacing = 1.f;
//        paragrahStyle.paragraphSpacing = 1.f;
//        paragrahStyle.paragraphSpacingBefore = 1.f;
//        paragrahStyle.maximumLineHeight = 26.f;
//        //[paragrahStyle setLineSpacing:1.f];
//        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [self.eventLabelLineTwo.text length])];
//        self.eventLabelLineTwo.attributedText = attributedString ;
////        self.eventLabelLineTwo.text = [deal.additionalInfo uppercaseString];
//        self.eventLabelLineTwo.x = 5;
//        [self.eventLabelLineTwo sizeToFit];
//        self.eventLabelLineTwo.bottom = self.dealContentView.height - self.descriptionBackground.height - 5;
    
        UIView *backgroundViewBlack = [[UIView alloc] initWithFrame:self.dealDescriptionView.bounds];
        backgroundViewBlack.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        UIView *backgroundViewOrange = [[UIView alloc] initWithFrame:self.dealDescriptionView.bounds];
        backgroundViewOrange.backgroundColor = [UIColor colorWithRed:(199/255.) green:(88/255.) blue:(13/255.) alpha:.2 ];
        backgroundViewBlack.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundViewOrange.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.dealDescriptionView addSubview:backgroundViewBlack];
        [self.dealDescriptionView addSubview:backgroundViewOrange];
    }
    
//    
//    self.descriptionDetailLabel = [[UILabel alloc] init];
//    self.descriptionDetailLabel.width = self.view.width - 40;
//    self.descriptionDetailLabel.font = [ThemeManager lightFontOfSize:1.3*11];
//    self.descriptionDetailLabel.textColor = [UIColor whiteColor];
//    self.descriptionDetailLabel.textAlignment = NSTextAlignmentCenter;
//    self.descriptionDetailLabel.text = @"(They don't even have to show up)";
//    [self.descriptionDetailLabel sizeToFit];
//    self.descriptionDetailLabel.centerX = self.descriptionBackground.width/2.0;
//    self.descriptionDetailLabel.y = self.descriptionLabel.bottom + 4;
//    [self.descriptionBackground addSubview:self.descriptionDetailLabel];

    self.composeMessageTextView.text = [self defaultInviteMessageForDeal:deal];
        
    [self.tableView reloadData];
    [[AnalyticsManager sharedManager] viewedDeal:deal.dealID.stringValue withPlaceName:deal.venue.name];
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
}

- (BOOL)customMessageExceedsMaxLength:(NSString *)customMessage
{
    NSInteger maxLength = 159 - [User loggedInUser].fullName.length;
    return customMessage.length > maxLength;
}

- (NSString *)defaultInviteMessageForDeal:(Deal *)deal
{
    NSString *text = [NSString stringWithFormat:@"Hey! You should meet us at %@ at %@ %@. %@", deal.venue.name, self.date.formattedTime, self.date.formattedDay.lowercaseString, deal.invitePrompt];
    if ([self customMessageExceedsMaxLength:text]) {
        text = [NSString stringWithFormat:@"Hey! You should meet us at %@, at %@. %@", deal.venue.name, self.date.formattedTime.lowercaseString, self.deal.invitePrompt];
    }
    return text;
}

- (void)inviteButtonTouched:(id)sender
{
    if (![self.deal isAvailableAtDate:self.date]) {
        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
//        [self uploadPicture];
        [self selectFriends];
    }
}

//- (void)retakePicture:(id)sender
//{
//    self.retakePictureButton.hidden = YES;
//    self.image = nil;
//    [self.imageView setImage:self.image];
//}

- (void)selectFriends
{
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
    findFriendsViewController.delegate = self;
    findFriendsViewController.deal = self.deal;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
    [[AnalyticsManager sharedManager] invitedFriendsDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name];
    //[self showExplanationPopup];
}

//- (void)showExplanationPopup
//{
//    ExplanationPopupView *explanationPopupView = [[ExplanationPopupView alloc] init];
//    NSString *address = self.deal.venue.name;
//    NSString *inviteText = self.composeMessageTextView.text;
//    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:inviteText];
//    [attributedText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[inviteText rangeOfString:address]];
//    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[inviteText rangeOfString:address]];
//    [attributedText addAttribute:NSFontAttributeName value:[ThemeManager lightFontOfSize:1.3*8] range:NSMakeRange(0, inviteText.length)];
//    explanationPopupView.attributedInviteText = attributedText;
//    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasShownDealExplanation]) {
//        jadispatch_after_delay(0.7, dispatch_get_main_queue(), ^{
//            [explanationPopupView show];
//        });
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasShownDealExplanation];
//    }
//}

- (void)resetDate
{
    //round date to nearest 15 min
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate: now];
    NSInteger minutesToSubract = (comps.minute % 5);
    if (minutesToSubract) {
        self.date = [now dateByAddingTimeInterval:-60*minutesToSubract];
    }
    else {
        self.date = now;
    }
    self.dateLabel.text = @"Now (tap here to change)";
    [self.tableView reloadData];
}

- (void)datePickerUpdated:(UIDatePicker *)datePicker
{
    self.date = datePicker.date;
    self.dateLabel.text = self.date.fullFormattedDate;
    if (!self.modifiedMessage) {
        self.composeMessageTextView.text = [self defaultInviteMessageForDeal:self.deal];
    }
}

//- (void)toggleCamera:(id)sender
//{
//    self.frontCamera = !self.frontCamera;
//    
//    //Change camera source
//    if(self.session)
//    {
//        //Indicate that some changes will be made to the session
//        [self.session beginConfiguration];
//        
//        //Remove existing input
//        AVCaptureInput* currentCameraInput = [self.session.inputs objectAtIndex:0];
//        [self.session removeInput:currentCameraInput];
//        
//        //Get new input
//        AVCaptureDevice *newCamera = nil;
//        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
//        {
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
//        }
//        else
//        {
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//        }
//        
//        //Add input to session
//        NSError *err = nil;
//        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
//        if(!newVideoInput || err)
//        {
//            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
//        }
//        else
//        {
//            [self.session addInput:newVideoInput];
//        }
//        
//        //Commit all the configuration changes at once
//        [self.session commitConfiguration];
//    }
//    
//}

//- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
//{
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for (AVCaptureDevice *device in devices)
//    {
//        if ([device position] == position) return device;
//    }
//    return nil;
//}

- (void)showDatePicker
{
    DatePickerModalView *datePicker = [[DatePickerModalView alloc] init];
    datePicker.datePicker.date = [NSDate date];
    datePicker.datePicker.minuteInterval = 15;
    [datePicker.datePicker addTarget:self action:@selector(datePickerUpdated:) forControlEvents:UIControlEventValueChanged];
    [datePicker show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.row == DealSectionDescription) {
        height = self.dealDescriptionView.height;
    }
    else if (indexPath.row == DealSectionInviteMessage) {
        height = self.composeMessageView.height;
    }
    else if (indexPath.row == DealSectionTime) {
        height = self.dateView.height;
    }
    else {
        height = self.inviteFriendsView.height;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == DealSectionDescription) {
        cell = [self descriptionCell];
    }
    else if (indexPath.row == DealSectionInviteMessage) {
        cell = [self composeMessageCell];
    }
    else if (indexPath.row == DealSectionTime) {
        cell = [self dateCell];
    }
    else {
        cell = [self inviteCell];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)descriptionCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.clipsToBounds = YES;
    [cell.contentView addSubview:self.dealDescriptionView];
    return cell;
}

- (UITableViewCell *)composeMessageCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.contentView addSubview:self.composeMessageView];
    return cell;
}

- (UITableViewCell *)dateCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.contentView addSubview:self.dateView];
    return cell;
}

- (UITableViewCell *)inviteCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.contentView addSubview:self.inviteFriendsView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == DealSectionDescription) {
        if ([self.deal.dealType isEqual:@"DT"]) {
            //[self captureImage];
//            [[[UIAlertView alloc] initWithTitle:@"The Fine Print" message:self.deal.additionalInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];   
        }
    }
    else if (indexPath.row == DealSectionTime) {
        [self showDatePicker];
    }
    else if (indexPath.row == DealSectionInvite) {
        if (![self.deal isAvailableAtDate:self.date]) {
            NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
            [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else {
            [self inviteButtonTouched:nil];
        }
    }
}

#pragma mark - Find Friends Delegate
- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts
{
    if (contacts.count >= self.deal.inviteRequirement.integerValue) {
        [self setBeaconOnServerWithInvitedContacts:contacts];
        [[AnalyticsManager sharedManager] setDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name numberOfInvites:contacts.count];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"Just select %d more friends to unlock this deal", self.deal.inviteRequirement.integerValue - contacts.count];
        [[[UIAlertView alloc] initWithTitle:@"You're Almost There..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)setBeaconOnServerWithInvitedContacts:(NSArray *)contacts
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIView *view = appDelegate.window.rootViewController.view;
    MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
    [[APIClient sharedClient] applyForDeal:self.deal invitedContacts:contacts customMessage:self.composeMessageTextView.text time:self.date imageUrl:@"" success:^(Beacon *beacon) {
        [loadingIndicator hide:YES];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
    } failure:^(NSError *error) {
        [loadingIndicator hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - Text View Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.modifiedMessage = YES;
    NSString *resultantText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([self customMessageExceedsMaxLength:resultantText] && resultantText.length > textView.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your message is over the character limit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
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

- (void)skipButtonTouched:(id)sender
{
    if (![self.deal isAvailableAtDate:self.date]) {
        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        NSArray *noContact = [[NSArray alloc] init];
        [self setBeaconOnServerWithInvitedContacts:noContact];
    }
}

//- (void) cameraUnavailable {
//    [self.fallBackImageView sd_setImageWithURL:self.deal.venue.imageURL];
//    self.takePicture.hidden = YES;
//    self.toggleCamera.hidden = YES;
//    
//}

//- (void) initializeCamera {
//    
//    self.session = [[AVCaptureSession alloc] init];
//    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
//    
//    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    
//    captureVideoPreviewLayer.frame = self.cameraPreview.bounds;
//    [self.cameraPreview.layer addSublayer:captureVideoPreviewLayer];
//    
//    UIView *view = [self cameraPreview];
//    CALayer *viewLayer = [view layer];
//    [viewLayer setMasksToBounds:YES];
//    
//    CGRect bounds = [view bounds];
//    [captureVideoPreviewLayer setFrame:bounds];
//    
//    NSArray *devices = [AVCaptureDevice devices];
//    AVCaptureDevice *frontCamera;
//    AVCaptureDevice *backCamera;
//    
//    for (AVCaptureDevice *device in devices) {
//        
//        NSLog(@"Device name: %@", [device localizedName]);
//        
//        if ([device hasMediaType:AVMediaTypeVideo]) {
//            
//            if ([device position] == AVCaptureDevicePositionBack) {
//                NSLog(@"Device position : back");
//                backCamera = device;
//            }
//            else {
//                NSLog(@"Device position : front");
//                frontCamera = device;
//            }
//        }
//    }
//    
//    if (!self.frontCamera) {
//        NSError *error = nil;
//        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
//        if (!input) {
//            NSLog(@"ERROR: trying to open camera: %@", error);
//        }
//        [self.session addInput:input];
//    }
//    
//    if (self.frontCamera) {
//        NSError *error = nil;
//        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:nil];
//        if (!input) {
//            NSLog(@"ERROR: trying to open camera: %@", error);
//        }
//        [self.session addInput:input];
//    }
//    
//    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
//    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
//    [self.stillImageOutput setOutputSettings:outputSettings];
//    
//    [self.session addOutput:self.stillImageOutput];
//    
//    [self.session startRunning];
//    
//}

//- (void) captureImage { //method to capture image from AVCaptureSession video feed
//
//    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
//    AVCaptureConnection *videoConnection = nil;
//    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
//        
//        for (AVCaptureInputPort *port in [connection inputPorts]) {
//            
//            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
//                videoConnection = connection;
//                break;
//            }
//        }
//        
//        if (videoConnection) {
//            break;
//        }
//    }
//    
//    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
//    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
//        
//        if (imageSampleBuffer != NULL) {
//            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
//            [self processImage:[UIImage imageWithData:imageData]];
//        }
//    }];
//}

//- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
//    self.haveImage = YES;
//    self.retakePictureButton.hidden = NO;
//    
//    UIGraphicsBeginImageContext(CGSizeMake(self.dealDescriptionView.width, self.dealDescriptionView.height));
//    [image drawInRect: CGRectMake(0, 0, self.dealDescriptionView.width, self.dealDescriptionView.height)];
//    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGRect cropRect = CGRectMake(0, 55, self.dealDescriptionView.width, self.dealDescriptionView.height - 106);
//    CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
//    
//    UIImage *unflippedImage = [UIImage imageWithCGImage:imageRef];
//    
//    if (self.frontCamera) {
//        self.image = [UIImage imageWithCGImage:unflippedImage.CGImage
//                                         scale:unflippedImage.scale
//                                   orientation:UIImageOrientationUpMirrored];
//    } else {
//        self.image = unflippedImage;
//    }
//    
//    
//    [self.imageView setImage:self.image];
//    
//    [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//    
//    CGImageRelease(imageRef);
//    
//}

//- (void) uploadPicture {
//        if (self.haveImage) {
//            
//            UIImage *imageToUpload = [self.imageView UIImage];
//            [[APIClient sharedClient] postImage:imageToUpload forBeaconWithID:[NSNumber numberWithInt:1000] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSString *baseURL = @"https://s3.amazonaws.com/hotspot-photo/";
//                NSString *imageKey = responseObject[@"image_key"];
//                self.imageUrl = [baseURL stringByAppendingString:imageKey];
//                NSLog(@"%@", self.imageUrl);
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                
//            }];
//        }
//}

@end
