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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setBeaconStatuses:(NSArray *)beaconStatuses
{
    _beaconStatuses = beaconStatuses;
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
        statusLabelFrame.size = CGSizeMake(45, 20);
        statusLabelFrame.origin.x = 255;
        statusLabelFrame.origin.y = 0.5*(cell.contentView.frame.size.height - statusLabelFrame.size.height);
        statusLabel.frame = statusLabelFrame;
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        statusLabel.font = [ThemeManager regularFontOfSize:10];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.textColor = [UIColor whiteColor];
        statusLabel.layer.cornerRadius = 2;
        [cell.contentView addSubview:statusLabel];
    }
    
    BeaconStatus *beaconStatus = self.beaconStatuses[indexPath.row];
    if (beaconStatus.user) {
        cell.textLabel.text = [beaconStatus.user fullName];
    }
    else if (beaconStatus.contact) {
        cell.textLabel.text = beaconStatus.contact.firstName;
    }
    
    UILabel *statusLabel = (UILabel *)[cell viewWithTag:TAG_STATUS_LABEL];
    if (beaconStatus.beaconStatusOption == BeaconStatusOptionGoing) {
        statusLabel.text = @"Going";
        statusLabel.backgroundColor = [UIColor colorWithRed:251/255.0 green:175/255.0 blue:92/255.0 alpha:1.0];
    }
    else if (beaconStatus.beaconStatusOption == BeaconStatusOptionHere) {
        statusLabel.text = @"Here";
        statusLabel.backgroundColor = [UIColor colorWithRed:130/255.0 green:202/255.0 blue:157/255.0 alpha:1.0];
    }
    else if (beaconStatus.beaconStatusOption == BeaconStatusOptionInvited) {
        statusLabel.text = @"Invited";
        statusLabel.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
