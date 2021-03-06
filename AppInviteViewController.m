//
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "AppInviteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "GroupsViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UIButton+HSNavButton.h"
#import "Contact.h"
#import "Theme.h"
#import "APIClient.h"
#import "User.h"
#import "Group.h"
#import "Deal.h"
#import "Venue.h"
#import "Utilities.h"
#import "LoadingIndictor.h"
#import "NavigationBarTitleLabel.h"
#import "AppDelegate.h"
#import "TextMessageManager.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AppInviteViewController()

@property (strong, nonatomic) NSMutableDictionary *tableViewHeaderPool;
@property (strong, nonatomic) NSMutableDictionary *selectAllButtonPool;
@property (strong, nonatomic) NSMutableSet *collapsedSections;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIView *sendMessageContainer;
@property (strong, nonatomic) UIButton *sendMessage;
@property (strong, nonatomic) UILabel *prompt;
@property (assign, nonatomic) BOOL inviteButtonShown;
@property (assign, nonatomic) BOOL inSearchMode;
@property (readonly) NSInteger promptContainer;
@property (readonly) NSInteger searchBarContainer;
@property (readonly) NSInteger findFriendSectionSuggested;
@property (readonly) NSInteger findFriendSectionContacts;
@property (nonatomic, strong) NSDate *date;
@property (assign, nonatomic) BOOL modifiedMessage;
@property (assign, nonatomic) BOOL isSendMessageShowing;
@property (assign, nonatomic) BOOL isKeyboardShowing;
@property (assign, nonatomic) int keyboardHeight;
@property (assign, nonatomic) CGFloat animationDuration;
@property (strong, nonatomic) UILabel *promoCode;
@property (strong, nonatomic) MFMailComposeViewController *emailModal;
@property (strong, nonatomic) MFMessageComposeViewController *smsModal;
@property (strong, nonatomic) UIButton *emailButton;
@property (strong, nonatomic) UIButton *smsButton;
@property (strong, nonatomic) NSString *smsMessage;

@end

#define selectedTransform CGAffineTransformMakeScale(1.35, 1.35)

@implementation AppInviteViewController

//- (NSMutableDictionary *)selectedContactDictionary
//{
//    if (!_selectedContactDictionary) {
//        _selectedContactDictionary = [NSMutableDictionary new];
//    }
//    return _selectedContactDictionary;
//}

//- (NSMutableDictionary *)inactiveContactDictionary
//{
//    if (!_inactiveContactDictionary) {
//        _inactiveContactDictionary = [NSMutableDictionary new];
//    }
//    return _inactiveContactDictionary;
//}

//- (NSMutableSet *)collapsedSections
//{
//    if (!_collapsedSections) {
//        _collapsedSections = [[NSMutableSet alloc] init];
//    }
//    return _collapsedSections;
//}
//
//- (NSInteger)promptContainer
//{
//    return 0;
//}
//
//- (NSInteger)findFriendSectionSuggested
//{
//    return 1;
//}
//
//- (NSInteger)findFriendSectionContacts
//{
//    return 2;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.rewardsViewController = [[RewardsViewController alloc] initWithNavigationItem:self.navigationItem];
//    [self addChildViewController:self.rewardsViewController];
//    [self.rewardsViewController updateRewardsScore];
    
//    self.scrollViewContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    self.scrollViewContainer.backgroundColor = [UIColor grayColor];
//    self.scrollViewContainer.scrollEnabled = YES;
//    self.scrollViewContainer.contentSize = CGSizeMake(self.view.width, 2000);
//    [self.view addSubview:self.scrollViewContainer];
    
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Free Drinks"];
    
    UIButton *cancelButton = [UIButton navButtonWithTitle:@"Cancel"];
    [cancelButton addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[APIClient sharedClient] getPromo:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSString *promoCode = responseObject[@"promo_code"];
        //        NSString *emailSubject = responseObject[@"email_subject"];
        //        NSString *emailBody = responseObject[@"email_body"];
        NSString *smsMessage = responseObject[@"sms_message"];
        
        self.smsMessage = smsMessage;
        //
        //        self.emailModal = [[MFMailComposeViewController alloc] init];
        //        self.emailModal.mailComposeDelegate = self;
        //        [self.emailModal setSubject:emailSubject];
        //        [self.emailModal setMessageBody:emailBody isHTML:NO];
        //        //        [mail setToRecipients:@[@"testingEmail@example.com"]];
        //
        //        self.smsModal = [[MFMessageComposeViewController alloc] init];
        //        self.smsModal.messageComposeDelegate = self;
        //        //picker.recipients = [NSArray arrayWithObjects:@"1234", @"2345", nil];
        //        self.smsModal.body = smsMessage;
        
    } failure:nil];
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:self.tableView];
//    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.hidden = YES;
    
//    self.sendMessageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 55)];
//    self.sendMessageContainer.backgroundColor = [[UIColor alloc] initWithWhite:0.96 alpha: 1.0];
//    self.sendMessageContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    [self.view addSubview:self.sendMessageContainer];
//    self.sendMessage = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, self.view.width - 50, 35)];
////    self.sendMessage.size = CGSizeMake(65, 40);
//    self.sendMessage.centerX = self.view.width/2;
//    self.sendMessage.y = 10;
//    self.sendMessage.layer.cornerRadius = 4;
//    [self.sendMessage setTitle:@"SEND INVITATIONS" forState:UIControlStateNormal];
//    self.sendMessage.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
//    self.sendMessage.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.sendMessage.titleLabel.font = [UIFont boldSystemFontOfSize:17];
//    [self.sendMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.sendMessage setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.5] forState:UIControlStateSelected];
//    [self.sendMessage addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [self.sendMessageContainer addSubview:self.sendMessage];
    
//    self.messageCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.width, 15)];
//    self.messageCount.font = [ThemeManager regularFontOfSize:13];
//    self.messageCount.textAlignment = NSTextAlignmentCenter;
//    self.messageCount.textColor = [[UIColor alloc] initWithWhite:0.65 alpha:1.0];
//    //    self.messageCount.text = @"1 Individual SMS";
//    self.messageCount.centerX = self.view.width/2;
//    [self.sendMessageContainer addSubview:self.messageCount];
//    
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[[UIColor alloc] initWithWhite:0.50 alpha: 1.0] CGColor];
    upperBorder.frame = CGRectMake(0, 0, self.view.width, 0.25f);
    [self.sendMessageContainer.layer addSublayer:upperBorder];
    
