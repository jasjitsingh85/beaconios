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
#import "Theme.h"
#import "BeaconUserCell.h"
#import "Utilities.h"

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
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    self.tableView.layer.cornerRadius = 4;
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setBeacon:(Beacon *)beacon
{
    _beacon = beacon;
    //it's possible for this to be set before view is created so force creation of view
    [self view];
    self.titleLabel.text = [NSString stringWithFormat:@"%@'s Beacon",beacon.creator.firstName];
    self.beaconDescriptionLabel.text = beacon.beaconDescription;
    
    //change table view height depending on how many elements it will have
    CGFloat height = self.tableView.rowHeight*[self tableView:self.tableView numberOfRowsInSection:0];
    if (height > kMaxTableHeight) {
        height = kMaxTableHeight;
    }
    CGRect frame = self.tableView.frame;
    frame.size.height = height;
    self.tableView.frame = frame;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (self.beacon && self.beacon.creator) {
        numRows++;
    }
    if (self.beacon && self.beacon.confirmedGuests) {
        numRows += self.beacon.confirmedGuests.count;
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
    }
    cell.beacon = self.beacon;
    User *user;
    if (indexPath.row == 0) {
        user = self.beacon.creator;
    }
    cell.user = user;
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



@end
