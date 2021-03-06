//
//  InviteListViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/14/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "InviteListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BeaconStatus.h"
#import "Theme.h"

@interface InviteListViewController ()

@property (strong, nonatomic) UIButton *inviteButton;

@end

@implementation InviteListViewController

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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
//    UIView *inviteButtonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 61 - 240, self.view.width, 61)];
//    inviteButtonBackground.backgroundColor = [UIColor whiteColor];
//    inviteButtonBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    [self.view addSubview:inviteButtonBackground];
//    self.inviteButton = [[UIButton alloc] init];
//    self.inviteButton.size = CGSizeMake(249, 35);
//    self.inviteButton.centerX = inviteButtonBackground.width/2.0;
//    self.inviteButton.centerY = inviteButtonBackground.height/2.0;
//    self.inviteButton.backgroundColor = [[ThemeManager sharedTheme] blueColor];
//    self.inviteButton.titleLabel.font = [ThemeManager mediumFontOfSize:17];
//    [self.inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.inviteButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//    [self.inviteButton addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [inviteButtonBackground addSubview:self.inviteButton]; 
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setBeaconStatuses:(NSArray *)beaconStatuses
{
    //make sure beacon statuses are sorted
    NSMutableArray *here = [[NSMutableArray alloc] init];
    NSMutableArray *going = [[NSMutableArray alloc] init];
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    for (BeaconStatus *status in beaconStatuses) {
        if (status.beaconStatusOption == BeaconStatusOptionHere) {
            [here addObject:status];
        }
        else if (status.beaconStatusOption == BeaconStatusOptionGoing) {
            [going addObject:status];
        }
        else if (status.beaconStatusOption == BeaconStatusOptionInvited) {
            [invited addObject:status];
        }
    }
    NSMutableArray *statuses = [[NSMutableArray alloc] initWithCapacity:here.count + going.count + invited.count];
    [statuses addObjectsFromArray:here];
    [statuses addObjectsFromArray:going];
    [statuses addObjectsFromArray:invited];
    _beaconStatuses = statuses;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (self.beaconStatuses && self.beaconStatuses.count) {
        numRows = self.beaconStatuses.count;
        NSLog(@"num rows: %ld", (long)numRows);
    }
    return numRows;
}

#define TAG_STATUS_LABEL 1

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.tag = TAG_STATUS_LABEL;
        CGRect statusLabelFrame;
        statusLabelFrame.size = CGSizeMake(55, 30);
        statusLabelFrame.origin.x = 245;
        statusLabelFrame.origin.y = 0.5*(cell.contentView.frame.size.height - statusLabelFrame.size.height);
        statusLabel.frame = statusLabelFrame;
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        statusLabel.font = [ThemeManager regularFontOfSize:12];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:statusLabel];
        cell.textLabel.font = [ThemeManager regularFontOfSize:17];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    BeaconStatus *beaconStatus = self.beaconStatuses[indexPath.row];
    if (beaconStatus.user) {
        cell.textLabel.text = beaconStatus.user.fullName;
    }
    else if (beaconStatus.contact) {
        cell.textLabel.text = beaconStatus.contact.fullName;
    }
    
    UILabel *statusLabel = (UILabel *)[cell viewWithTag:TAG_STATUS_LABEL];
    if (beaconStatus.beaconStatusOption == BeaconStatusOptionGoing) {
        statusLabel.text = @"Going";
        statusLabel.font = [ThemeManager regularFontOfSize:12];
        statusLabel.backgroundColor = [UIColor colorWithRed:251/255.0 green:175/255.0 blue:92/255.0 alpha:1.0];
    }
    else if (beaconStatus.beaconStatusOption == BeaconStatusOptionHere) {
        statusLabel.text = @"Here";
        statusLabel.font = [ThemeManager regularFontOfSize:12];
        statusLabel.backgroundColor = [UIColor colorWithRed:130/255.0 green:202/255.0 blue:157/255.0 alpha:1.0];
    }
    else if (beaconStatus.beaconStatusOption == BeaconStatusOptionInvited) {
        statusLabel.text = @"Invited";
        statusLabel.font = [ThemeManager italicFontOfSize:12];
        statusLabel.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconStatus *beaconStatus = self.beaconStatuses[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(inviteListViewController:didSelectBeaconStatus:)]) {
        [self.delegate inviteListViewController:self didSelectBeaconStatus:beaconStatus];
    }
}

@end