//    self.composeMessageTextView = [[UITextView alloc] init];
//    self.composeMessageTextView.width = self.view.width - 75;
//    self.composeMessageTextView.height = 85;
//    self.composeMessageTextView.x = 10;
//    self.composeMessageTextView.y = 10;
//    self.composeMessageTextView.layer.cornerRadius = 6;
//    self.composeMessageTextView.layer.borderWidth = .25f;
//    self.composeMessageTextView.layer.borderColor = [[[UIColor alloc] initWithWhite:0.50 alpha: 1.0] CGColor];
//    self.composeMessageTextView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
//    self.composeMessageTextView.textAlignment = NSTextAlignmentLeft;
//    self.composeMessageTextView.font = [UIFont systemFontOfSize:15];
//    //    self.composeMessageTextView.textColor = [UIColor blackColor];
//    self.composeMessageTextView.textColor = [UIColor blackColor];
//    self.composeMessageTextView.delegate = self;
//    self.composeMessageTextView.text = @"Join me on Hotspot so we can both get a free (alcoholic) drink. http://GetHotspotApp.com";
//    self.composeMessageTextView.returnKeyType = UIReturnKeyDone;
//    [self.sendMessageContainer addSubview:self.composeMessageTextView];
    
//    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
//    if (contactAuthStatus == kABAuthorizationStatusAuthorized) {
//        [self loadAuthorizedContactView];
//    } else if (contactAuthStatus == kABAuthorizationStatusNotDetermined) {
//        NSString *message = [NSString stringWithFormat:@"Syncing contacts lets you earn free drinks when you invite friends or text them to meet up through Hotspot"];
//        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Want Free Drinks?" message:message];
//        [alertView bk_addButtonWithTitle:@"Sync Contacts" handler:^{
//            [self requestContactPermissions];
//        }];
//        [alertView bk_setCancelButtonWithTitle:@"Maybe Later" handler:^ {
//            [self loadUnauthorizedContactView];
//        }];
//        [alertView show];
//    } else {
    [self loadUnauthorizedContactView];
//    }
    
}

//- (void)requestContactPermissions
//{
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//        if (granted) {
//            [self loadAuthorizedContactView];
////            [[ContactManager sharedManager] syncContacts];
//        } else {
//            [self loadUnauthorizedContactView];
//        }
//    });
//}

//- (void) loadAuthorizedContactView
//{
//    
//    //    UIButton *skipButton = [UIButton navButtonWithTitle:@"SKIP"];
//    //    [skipButton addTarget:self action:@selector(skipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:skipButton];
//    
//    [self resetDate];
//    
//    //    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
//    //    //weird hack for black search bar issue
//    //    self.searchBar.backgroundImage = [UIImage new];
//    //    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
//    //    self.searchBar.delegate = self;
//    //    self.searchBar.barTintColor = [[ThemeManager sharedTheme] redColor];
//    //    self.searchBar.translucent = NO;
//    //    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
//    //    [self.view addSubview:self.searchBar];
//    
//    UIView *searchBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 40)];
//    searchBarContainer.backgroundColor = [UIColor whiteColor];
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 10, self.view.width * .8, 25)];
//    //weird hack for black search bar issue
//    self.searchBar.backgroundImage = [UIImage new];
//    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
//    self.searchBar.delegate = self;
//    //self.searchBar.barTintColor = [[ThemeManager sharedTheme] redColor];
//    self.searchBar.translucent = NO;
//    self.searchBar.layer.cornerRadius = 12;
//    self.searchBar.layer.borderWidth = 1.0;
//    self.searchBar.centerX = self.view.width/2;
//    self.searchBar.layer.borderColor = [[UIColor unnormalizedColorWithRed:167 green:167 blue:167 alpha:255] CGColor];
//    //self.searchBar.searchBarStyle = UISearchBarStyleProminent;
//    [searchBarContainer addSubview:self.searchBar];
//    //    self.navigationItem.titleView = searchBarContainer;
//    [self.view addSubview:searchBarContainer];
//    
//    self.tableView.backgroundColor = [UIColor whiteColor];
//    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
//    self.tableView.sectionIndexColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
//    
//    self.isSendMessageShowing = NO;
//    self.isKeyboardShowing = NO;
//    
//    self.tableView.hidden = NO;
//    
//    //    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    //    self.skipButton.width = self.view.width;
//    //    self.skipButton.height = 35;
//    //    self.skipButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
//    //    self.skipButton.y = self.view.height - 35;
//    //    [self.skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
//    //
//    //    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    //    [self.skipButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.5] forState:UIControlStateSelected];
//    //    [self.skipButton addTarget:self action:@selector(skipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    //    self.skipButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    //    self.skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//    //    [self.view addSubview:self.skipButton];
//    
//    
//    //    self.dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
//    //    UITapGestureRecognizer *dateViewTap =
//    //    [[UITapGestureRecognizer alloc] initWithTarget:self
//    //                                            action:@selector(dateViewTap:)];
//    //    [self.dateView addGestureRecognizer:dateViewTap];
//    //    [self.sendMessageContainer addSubview:self.dateView];
//    //
//    //    self.dateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
//    //    self.dateTitleLabel.text = @"Choose Time:";
//    //    self.dateTitleLabel.font = [ThemeManager regularFontOfSize:14];
//    //    self.dateTitleLabel.textColor = [UIColor blackColor];
//    //    [self.sendMessageContainer addSubview:self.dateTitleLabel];
//    //
//    //    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.width - 65, 30)];
//    //    self.dateLabel.font = [ThemeManager regularFontOfSize:14];
//    //    self.dateLabel.textAlignment = NSTextAlignmentRight;
//    //    self.dateLabel.textColor = [[ThemeManager sharedTheme] redColor];
//    //    [self.sendMessageContainer addSubview:self.dateLabel];
//    
//    [self resetDate];
//    
//    //    [self updateInviteButtonText:nil];
//    //UIEdgeInsets insets = self.tableView.contentInset;
//    //insets.bottom = self.inviteButton.frame.size.height;
//    //self.tableView.contentInset = insets;
//    self.inviteButtonShown = YES;
//    
//    self.tableView.rowHeight = 40;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
//    
//    //        ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
//    //    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//    //            self.onlyContacts = NO;
//    jadispatch_main_qeue(^{
//        NSOperation *updateFriendsOperation = [ContactManager sharedManager].updateFriendsOperation;
//        if (updateFriendsOperation && !updateFriendsOperation.isFinished) {
//            [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
//            NSBlockOperation *populateOperation = [NSBlockOperation blockOperationWithBlock:^{
//                //total hack. wait for url operation completion block to finish before populating contacts
//                jadispatch_after_delay(1, dispatch_get_main_queue(), ^{
//                    [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//                    [self populateContacts];
//                });
//            }];
//            [populateOperation addDependency:updateFriendsOperation];
//            [[NSOperationQueue mainQueue] addOperation:populateOperation];
//        }
//        else {
//            [self populateContacts];
//        }
//    });
//}

