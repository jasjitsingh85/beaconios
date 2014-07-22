//
//  DealDetailViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/30/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DealDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UIView+Shadow.h"
#import "NSDate+FormattedDate.h"
#import "AppDelegate.h"
#import "LoadingIndictor.h"
#import "Venue.h"
#import "DatePickerModalView.h"
#import "FindFriendsViewController.h"
#import "ExplanationPopupView.h"
#import "Beacon.h"
#import "User.h"
#import "APIClient.h"
#import "AnalyticsManager.h"

const NSInteger maxCustomMessageLength = 159;

@interface DealDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, FindFriendsViewControllerDelegate>

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *imageOverlay;
@property (strong, nonatomic) UILabel *venueLabel;
@property (assign, nonatomic) CGFloat imageViewNaturalHeight;
@property (strong, nonatomic) UIButton *inviteFriendsButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIFont *headerFont;
@property (strong, nonatomic) UIFont *detailFont;
@property (strong, nonatomic) UITextView *customMessageTextView;

@end

@implementation DealDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerFont = [ThemeManager lightFontOfSize:1.3*12];
    self.detailFont = [ThemeManager lightFontOfSize:1.3*13];
    self.view.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    
    self.imageViewNaturalHeight = 160;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.imageViewNaturalHeight)];
    [self.view addSubview:self.headerView];
    self.imageView = [[UIImageView alloc] initWithFrame:self.headerView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.headerView addSubview:self.imageView];
    self.imageOverlay = [[UIView alloc] initWithFrame:self.imageView.bounds];
    self.imageOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.imageOverlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.imageView addSubview:self.imageOverlay];
    
    self.venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 126, 200, 20)];
    self.venueLabel.font = [ThemeManager regularFontOfSize:1.3*14];
    self.venueLabel.textColor = [UIColor whiteColor];
    [self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1.0) shouldDrawPath:NO];
    [self.headerView addSubview:self.venueLabel];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.clipsToBounds = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(self.imageView.height, 0, 0, 0);
    [self.view insertSubview:self.tableView belowSubview:self.imageView];
    
    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inviteFriendsButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
    self.inviteFriendsButton.size = CGSizeMake(self.view.width, 84);
    self.inviteFriendsButton.bottom = self.view.height;
    self.inviteFriendsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inviteFriendsButton];
    
    UILabel *inviteFriendsLabel = [[UILabel alloc] init];
    inviteFriendsLabel.size = CGSizeMake(283, 33);
    inviteFriendsLabel.centerX = self.inviteFriendsButton.width/2.0;
    inviteFriendsLabel.bottom = self.inviteFriendsButton.height - 13;
    inviteFriendsLabel.text = @"Get Deal!";
    inviteFriendsLabel.font = [ThemeManager lightFontOfSize:1.3*15];
    inviteFriendsLabel.textAlignment = NSTextAlignmentCenter;
    inviteFriendsLabel.textColor = [UIColor colorWithRed:133/255.0 green:193/255.0 blue:255/255.0 alpha:1.0];
    inviteFriendsLabel.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    inviteFriendsLabel.layer.cornerRadius = 4;
    inviteFriendsLabel.clipsToBounds = YES;
    [self.inviteFriendsButton addSubview:inviteFriendsLabel];
    
    UILabel *readyLabel = [[UILabel alloc] init];
    readyLabel.size = CGSizeMake(self.inviteFriendsButton.width, self.inviteFriendsButton.height - inviteFriendsLabel.y);
    readyLabel.textColor = [[ThemeManager sharedTheme] boneWhiteColor];
    readyLabel.text = @"Ready to get this deal?";
    readyLabel.font = [ThemeManager lightFontOfSize:1.3*10];
    readyLabel.textAlignment = NSTextAlignmentCenter;
    [self.inviteFriendsButton addSubview:readyLabel];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.imageView.height, 0, self.inviteFriendsButton.height, 0);
//    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.imageView.height - self.inviteFriendsButton.height);
//    self.tableView.y = self.imageView.bottom;
    [self.view bringSubviewToFront:self.imageView];
    [self.view bringSubviewToFront:self.inviteFriendsButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.deal) {
        [[AnalyticsManager sharedManager] viewedDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name];
    }
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
    [self view];
    _deal = deal;
    [self resetDate];
    self.venueLabel.text = deal.venue.name;
    [self.imageView setImageWithURL:deal.venue.imageURL];
    [self.tableView reloadData];
}

