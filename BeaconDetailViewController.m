//
//  BeaconDetailViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "Beacon.h"
#import "User.h"
#import "Contact.h"
#import "Theme.h"
#import "BeaconUserCell.h"
#import "Utilities.h"
#import "TextMessageManager.h"
#import "APIClient.h"
#import "AppDelegate.h"

#define kMaxTableHeight 227
@interface BeaconDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UIButton *directionsButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *groupMessageButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *beaconDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSDictionary *attendingContactDictionary;

@end

@implementation BeaconDetailViewController

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
    [ThemeManager customizeViewAndSubviews:self.view];
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    self.tableView.layer.cornerRadius = 4;
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.beaconDescriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.addressLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    //it's possible for this to be set before view is created so force creation of view
    [self view];

    if (beacon.isUserBeacon) {
        self.titleLabel.text = @"My Beacon";
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@'s Beacon", beacon.creator.firstName];
    }
    self.navigationItem.title = self.titleLabel.text;
    self.beaconDescriptionLabel.text = beacon.beaconDescription;
    
    //change table view height depending on how many elements it will have
    CGFloat height = self.tableView.rowHeight*[self tableView:self.tableView numberOfRowsInSection:0];
    if (height > kMaxTableHeight) {
        height = kMaxTableHeight;
    }
    CGRect frame = self.tableView.frame;
    frame.size.height = height;
    self.tableView.frame = frame;
    
    NSMutableDictionary *attendingContactDictionary = [NSMutableDictionary new];
    for (Contact *contact in beacon.attending) {
        [attendingContactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
    }
    self.attendingContactDictionary = [NSDictionary dictionaryWithDictionary:attendingContactDictionary];
    self.confirmButton.selected = self.beacon.userAttending;
    if (self.beacon.address) {
        self.addressLabel.text = self.beacon.address;
    }
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"hh:mm a";
    self.timeLabel.text = [timeFormatter stringFromDate:self.beacon.time];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (self.beacon && self.beacon.creator) {
        numRows++;
    }
    if (self.beacon && self.beacon.invited) {
        numRows += self.beacon.invited.count;
    }
    return numRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BeaconUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BeaconUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.beacon = self.beacon;
    User *user;
    if (indexPath.row == 0) {
        user = self.beacon.creator;
        cell.user = user;
        cell.isAttending = YES;
    }
    else {
        Contact *contact = self.beacon.invited[indexPath.row - 1];
        cell.contact = contact;
        cell.isAttending = [self.attendingContactDictionary.allKeys containsObject:contact.normalizedPhoneNumber];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    User *user;
//    if (indexPath.row == 0) {
//        user = self.beacon.creator;
//    }
//    UILabel *
}

#pragma mark - UITableViewDelegate

#pragma mark - Button Events
- (IBAction)directionsButtonTouched:(id)sender
{
    NSDictionary *addressDictionary;
    if (self.beacon.address) {
//        addressDictionary=
    }
    [Utilities launchMapDirectionsToCoordinate:self.beacon.coordinate addressDictionary:addressDictionary destinationName:self.beacon.beaconDescription];
}

- (IBAction)textMessageButtonTouched:(id)sender
{
    [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self messageRecipients:@[self.beacon.creator.phoneNumber]];
}

- (IBAction)groupTextMessageButtonTouched:(id)sender
{
    NSMutableSet *invitedNumbers = [NSMutableSet new];
    for (Contact *contact in self.beacon.invited) {
        [invitedNumbers addObject:contact.normalizedPhoneNumber];
    }
    //also add creator
    [invitedNumbers addObject:self.beacon.creator.normalizedPhoneNumber];
    //remove user from this set
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [invitedNumbers removeObject:appDelegate.loggedInUser.normalizedPhoneNumber];
    [[TextMessageManager sharedManager] presentMessageComposeViewControllerFromViewController:self messageRecipients:invitedNumbers.allObjects];
}
- (IBAction)confirmButtonTouched:(id)sender
{
    self.confirmButton.selected = !self.confirmButton.selected;
    BOOL confirmed = self.confirmButton.selected;
    if (confirmed && !self.beacon.userAttending) {
        self.beacon.userAttending = YES;
        [[APIClient sharedClient] confirmBeacon:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[[UIAlertView alloc] initWithTitle:@"Confirmed" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Fail" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        }];
    }
    else if (!confirmed && self.beacon.userAttending){
        if (self.beacon.isUserBeacon) {
            [[[UIAlertView alloc] initWithTitle:@"This is your own beacon" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        }
        else {
            self.beacon.userAttending = NO;
            [[APIClient sharedClient] cancelBeacon:self.beacon.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[[UIAlertView alloc] initWithTitle:@"You have left this beacon" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Fail" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
            }];
        }
    }
    self.confirmButton.selected = self.beacon.userAttending;
}

@end