- (void) loadUnauthorizedContactView
{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    UIImageView *promptIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drinkImage"]];
    promptIcon.centerX = self.view.width/2;
    promptIcon.y = 50;
    [self.view addSubview:promptIcon];
    
    UILabel *promptHeading = [[UILabel alloc] initWithFrame:CGRectMake(0, 248, self.view.width, 15)];
    promptHeading.textAlignment = NSTextAlignmentCenter;
    promptHeading.text = [[NSString stringWithFormat:@"GET FREE DRINKS."] uppercaseString];
    promptHeading.font = [ThemeManager boldFontOfSize:14];
    
    [self.view addSubview:promptHeading];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 75, 60)];
    self.prompt.centerX = self.view.width/2;
    self.prompt.y = 250;
    self.prompt.font = [ThemeManager lightFontOfSize:14];
    self.prompt.textColor = [UIColor blackColor];
    self.prompt.numberOfLines = 2;
    self.prompt.textAlignment = NSTextAlignmentCenter;
    self.prompt.text = [NSString stringWithFormat:@"Send friends a drink and you’ll get one when they use theirs"];
    
//    UILabel *promoCodePrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.width - 50, 30)];
//    promoCodePrompt.centerX = self.view.width/2;
//    promoCodePrompt.y = 105;
//    promoCodePrompt.font = [ThemeManager lightFontOfSize:12];
//    promoCodePrompt.textColor = [UIColor blackColor];
//    promoCodePrompt.numberOfLines = 2;
//    promoCodePrompt.textAlignment = NSTextAlignmentCenter;
//    promoCodePrompt.text = [NSString stringWithFormat:@"Send your promo code:"];
//    [view addSubview:promoCodePrompt];
    
    UILabel *sendPromoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 310, self.view.width, 20)];
    sendPromoLabel.text = @"SEND YOUR PROMO CODE";
    sendPromoLabel.textAlignment = NSTextAlignmentCenter;
    sendPromoLabel.font = [ThemeManager lightFontOfSize:11];
    sendPromoLabel.textColor = [[ThemeManager sharedTheme] darkGrayColor];
    [self.view addSubview:sendPromoLabel];
    
    self.promoCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.view.width, 25)];
    self.promoCode.textAlignment = NSTextAlignmentCenter;
    self.promoCode.y = 335;
    self.promoCode.textColor = [[ThemeManager sharedTheme] redColor];