- (void)showExplanationPopup
{
    ExplanationPopupView *explanationPopupView = [[ExplanationPopupView alloc] init];
    NSString *address = self.deal.venue.name;
    NSString *inviteText = [NSString stringWithFormat:@"%@ invited you to redeem a group deal at %@. Join and %@", [User loggedInUser].firstName, address, self.deal.inviteDescription];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:inviteText];
    [attributedText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[inviteText rangeOfString:address]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[inviteText rangeOfString:address]];
    explanationPopupView.attributedInviteText = attributedText;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasShownDealExplanation]) {
        [explanationPopupView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasShownDealExplanation];
    }
}

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
    [self.tableView reloadData];
}

- (void)datePickerUpdated:(UIDatePicker *)datePicker
{
    self.date = datePicker.date;
    [self.tableView reloadData];
}

- (void)inviteFriendsButtonTouched:(id)sender
{
    if (![self.deal isAvailableAtDate:self.date]) {
        NSString *message = [NSString stringWithFormat:@"This deal is only available %@", self.deal.hoursAvailableString];
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:nil message:@"Type a message"];
        if (!self.customMessageTextView) {
            self.customMessageTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 250, 130)];
            self.customMessageTextView.delegate = self;
            self.customMessageTextView.font = [ThemeManager regularFontOfSize:12*1.3];
            self.customMessageTextView.backgroundColor = [UIColor clearColor];
        }
        self.customMessageTextView.text = [NSString stringWithFormat:@"Hey! You should meet us at %@ (%@), at %@ %@. I'm inviting you through this app, so you %@", self.deal.venue.name, self.deal.venue.address, self.date.formattedTime.lowercaseString, self.date.formattedDay.lowercaseString, self.deal.inviteDescription];
        if (self.customMessageTextView.text.length > maxCustomMessageLength) {
            self.customMessageTextView.text = [NSString stringWithFormat:@"Hey! You should meet us at %@, at %@. I'm inviting you through this app, so you %@", self.deal.venue.name, self.date.formattedTime.lowercaseString, self.deal.inviteDescription];
        }
        self.customMessageTextView.backgroundColor = [UIColor whiteColor];
        self.customMessageTextView.layer.cornerRadius = 8;
        self.customMessageTextView.layer.borderColor = [UIColor grayColor].CGColor;
        self.customMessageTextView.layer.borderWidth = 0.5;
        [alertView setValue:self.customMessageTextView forKey:@"accessoryView"];
        [alertView bk_addButtonWithTitle:@"Cancel" handler:nil];
        [alertView bk_setCancelButtonWithTitle:@"Select Friends" handler:^{
            [self selectFriends];
        }];
        [alertView bk_setDidShowBlock:^(UIAlertView *a) {
            [self.customMessageTextView becomeFirstResponder];
        }];
        [alertView show];
    }
}

- (void)selectFriends
{
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
    findFriendsViewController.delegate = self;
    findFriendsViewController.deal = self.deal;
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
    [[AnalyticsManager sharedManager] invitedFriendsDeal:self.deal.dealID.stringValue withPlaceName:self.deal.venue.name];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = scrollView.contentOffset.y + self.imageViewNaturalHeight;
    if (yOffset <= 0) {
        CGFloat desiredHeight = self.imageViewNaturalHeight + ABS(yOffset);
        CGFloat scale = desiredHeight/self.imageViewNaturalHeight;
        self.headerView.transform = CGAffineTransformIdentity;
        self.imageView.transform = CGAffineTransformIdentity;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, ABS(yOffset)/2.0);
        transform = CGAffineTransformScale(transform, scale, scale);
        self.imageView.transform = transform;
        [self.view insertSubview:self.headerView aboveSubview:self.tableView];
        CGFloat minOffSet = -32.0;
        CGFloat opacity = 1 - yOffset/minOffSet;
        [self setImageSubViewOpacity:opacity];
    }
    else {
        self.headerView.transform = CGAffineTransformMakeTranslation(0, -yOffset);
        [self.view insertSubview:self.tableView aboveSubview:self.headerView];
    }
}

