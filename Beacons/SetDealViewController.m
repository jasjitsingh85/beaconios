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

typedef NS_ENUM(NSUInteger, DealSection)  {
    DealSectionDescription,
    DealSectionInviteMessage,
    DealSectionTime,
    DealSectionInvite
};

@interface SetDealViewController () <UITextViewDelegate>

@property (strong, nonatomic) UIView *dealDescriptionView;
@property (strong, nonatomic) UIView *dealContentView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *venueLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIView *descriptionBackground;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *descriptionDetailLabel;

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

@property (strong, nonatomic) NSDate *date;


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
    self.view.backgroundColor = [UIColor colorWithWhite:230/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.dealDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 218)];
    self.dealContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dealDescriptionView.width, 210)];
    [self.dealDescriptionView addSubview:self.dealContentView];
    [self.dealContentView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.height = 157;
    self.imageView.width = self.view.width;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.dealContentView addSubview:self.imageView];
    
    self.venueLabel = [[UILabel alloc] init];
    self.venueLabel.width = self.view.width - 40;
    self.venueLabel.centerX = self.view.width/2.0;
    self.venueLabel.height = 92;
    self.venueLabel.centerY = 80;
    self.venueLabel.font = [ThemeManager boldFontOfSize:19*1.3];
    self.venueLabel.textColor = [UIColor whiteColor];
    [self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabel.textAlignment = NSTextAlignmentCenter;
    self.venueLabel.numberOfLines = 0;
    [self.dealContentView addSubview:self.venueLabel];
    
    self.descriptionBackground = [[UIView alloc] init];
    self.descriptionBackground.size = CGSizeMake(self.view.width, self.dealContentView.height - self.imageView.height);
    self.descriptionBackground.bottom = self.dealContentView.height;
    self.descriptionBackground.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.dealContentView addSubview:self.descriptionBackground];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.height = 10;
    self.descriptionLabel.width = self.view.width - 40;
    self.descriptionLabel.centerX = self.descriptionBackground.width/2.0;
    self.descriptionLabel.font = [ThemeManager boldFontOfSize:1.3*12];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.numberOfLines = 2;
    [self.descriptionBackground addSubview:self.descriptionLabel];
    
    self.composeMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 165)];
    self.composeMessageContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 157)];
    self.composeMessageContentView.backgroundColor = [UIColor whiteColor];
    [self.composeMessageContentView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    [self.composeMessageView addSubview:self.composeMessageContentView];
    
    self.composeMessageTitleLabel = [[UILabel alloc] init];
    self.composeMessageTitleLabel.height = 40;
    self.composeMessageTitleLabel.x = 21;
    self.composeMessageTitleLabel.width = self.composeMessageContentView.width - self.composeMessageTitleLabel.x;
    self.composeMessageTitleLabel.text = @"Message to friends:";
    self.composeMessageTitleLabel.textColor = [UIColor blackColor];
    self.composeMessageTitleLabel.font = [ThemeManager regularFontOfSize:1.3*11];
    [self.composeMessageContentView addSubview:self.composeMessageTitleLabel];
    
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor colorWithWhite:229/255.0 alpha:1.0];
    divider.width = self.composeMessageContentView.width;
    divider.height = 0.5;
    divider.y = 40;
    [self.composeMessageView addSubview:divider];
    
    self.composeMessageTextView = [[UITextView alloc] init];
    self.composeMessageTextView.width = self.composeMessageContentView.width;
    self.composeMessageTextView.height = 117;
    self.composeMessageTextView.bottom = self.composeMessageContentView.height;
    self.composeMessageTextView.textContainerInset = UIEdgeInsetsMake(8, 19, 8, 19);
    self.composeMessageTextView.font = [ThemeManager regularFontOfSize:1.3*11];
    self.composeMessageTextView.textColor = [UIColor blackColor];
    self.composeMessageTextView.delegate = self;
    self.composeMessageTextView.returnKeyType = UIReturnKeyDone;
    [self.composeMessageContentView addSubview:self.composeMessageTextView];
    
    self.dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    self.dateContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dateView.width, 47)];
    self.dateContentView.backgroundColor = [UIColor whiteColor];
    [self.dateContentView setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:1 offset:CGSizeMake(0, 1) shouldDrawPath:YES];
    [self.dateView addSubview:self.dateContentView];
    
    self.dateTitleLabel = [[UILabel alloc] init];
    self.dateTitleLabel.height = self.dateContentView.height;
    self.dateTitleLabel.x = self.composeMessageTitleLabel.x;
    self.dateTitleLabel.width = self.dateContentView.width - self.dateTitleLabel.x;
    self.dateTitleLabel.font = self.composeMessageTitleLabel.font;
    self.dateTitleLabel.textColor = self.composeMessageTitleLabel.textColor;
    self.dateTitleLabel.text = @"When:";
    [self.dateContentView addSubview:self.dateTitleLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.height = self.dateContentView.height;
    self.dateLabel.x = 90;
    self.dateLabel.width = self.dateContentView.width - self.dateLabel.x;
    self.dateLabel.textColor = [UIColor colorWithWhite:171/255.0 alpha:1.0];
    self.dateLabel.font = self.dateTitleLabel.font;
    [self.dateContentView addSubview:self.dateLabel];
    
    self.inviteFriendsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54)];
    self.inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inviteFriendsButton.size = CGSizeMake(250, 35);
    self.inviteFriendsButton.centerX = self.inviteFriendsView.width/2.0;
    self.inviteFriendsButton.centerY = self.inviteFriendsView.height/2.0;
    self.inviteFriendsButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.inviteFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    self.inviteFriendsButton.titleLabel.font = [ThemeManager regularFontOfSize:1.3*15];
    [self.inviteFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.inviteFriendsView addSubview:self.inviteFriendsButton];
}

- (void)setDeal:(Deal *)deal
{
    _deal = deal;
    [self view];
    [self resetDate];
    [self.imageView setImageWithURL:deal.venue.imageURL];
    self.venueLabel.text = deal.venue.name;
    self.descriptionLabel.text = deal.dealDescriptionShort;
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.centerX = self.descriptionBackground.width/2.0;
    self.descriptionLabel.y = 8;
    self.descriptionBackground.height = self.descriptionLabel.height + 40;
    self.descriptionBackground.bottom = self.dealContentView.height;
    
    self.descriptionDetailLabel = [[UILabel alloc] init];
    self.descriptionDetailLabel.width = self.view.width - 40;
    self.descriptionDetailLabel.font = [ThemeManager lightFontOfSize:1.3*11];
    self.descriptionDetailLabel.textColor = [UIColor whiteColor];
    self.descriptionDetailLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionDetailLabel.text = @"(They don't even have to show up)";
    [self.descriptionDetailLabel sizeToFit];
    self.descriptionDetailLabel.centerX = self.descriptionBackground.width/2.0;
    self.descriptionDetailLabel.y = self.descriptionLabel.bottom + 4;
    [self.descriptionBackground addSubview:self.descriptionDetailLabel];
    
    self.composeMessageTextView.text = [self defaultInviteMessageForDeal:deal];
    
    [self.tableView reloadData];
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
    self.dateLabel.text = @"Now";
    [self.tableView reloadData];
}

- (void)datePickerUpdated:(UIDatePicker *)datePicker
{
    self.date = datePicker.date;
    self.dateLabel.text = self.date.fullFormattedDate;
}

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
    if (indexPath.row == DealSectionTime) {
        [self showDatePicker];
    }
}

#pragma mark - Text View Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
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

@end