//    self.promoCode.textColor = [UIColor blackColor];
    self.promoCode.font = [ThemeManager boldFontOfSize:20];
    [self.view addSubview:self.promoCode];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor unnormalizedColorWithRed:178 green:178 blue:178 alpha:255].CGColor;
    bottomBorder.frame = CGRectMake(0, self.view.height - 3, self.view.width, 1.f);
    
    [self.view addSubview:self.prompt];
    
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.emailButton.size = CGSizeMake(self.view.width - 50, 35);
    self.emailButton.centerX = self.view.width/2;
    self.emailButton.y = 375;
    self.emailButton.layer.cornerRadius = 3;
    self.emailButton.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
    [self.emailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.emailButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.emailButton setTitle:@"EMAIL INVITE" forState:UIControlStateNormal];
    self.emailButton.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [self.emailButton addTarget:self action:@selector(emailButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.smsButton.size = CGSizeMake(self.view.width - 50, 35);
    self.smsButton.centerX = self.view.width/2;
    [self.smsButton setTitle:@"TEXT INVITE" forState:UIControlStateNormal];
    self.smsButton.y = 420;
    self.smsButton.layer.cornerRadius = 3;
    self.smsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    self.smsButton.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [self.smsButton addTarget:self action:@selector(smsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.smsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.smsButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.size = CGSizeMake(self.view.width - 50, 35);
    shareButton.centerX = self.view.width/2;
    [shareButton setTitle:@"Share on social media" forState:UIControlStateNormal];
    shareButton.y = 453;
    [shareButton setTitleColor:[[ThemeManager sharedTheme] lightBlueColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    shareButton.titleLabel.font = [ThemeManager lightFontOfSize:12];
    [shareButton addTarget:self action:@selector(shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.emailButton];
    [self.view addSubview:self.smsButton];
    [self.view addSubview:shareButton];
    
    [[APIClient sharedClient] getPromo:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *promoCode = responseObject[@"promo_code"];
        NSString *emailSubject = responseObject[@"email_subject"];
        NSString *emailBody = responseObject[@"email_body"];
        NSString *smsMessage = responseObject[@"sms_message"];
        
        self.promoCode.text = promoCode;
        
        self.emailModal = [[MFMailComposeViewController alloc] init];
        self.emailModal.mailComposeDelegate = self;
        [self.emailModal setSubject:emailSubject];
        [self.emailModal setMessageBody:emailBody isHTML:NO];
//        [mail setToRecipients:@[@"testingEmail@example.com"]];
        
        self.smsModal = [[MFMessageComposeViewController alloc] init];
        self.smsModal.messageComposeDelegate = self;
        //picker.recipients = [NSArray arrayWithObjects:@"1234", @"2345", nil];
        self.smsModal.body = smsMessage;
        
    } failure:nil];
}

//- (void)requestContactPermissions
//{
////    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//        if (granted) {
//            [self populateContacts];
//            [[ContactManager sharedManager] syncContacts];
//        } else {
//            [self populateContacts];
//        }
//    });
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
////    CGRect frame = CGRectMake(0, 0, 400, 44);
////    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:frame];
////    navTitleLabel.backgroundColor = [UIColor clearColor];
////    navTitleLabel.font = [ThemeManager mediumFontOfSize:17.0];
////    navTitleLabel.textAlignment = NSTextAlignmentCenter;
////    navTitleLabel.textColor = [UIColor whiteColor];
////    navTitleLabel.text = @"SELECT FRIENDS";
////    self.navigationItem.titleView = navTitleLabel;
////    if (self.deal) {
////        [self updateNavTitleForDeal:self.deal];
////    }
////    UIButton *groupsButton = [UIButton navButtonWithTitle:@"Groups"];
////    [groupsButton addTarget:self action:@selector(groupsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
////    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupsButton];
//    
//}

//- (void)groupsButtonTouched:(id)sender
//{
//    GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
//    [self.navigationController pushViewController:groupsViewController animated:YES];
//}

//- (void)setDeal:(Deal *)deal
//{
//    [self view];
//    _deal = deal;
//    //[self updateNavTitleForDeal:deal];
//    //self.composeMessageTextView.text = [self defaultInviteMessageForDeal:deal];
//    [self updateInviteButtonTextForDeal:nil];
//    
//    ABAuthorizationStatus contactAuthStatus = [ContactManager sharedManager].authorizationStatus;
//    if (contactAuthStatus == kABAuthorizationStatusDenied) {
//        [self skipButtonTouchedFromContactModal];
//    }
//}

//- (BOOL)customMessageExceedsMaxLength:(NSString *)customMessage
//{
//    NSInteger maxLength = 159 - [User loggedInUser].fullName.length;
//    return customMessage.length > maxLength;
//}

//- (NSString *)defaultInviteMessageForDeal:(Deal *)deal
//{
//    NSString *text = [NSString stringWithFormat:@"Hey! You should meet us at %@ at %@ %@. %@", deal.venue.name, self.date.formattedTime, self.date.formattedDay.lowercaseString, deal.invitePrompt];
//    if ([self customMessageExceedsMaxLength:text]) {
//        text = [NSString stringWithFormat:@"Hey! You should meet us at %@, at %@. %@", deal.venue.name, self.date.formattedTime.lowercaseString, self.deal.invitePrompt];
//    }
//    return text;
//}

//- (void) setTextMoreFriends:(BOOL)textMoreFriends
//{
//    if (textMoreFriends) {
//        self.skipButton.hidden = YES;
//    } else {
//        self.skipButton.hidden = NO;
//    }
//}

//- (void)updateNavTitleForDeal:(Deal *)deal
//{
//    CGRect frame = CGRectMake(0, 0, 400, 44);
//    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:frame];
//    navTitleLabel.backgroundColor = [UIColor clearColor];
//    navTitleLabel.font = [ThemeManager mediumFontOfSize:17.0];
//    navTitleLabel.textAlignment = NSTextAlignmentCenter;
//    navTitleLabel.textColor = [UIColor whiteColor];
//    NSString *navTitle = [[NSString alloc] init];
//    if (deal.inviteRequirement.integerValue <= 1) {
//        navTitle = [NSString stringWithFormat:@"SELECT FRIENDS"];
//    } else {
//        navTitle = [NSString stringWithFormat:@"SELECT %@ FRIENDS", deal.inviteRequirement];
//    }
//    navTitleLabel.text = navTitle;
//    self.navigationItem.titleView = navTitleLabel;
//    
//    
////    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:[NSString stringWithFormat:@"SELECT %@ FRIENDS!", deal.inviteRequirement]];
//}

//- (void)populateContacts
//{
//    self.suggestedList = @[];
//    self.nonSuggestedList = @[];
//    self.contactDictionary = [NSMutableDictionary new];
//    [[ContactManager sharedManager] fetchAddressBookContacts:^(NSArray *contacts) {
//        self.contactDictionary = [NSMutableDictionary new];
//        for (Contact *contact in contacts) {
//            [self.contactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
//        }
////        [[ContactManager sharedManager] getGroups:^(NSArray *groups) {
////            self.tableViewHeaderPool = nil;
////            self.groups = groups;
////            [self collapseGroupSections];
//            [self reloadData];
////        } failure:nil];
//        if (self.selectedContacts) {
//            for (Contact *contact in self.selectedContacts) {
//                [self.selectedContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
//            }
//        }
////        if (self.inactiveContacts) {
////            for (Contact *contact in self.inactiveContacts) {
////                [self.inactiveContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
////            }
////        }
//    } failure:^(NSError *error) {
//        NSLog(@"error %@",error);
//    }];
//}

//- (void)collapseGroupSections
//{
//    [self.collapsedSections removeAllObjects];
//    for (NSInteger i=0;i<self.groups.count;i++) {
//        [self.collapsedSections addObject:@(i)];
//    }
//}

//- (void)reloadData
//{
//    NSArray *allContacts = self.contactDictionary.allValues;
////    NSPredicate *allUsersPredicate = [NSPredicate predicateWithFormat:@"isAllUser = %d", YES];
////    self.usersInContactsList = [allContacts filteredArrayUsingPredicate:allUsersPredicate];
//    //separate users and nonusers
////    NSPredicate *recentPredicate = [NSPredicate predicateWithFormat:@"isRecent = %d", YES];
////    self.recentsList = [allContacts filteredArrayUsingPredicate:recentPredicate];
//    NSPredicate *suggestedPredicate = [NSPredicate predicateWithFormat:@"isSuggested = %d && isRecent = %d",YES, NO];
//    self.suggestedList = [allContacts filteredArrayUsingPredicate:suggestedPredicate];
//    self.nonSuggestedList = allContacts;
//    
//    //sort both lists by name
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
////    self.usersInContactsList = [self.usersInContactsList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    //self.recentsList = [self.recentsList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    [self.tableView reloadData];
//}

//- (void)reloadDataWithSearchText:(NSString *)searchText
//{
//    NSArray *allContacts = self.contactDictionary.allValues;
//    //separate users and nonusers
////    self.usersInContactsList = @[];
//    //self.recentsList = @[];
//    self.suggestedList = @[];
//    NSPredicate *nonsuggestedPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", searchText];
//    self.nonSuggestedList = [allContacts filteredArrayUsingPredicate:nonsuggestedPredicate];
//    
//    //sort both lists by name
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
////    self.usersInContactsList = [self.usersInContactsList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    //self.recentsList = [self.recentsList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    self.suggestedList = [self.suggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    self.nonSuggestedList = [self.nonSuggestedList sortedArrayUsingDescriptors:@[sortDescriptor]];
//    [self.tableView reloadData];
//}

//- (void)showInviteButton:(BOOL)animated
//{
//    if (self.inviteButtonShown) {
//        return;
//    }
//    self.inviteButtonShown = YES;
//    NSTimeInterval duration = animated ? 0.3 : 0.0;
//    [UIView animateWithDuration:duration animations:^{
//        self.inviteButton.transform = CGAffineTransformIdentity;
//        UIEdgeInsets insets = self.tableView.contentInset;
//        insets.bottom = self.inviteButton.frame.size.height;
//        self.tableView.contentInset = insets;
//    }];
//}
//
//- (void)hideInviteButton:(BOOL)animated
//{
//    if (!self.inviteButtonShown) {
//        return;
//    }
//    self.inviteButtonShown = NO;
//    self.inviteButton.transform = CGAffineTransformIdentity;
//    NSTimeInterval duration = animated ? 0.3 : 0.0;
//    [UIView animateWithDuration:duration animations:^{
//        self.inviteButton.transform = CGAffineTransformMakeTranslation(0, self.inviteButton.frame.size.height);
//        UIEdgeInsets insets = self.tableView.contentInset;
//        insets.bottom = 0;
//        self.tableView.contentInset = insets;
//    }];
//    self.tableView.contentInset = UIEdgeInsetsZero;
//}

//- (void)updateInviteButtonText:(Contact *)lastSelectedContact
//{
//    if (self.deal) {
//        [self updateInviteButtonTextForDeal:lastSelectedContact];
//        return;
//    }
//    NSString *inviteButtonText = @"INVITE FRIENDS";
//    if (self.selectedContactDictionary.count) {
//        Contact *contact = lastSelectedContact ? lastSelectedContact : [self.selectedContactDictionary.allValues firstObject];
//        if (self.selectedContactDictionary.count == 1) {
//            //inviteButtonText = [NSString stringWithFormat:@"INVITE %@", contact.firstName];
//        }
//        else {
//            //NSInteger otherCount = self.selectedContactDictionary.count - 1;
//            //NSString *plural = otherCount == 1 ? @"other" : @"others";
//            //inviteButtonText = [NSString stringWithFormat:@"INVITE %@ and %d %@", contact.firstName, otherCount, plural];
//        }
//    }
//    [self.sendMessage setTitle:inviteButtonText forState:UIControlStateNormal];
////    self.sendMessage.titleLabel.font = [ThemeManager boldFontOfSize:15];
//}

- (void)updateInviteButtonTextForDeal:(Contact *)lastSelectedContact
{
    [self.sendMessage setTitle:@"Send" forState:UIControlStateNormal];
    
    //UIImage *chevronImage = [UIImage imageNamed:@"whiteChevron"];
    //[self.inviteButton setImage:[UIImage imageNamed:@"whiteChevron"] forState:UIControlStateNormal];
    //self.inviteButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.inviteButton.frame.size.width - (chevronImage.size.width + 25.), 0., 0.);
    
}

//#pragma mark - Table view data source
//- (Group *)groupForSection:(NSInteger)section
//{
//    Group *group;
//    if (section < self.groups.count) {
//        group = self.groups[section];
//    }
//    return group;
//}

//- (BOOL)sectionIsCollapsed:(NSInteger)section
//{
//    return [self.collapsedSections containsObject:@(section)];
//}
//
//- (void)collapseSection:(NSInteger)section
//{
//    [self.collapsedSections addObject:@(section)];
//    NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
//    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
//    for (NSInteger i=0; i<numRowsExpanded; i++) {
//        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//    }
//    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
//}
//
//- (void)uncollapseSection:(NSInteger)section
//{
//    [self.collapsedSections removeObject:@(section)];
//    NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
//    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
//    for (NSInteger i=0; i<numRowsExpanded; i++) {
//        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//    }
//    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 105;
//    } else {
//        CGFloat height = self.inSearchMode ? 0 : tableView.rowHeight;
//        return height;
//    }
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section != self.promptContainer) {
//        if (self.inSearchMode) {
//            return nil;
//        }
//        if (!self.tableViewHeaderPool) {
//            self.tableViewHeaderPool = [NSMutableDictionary new];
//        }
//        NSString *key = @(section).stringValue;
//        if ([self.tableViewHeaderPool valueForKey:key]) {
//            return [self.tableViewHeaderPool valueForKey:key];
//        }
////        CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
//        view.backgroundColor = [UIColor whiteColor];
//        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 40)];
//        title.adjustsFontSizeToFitWidth = YES;
//        title.backgroundColor = [UIColor clearColor];
//        title.font = [ThemeManager boldFontOfSize:11.0];
//        title.textColor = [[ThemeManager sharedTheme] redColor];
////        title.textColor = [UIColor unnormalizedColorWithRed:240 green:110 blue:97 alpha:255];
//        [view addSubview:title];
//        title.text = [self tableView:tableView titleForHeaderInSection:section];
//        //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        //    CGRect buttonFrame = CGRectZero;
//        //    buttonFrame.size = CGSizeMake(height, height);
//        //    buttonFrame.origin.x = self.view.width - 60;
//        //    buttonFrame.origin.y = 0.5*(height - buttonFrame.size.height);
//        //    button.frame = buttonFrame;
//        //    [view addSubview:button];
//        //    [button setImage:[UIImage imageNamed:@"addFriendNormal"] forState:UIControlStateNormal];
//        //    [button setImage:[UIImage imageNamed:@"addFriendSelected"] forState:UIControlStateSelected];
//        //    [button addTarget:self action:@selector(selectAllButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        
//        //UILabel *contactCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.width - 32, height)];
//        //contactCountLabel.textAlignment = NSTextAlignmentRight;
//        //contactCountLabel.font = [ThemeManager lightFontOfSize:1.3*8];
//        //contactCountLabel.textColor = [UIColor whiteColor];
//        //NSInteger contactCount = [self tableView:tableView  numberOfRowsInExpandedSection:section];
//        //NSString *contactPlural = contactCount == 1 ? @"Contact" : @"Contacts";
//        //contactCountLabel.text = [NSString stringWithFormat:@"%d %@", contactCount, contactPlural];
//        //[view addSubview:contactCountLabel];
//        
//        [self.tableViewHeaderPool setValue:view forKey:key];
//        //[self setSelectAllButton:button forSection:section];
//        view.tag = section;
//        UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
//        [view addGestureRecognizer:headerTap];
//        return view;
//    } else {
//        //CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 105)];
//        
//        UIImageView *promptIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beerGlasses"]];
//        promptIcon.centerX = view.width/2;
//        promptIcon.y = 10;
//        [view addSubview:promptIcon];
//        
//        UILabel *promptHeading = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, view.width, 15)];
//        promptHeading.textAlignment = NSTextAlignmentCenter;
//        promptHeading.text = [[NSString stringWithFormat:@"GIVE A DRINK. GET A DRINK."] uppercaseString];
//        promptHeading.font = [ThemeManager boldFontOfSize:12];
//        
//        [view addSubview:promptHeading];
//        
//        self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.width - 50, 30)];
//        self.prompt.centerX = self.view.width/2;
//        self.prompt.y = 55;
//        self.prompt.font = [ThemeManager lightFontOfSize:12];
//        self.prompt.textColor = [UIColor blackColor];
//        self.prompt.numberOfLines = 2;
//        self.prompt.textAlignment = NSTextAlignmentCenter;
//        self.prompt.text = [NSString stringWithFormat:@"Select friends to invite them to Hotspot. When they join, you'll both get a free drink!"];
//        
//        CALayer *bottomBorder = [CALayer layer];
//        bottomBorder.backgroundColor = [UIColor unnormalizedColorWithRed:178 green:178 blue:178 alpha:255].CGColor;
//        bottomBorder.frame = CGRectMake(0, view.height - 3, view.width, 1.f);
//        
//        [view addSubview:self.prompt];
//        [view.layer addSublayer:bottomBorder];
//        return view;
//    }
//}

//- (void)setSelectAllButton:(UIButton *)button forSection:(NSInteger)section
//{
//    if (!self.selectAllButtonPool) {
//        self.selectAllButtonPool = [NSMutableDictionary new];
//    }
//    NSString *key = @(section).stringValue;
//    [self.selectAllButtonPool setValue:button forKey:key];
//}
//
//- (UIButton *)selectAllButtonForSection:(NSInteger)section
//{
//    return [self.selectAllButtonPool valueForKey:@(section).stringValue];
//}
//
//- (void)headerTapped:(UITapGestureRecognizer *)tap
//{
//    NSInteger section = tap.view.tag;
//    if ([self sectionIsCollapsed:section]) {
//        [self uncollapseSection:section];
//    }
//    else {
//        [self collapseSection:section];
//    }
//}

//- (void)selectAllButtonTouched:(UIButton *)button
//{
//    button.selected = !button.selected;
//    NSInteger section = [[self.selectAllButtonPool allKeysForObject:button][0] integerValue];
//    [self setSelected:button.selected forAllContactsInSection:section];
//}
//
//- (void)setSelected:(BOOL)selected forAllContactsInSection:(NSInteger)section
//{
//    NSArray *contactList;
////    Group *group = [self groupForSection:section];
////    if (group) {
////        contactList = group.contacts;
////    } else
////        
////    if (section == self.findFriendSectionAllUsers) {
////        contactList = self.usersInContactsList;
////    }
////    else if (section == self.findFriendSectionRecents) {
////        contactList = self.recentsList;
////    }
//    if (section == self.findFriendSectionSuggested) {
//        contactList = self.suggestedList;
//    }
//    else if (section == self.findFriendSectionContacts) {
//        contactList = self.nonSuggestedList;
//    }
//    for (Contact *contact in contactList) {
//        if (selected) {
//            [self selectContact:contact];
//        }
//        else {
//            [self unselectContact:contact];
//        }
//    }
//    UIButton *selectAllButton = [self.selectAllButtonPool valueForKey:@(section).stringValue];
//    selectAllButton.selected = selected;
//    CGFloat damping = selected ? 0.25 : 0.5;
//    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
//        selectAllButton.transform = selected ? selectedTransform : CGAffineTransformIdentity;
//    } completion:nil];
//    [self.tableView reloadData];
//}

//- (void)selectContact:(Contact *)contact
//{
////    BOOL contactInactive = [self.inactiveContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
////    if (contactInactive) {
////        return;
////    }
//
//    
//    [self.selectedContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
//    
//    if (self.selectedContactDictionary.count == 0) {
//        [UIView animateWithDuration:0.3 animations:^{  // animate the following:
//            //CGRect rect = self.skipButton.frame;
//            //rect.origin.y = self.view.height;
//            //self.skipButton.frame = rect;
//        } completion:^(BOOL finished){
//            [self updateMessageCount];
//        }];
//    } else {
//        [self updateMessageCount];
//    }
//    
////    NSLog(@"%lu", (unsigned long)self.selectedContactDictionary.count);
////    [self updateInviteButtonText:contact];
//}

//- (void) updateMessageCount
//{
//    
//    //self.messageCount.text = [NSString stringWithFormat:@"%lu Individual SMS", (unsigned long)self.selectedContactDictionary.count];
//    [self updateSendMessagePosition];
//}

//- (void)unselectContact:(Contact *)contact
//{
//    [self.selectedContactDictionary removeObjectForKey:contact.normalizedPhoneNumber];
//    
//    if (self.selectedContactDictionary.count == 0) {
//        [self updateMessageCount];
////        [UIView animateWithDuration:0.2 delay:.5 options:UIViewAnimationOptionCurveEaseOut animations:^{  // animate the following:
////            CGRect rect = self.skipButton.frame;
////            rect.origin.y = self.view.height - 35;
////            self.skipButton.frame = rect;
////        } completion:^(BOOL finished) {
////            NSLog(@"Skip Button Added");
////        }];
//    
////    [self updateInviteButtonText:nil];
//    }
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = @"";
////    Group *group = [self groupForSection:section];
////    if (group) {
////        title = group.name;
////    } else
////    if (section == self.findFriendSectionAllUsers) {
////        title = @"Friends on Hotspot";
////    }
////    else  if (section == self.findFriendSectionRecents) {
////        title = @"Recents";
////    }
//    if (section == self.findFriendSectionSuggested) {
//        title = @"Suggested";
//    }
//    else if (section == self.findFriendSectionContacts) {
//        title = @"Contacts";
//    }
//    
//    return title;
//}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger numRows = 0;
//    if ([self sectionIsCollapsed:section]) {
//        numRows = 0;
//    }
//    else {
//        numRows = [self tableView:tableView numberOfRowsInExpandedSection:section];
//    }
//    return numRows;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInExpandedSection:(NSInteger)section
//{
//    NSInteger numRows = 0;
////    Group *group = [self groupForSection:section];
////    if (group) {
////        Group *group = self.groups[section];
////        numRows = group.contacts.count;
////    } else
//    
////    if (section == self.findFriendSectionAllUsers) {
////        numRows = self.usersInContactsList.count;
////    }
////    else if (section == self.findFriendSectionRecents) {
////        numRows = self.recentsList.count;
////    }
//    if (section == self.findFriendSectionSuggested) {
//        numRows = self.suggestedList.count;
//    }
//    else if (section == self.findFriendSectionContacts) {
//        numRows = self.nonSuggestedList.count;
//    }
//    return numRows;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
//}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    BOOL found = NO;
//    NSInteger i = 0;
//    NSInteger newRow = 0;
//    while (!found && i < self.nonSuggestedList.count) {
//        Contact *contact = self.nonSuggestedList[i];
//        NSString *contactName = contact.firstName;
//        NSRange range = NSMakeRange(0, 1);
//        if (contactName.length && [[contactName substringWithRange:range] isEqualToString:title]) {
//            found = YES;
//            newRow = [self.nonSuggestedList indexOfObject:contact];
//        }
//        i++;
//    }
//    
//    if (found) {
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:self.findFriendSectionContacts];
//        [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    }
//    return index;
//}

//#define TAG_NAME_LABEL 2
//#define TAG_CHECK_IMAGE 3
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        UILabel *nameLabel = [[UILabel alloc] init];
//        CGRect frame = CGRectZero;
//        frame.size = CGSizeMake(160, tableView.rowHeight);
//        frame.origin.x = 15;
//        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
//        nameLabel.frame = frame;
//        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
//        nameLabel.backgroundColor = [UIColor clearColor];
//        nameLabel.textColor = [UIColor blackColor];
//        nameLabel.font = [ThemeManager lightFontOfSize:14];
//        nameLabel.adjustsFontSizeToFitWidth = YES;
//        nameLabel.tag = TAG_NAME_LABEL;
//        [cell.contentView addSubview:nameLabel];
//        
//        UIImageView *addFriendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriendNormal"]];
//        frame = addFriendImageView.frame;
//        frame.size = CGSizeMake(30, 30);
//        frame.origin.x = self.view.width - 60;
//        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
//        addFriendImageView.frame = frame;
//        addFriendImageView.contentMode = UIViewContentModeCenter;
//        addFriendImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
//        addFriendImageView.tag = TAG_CHECK_IMAGE;
//        [cell.contentView addSubview:addFriendImageView];
//    }
//    
//    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:TAG_NAME_LABEL];
//    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
//    NSString *normalizedPhoneNumber;
//    Contact *contact;
////    if (indexPath.section < self.groups.count) {
////        Group *group = self.groups[indexPath.section];
////        contact = group.contacts[indexPath.row];
////    }
//    if (!contact) {
////        if (indexPath.section == self.findFriendSectionRecents) {
////            contact = self.recentsList[indexPath.row];
////        } else
////        if (indexPath.section == self.findFriendSectionAllUsers) {
////            contact = self.usersInContactsList[indexPath.row];
////        }
//        if (indexPath.section == self.findFriendSectionSuggested) {
//            contact = self.suggestedList[indexPath.row];
//        }
//        else if (indexPath.section == self.findFriendSectionContacts) {
//            contact = self.nonSuggestedList[indexPath.row];
//        }
//
//    }
//    nameLabel.text = contact.fullName;
//    normalizedPhoneNumber = contact.normalizedPhoneNumber;
//    //BOOL contactInactive = [self.inactiveContactDictionary.allKeys containsObject:normalizedPhoneNumber];
//    BOOL contactSelected = [self.selectedContactDictionary.allKeys containsObject:normalizedPhoneNumber];
//    addFriendImageView.image = contactSelected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
//    cell.backgroundColor = contactSelected ? [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:.1]:[UIColor clearColor];
//    //addFriendImageView.transform = contactSelected ? selectedTransform : CGAffineTransformIdentity;
//    //addFriendImageView.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:.1];
////    if (contactInactive) {
////        nameLabel.textColor = [UIColor lightGrayColor];
////        addFriendImageView.image = [UIImage imageNamed:@"addFriendInactive"];
////        addFriendImageView.transform = CGAffineTransformIdentity;
////        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1];
////    }
//    //else {
//        nameLabel.textColor = [UIColor blackColor];
//    //}
//    return cell;
//}

//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Contact *contact;
////    if (indexPath.section < self.groups.count) {
////        Group *group = self.groups[indexPath.section];
////        contact = group.contacts[indexPath.row];
////    }
////    else
////    if (indexPath.section == self.findFriendSectionAllUsers) {
////        contact = self.usersInContactsList[indexPath.row];
////    }
////    else if (indexPath.section == self.findFriendSectionRecents) {
////        contact = self.recentsList[indexPath.row];
////    }
//    if (indexPath.section == self.findFriendSectionSuggested) {
//        contact = self.suggestedList[indexPath.row];
//    }
//    else if (indexPath.section == self.findFriendSectionContacts) {
//        contact = self.nonSuggestedList[indexPath.row];
//    }
//    
////    BOOL inactiveContact = [self.inactiveContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
////    if (inactiveContact) {
////        NSString *message = [NSString stringWithFormat:@"%@ has already been invited", contact.fullName];
////        [[[UIAlertView alloc] initWithTitle:@"Friends don't spam friends" message:message delegate:nil cancelButtonTitle:@"I'm Sorry" otherButtonTitles:nil] show];
////        return;
////    }
//    
//    BOOL currentlySelected = [self.selectedContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
//    if (currentlySelected) {
//        [self unselectContact:contact];
//    }
//    else {
//        [self selectContact:contact];
//    }
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [self animateSelectingContactInCell:cell selected:!currentlySelected completion:^{
//        [self.tableView reloadData];
//        if (self.inSearchMode) {
//            [self exitSearchMode];
//        }
//    }];
//}

//- (void)animateSelectingContactInCell:(UITableViewCell *)cell selected:(BOOL)selected completion:(void(^) ())completion
//{
//    UIImage *image = selected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
//    cell.backgroundColor = selected ? [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:.1]:[UIColor clearColor];
//    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
//    addFriendImageView.image = image;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [self exitSearchMode];
//    });
//
////    CGFloat damping = selected ? 0.25 : 0.5;
////    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
////        addFriendImageView.transform = selected ? selectedTransform : CGAffineTransformIdentity;
////        [cell layoutIfNeeded];
////    } completion:^(BOOL finished) {
////        if (completion) {
////            completion();
////        }
////    }];
//}

//#pragma mark - UISearchBarDelegate
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (searchText.length) {
//        [self reloadDataWithSearchText:searchText];
//    }
//    else {
//        [self reloadData];
//    }
//}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [self.searchBar endEditing:YES];
//    [self reloadDataWithSearchText:searchBar.text];
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    [self exitSearchMode];
//}
//
//- (void)exitSearchMode
//{
//    self.inSearchMode = NO;
//    self.searchBar.text = nil;
//    [self.searchBar endEditing:YES];
//    [self reloadData];
//}

//#pragma mark - Text View Delegate
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    self.modifiedMessage = YES;
//    NSString *resultantText = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    if ([self customMessageExceedsMaxLength:resultantText] && resultantText.length > textView.text.length) {
//        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your message is over the character limit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        return NO;
//    }
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//    }
//    return YES;
//}


//#pragma mark - buttons
//- (void)doneButtonTouched:(id)sender
//{
//   if ([self.delegate respondsToSelector:@selector(findFriendViewController:didPickContacts:andMessage:andDate:)]) {
//        [self.delegate findFriendViewController:self didPickContacts:self.selectedContactDictionary.allValues andMessage:self.composeMessageTextView.text andDate:self.date];
//    }
//}
//
//- (void)inviteButtonTouched:(id)sender
//{
////    if ([self.delegate respondsToSelector:@selector(findFriendViewController:didPickContacts:andMessage:andDate:)]) {
////        [self.delegate findFriendViewController:self didPickContacts:self.selectedContactDictionary.allValues andMessage:self.composeMessageTextView.text andDate:self.date];
////    }
//    
////    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
////    [[APIClient sharedClient] inviteFriendsToApp:self.selectedContactDictionary.allValues customMessage:self.composeMessageTextView.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
////        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
////        [self dismissViewControllerAnimated:YES completion:nil];
////    } failure:nil];
//    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
//    NSArray *selectedContacts = [self.selectedContactDictionary allKeys];
//    [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self messageRecipients:selectedContacts withMessage:self.smsMessage success:^(BOOL success) {
//        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
//    } failure:nil];
//    
//}

//- (void)resetDate
//{
//    //round date to nearest 15 min
//    NSDate *now = [NSDate date];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate: now];
//    NSInteger minutesToSubract = (comps.minute % 5);
//    if (minutesToSubract) {
//        self.date = [now dateByAddingTimeInterval:-60*minutesToSubract];
//    }
//    else {
//        self.date = now;
//    }
//    //self.dateLabel.text = @"Now (tap to change)";
//    [self.tableView reloadData];
//}

//#pragma mark - Keyboard
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    NSDictionary* info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    self.animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
//    self.keyboardHeight = kbSize.height;
//    
//    if (!self.isVisible) {
//        return;
//    }
//    
//    self.isKeyboardShowing = YES;
//
//    [self updateSendMessagePosition];
//    
//    self.inSearchMode = YES;
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    if (!self.isVisible) {
//        return;
//    }
//    
//    self.isKeyboardShowing = NO;
//    
//    [self updateSendMessagePosition];
//    
//    [self.searchBar setShowsCancelButton:NO animated:YES];
//}

//- (void)skipButtonTouched:(id)sender
//{
//    if (![self.deal isAvailableAtDate:self.date]) {
//        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
//        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }
//    else {
//        NSArray *noContact = [[NSArray alloc] init];
//        [self setBeaconOnServerWithInvitedContacts:noContact andMessage:@" " andDate:self.date];
//    }
//}

//- (void)setBeaconOnServerWithInvitedContacts:(NSArray *)contacts andMessage:(NSString *)message andDate:(NSDate *)date
//{
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    UIView *view = appDelegate.window.rootViewController.view;
//    MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
//    [[APIClient sharedClient] applyForDeal:self.deal invitedContacts:contacts customMessage:message time:date imageUrl:@"" success:^(Beacon *beacon) {
//        [loadingIndicator hide:YES];
//        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
//    } failure:^(NSError *error) {
//        [loadingIndicator hide:YES];
//        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }];
//}
//
//- (void) updateSendMessagePosition
//{
//    
//    [UIView animateWithDuration:0.3 animations:^{  // animate the following:
//        CGRect rect = self.sendMessageContainer.frame;
//        if (self.isKeyboardShowing) {
//            if (self.selectedContactDictionary.count > 0) {
//                rect.origin.y = self.view.height - self.keyboardHeight - 55;
//            } else {
//                rect.origin.y = self.view.height - self.keyboardHeight;
//            }
//        } else {
//            if (self.selectedContactDictionary.count > 0) {
//                rect.origin.y = self.view.height - 55;
//            } else {
//                rect.origin.y = self.view.height;
//            }
//        }
//        self.sendMessageContainer.frame = rect;
//    }];
//}

//-(void)setViewMovedUp:(BOOL)movedUp
//{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:self.animationDuration]; // if you want to slide up the view
//    
//    CGRect rect = self.sendMessageContainer.frame;
//    if (movedUp)
//    {
//        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
//        // 2. increase the size of the view so that the area behind the keyboard is covered up.
//        rect.origin.y = self.view.height;
////        rect.size.height += kOFFSET_FOR_KEYBOARD;
//    } else {
//        // revert back to the normal state.
//        rect.origin.y = self.view.height - 120;
////        rect.size.height -= kOFFSET_FOR_KEYBOARD;
//    }
//    self.sendMessageContainer.frame = rect;
//    
//    [UIView commitAnimations];
//}
//
//-(void)showSendMessageContainer:(BOOL)show
//{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:.3]; // if you want to slide up the view
//    
//    CGRect rect = self.sendMessageContainer.frame;
//    if (show)
//    {
//        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
//        // 2. increase the size of the view so that the area behind the keyboard is covered up.
//        rect.origin.y -= self.sendMessageContainer.height;
//        //        rect.size.height += kOFFSET_FOR_KEYBOARD;
//    }
//    else
//    {
//        // revert back to the normal state.
//        rect.origin.y += self.sendMessageContainer.height;
//        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
//    }
//    self.sendMessageContainer.frame = rect;
//    
//    [UIView commitAnimations];
//    
//    //self.showSendMessage = show;
//}

//- (void)showDatePicker
//{
//    DatePickerModalView *datePicker = [[DatePickerModalView alloc] init];
//    datePicker.datePicker.date = [NSDate date];
//    datePicker.datePicker.minuteInterval = 15;
//    [datePicker.datePicker addTarget:self action:@selector(datePickerUpdated:) forControlEvents:UIControlEventValueChanged];
//    [datePicker show];
//}

//- (void)datePickerUpdated:(UIDatePicker *)datePicker
//{
//    self.date = datePicker.date;
//    self.dateLabel.text = self.date.fullFormattedDate;
//    if (!self.modifiedMessage) {
//        self.composeMessageTextView.text = [self defaultInviteMessageForDeal:self.deal];
//    }
//}

//- (void)dateViewTap:(id)sender
//{
//    [self showDatePicker];
//}

//- (void)skipButtonTouchedFromContactModal
//{
//    if (![self.deal isAvailableAtDate:self.date]) {
//        
//        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
//        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Sorry" message:message];
//        [alertView bk_setCancelButtonWithTitle:@"OK" handler:^{
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }];
//        [alertView show];
//        
////        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
////        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }
//    else {
//        NSArray *noContact = [[NSArray alloc] init];
//        [self setBeaconOnServerWithInvitedContacts:noContact andMessage:@" " andDate:self.date];
//    }
//}

- (void)smsButtonTouched:(id)sender
{
    [self presentViewController:self.smsModal animated:YES completion:nil];
}

- (void)emailButtonTouched:(id)sender
{
    [self presentViewController:self.emailModal animated:YES completion:NULL];
    
}

-(void)shareButtonTouched:(id)sender
{
    NSArray *objectsToShare = @[self.smsMessage];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeMessage,
                                   UIActivityTypeMail];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