- (void)setImageSubViewOpacity:(CGFloat)opacity
{
    NSArray *subviews = @[self.imageOverlay, self.venueLabel];
    for (UIView *view in subviews) {
        view.alpha = opacity;
    }
}

#pragma mark - table view controller

- (NSInteger)bonusRow
{
    return self.deal.bonusRequirement ? 1 : -1;
}

- (NSInteger)timePickerRow
{
    return self.deal.bonusRequirement ? 2 : 1;
}

- (CGFloat)tableViewHeight
{
    NSInteger lastSection = [self numberOfSectionsInTableView:self.tableView] - 1;
    NSInteger lastRow = [self tableView:self.tableView numberOfRowsInSection:lastSection] - 1;
    CGRect lastRowRect= [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:lastSection]];
    CGFloat contentHeight = lastRowRect.origin.y + lastRowRect.size.height;
    return contentHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 88;
    if (!indexPath.row) {
        height = [self.deal.dealDescription boundingRectWithSize:CGSizeMake(self.view.width - 70, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.detailFont} context:nil].size.height;
        height += 40;
    }
    else if (self.deal.bonusRequirement && indexPath.row == [self bonusRow]) {
        height = [self.deal.bonusDescription boundingRectWithSize:CGSizeMake(self.view.width - 70, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.detailFont} context:nil].size.height;
        height += 40;
    }
    else if (indexPath.row == [self timePickerRow]) {
        height = 88;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deal.bonusRequirement ? 3 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.indentationWidth = 1;
    cell.indentationLevel = 17;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [[ThemeManager sharedTheme] boneWhiteColor];
    cell.detailTextLabel.font = self.detailFont;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:102/255.0 green:100/255.0 blue:98/255.0 alpha:1.0];
    cell.textLabel.font = self.headerFont;
    cell.textLabel.textColor = [[ThemeManager sharedTheme] redColor];
    if (!indexPath.row) {
        cell.textLabel.text = @"Here's the deal:";
        cell.detailTextLabel.text = self.deal.dealDescription;
        cell.detailTextLabel.numberOfLines = 0;
    }
    else if (indexPath.row == [self bonusRow]) {
        cell.textLabel.text = @"Bonus deal:";
        cell.detailTextLabel.text = self.deal.bonusDescription;
        cell.detailTextLabel.numberOfLines = 0;
        
    }
    else if (indexPath.row == [self timePickerRow]) {
        cell.textLabel.text = @"Pick a time:";
        cell.detailTextLabel.text = self.date.fullFormattedDate;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self tableView:tableView numberOfRowsInSection:0] - 1) {
        [cell addEdge:UIRectEdgeBottom width:0.5 color:[UIColor colorWithWhite:190/255.0 alpha:1.0]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row) {
        [[[UIAlertView alloc] initWithTitle:nil message:self.deal.additionalInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    if (indexPath.row == [self timePickerRow]) {
        DatePickerModalView *datePicker = [[DatePickerModalView alloc] init];
        datePicker.datePicker.date = [NSDate date];
        datePicker.datePicker.minuteInterval = 15;
        [datePicker.datePicker addTarget:self action:@selector(datePickerUpdated:) forControlEvents:UIControlEventValueChanged];
        [datePicker show];
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
        NSString *message = [NSString stringWithFormat:@"Invite %d more friends to unlock deal", self.deal.inviteRequirement.integerValue - contacts.count];
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)setBeaconOnServerWithInvitedContacts:(NSArray *)contacts
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIView *view = appDelegate.window.rootViewController.view;
    MBProgressHUD *loadingIndicator = [LoadingIndictor showLoadingIndicatorInView:view animated:YES];
    [[APIClient sharedClient] applyForDeal:self.deal invitedContacts:contacts customMessage:self.customMessageTextView.text time:self.date success:^(Beacon *beacon) {
        [loadingIndicator hide:YES];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setSelectedViewControllerToBeaconProfileWithBeacon:beacon];
    } failure:^(NSError *error) {
        [loadingIndicator hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *resultantText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (resultantText.length > maxCustomMessageLength && resultantText.length > textView.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your message is over the character limit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

@end
