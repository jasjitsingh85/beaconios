//
//  MenuViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

typedef enum {
    MenuTableViewRowHome=0,
    MenuTableViewRowFind,
    MenuTableViewRowSettings,
    MenuTableViewRowLogout,
} MenuTableViewRows;

@interface MenuViewController ()

@end

@implementation MenuViewController

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

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuBackground"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (CGFloat)visibleTableViewWidth
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CGFloat visibleWidth = self.view.frame.size.width - appDelegate.sideNavigationViewController.leftSize;
    return visibleWidth;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [self tableViewCellWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell ForIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
	
	
	picker.displayedProperties = displayedItems;
	// Show the picker
	[self presentViewController:picker animated:YES completion:nil];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [peoplePicker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell Customization
#define ICON_IMAGE_TAG 1
#define TEXT_LABEL_TAG 3
- (UITableViewCell *)tableViewCellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    //set up image view
    CGRect frame = CGRectZero;
    frame.size.height = 28;
    frame.size.width = 28;
    frame.origin.y = 0.5*(self.tableView.rowHeight - frame.size.height);
    frame.origin.x = 19;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = ICON_IMAGE_TAG;
    [cell.contentView addSubview:imageView];
    
    
    //set up name label
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = TEXT_LABEL_TAG;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    frame = CGRectZero;
    frame.size.width = [self visibleTableViewWidth];
    frame.size.height = self.tableView.rowHeight;
    frame.origin.x = 0;
    frame.origin.y = 0.5*(self.tableView.rowHeight - frame.size.height);
    label.frame = frame;
    [cell.contentView addSubview:label];
    
    UIImageView *hairlineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hairline"]];
    frame = hairlineImageView.frame;
    frame.origin.y = CGRectGetHeight(cell.contentView.frame) - frame.size.height;
    hairlineImageView.frame = frame;
    hairlineImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [cell.contentView addSubview:hairlineImageView];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell ForIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:ICON_IMAGE_TAG];
    UILabel *label = (UILabel *)[cell viewWithTag:TEXT_LABEL_TAG];
    if (indexPath.row == MenuTableViewRowHome) {
        
    }
    else if (indexPath.row == MenuTableViewRowFind) {
        label.text = @"Account";
        imageView.image = [UIImage imageNamed:@"menuButtonAccount"];
    }
    else if (indexPath.row == MenuTableViewRowSettings) {
        label.text = @"Favorites";
        imageView.image = [UIImage imageNamed:@"menuButtonFavorite"];
    }
    else if (indexPath.row == MenuTableViewRowLogout) {
        label.text = @"Logout";
        imageView.image = [UIImage imageNamed:@"menuButtonLogout"];
    }
}


@end
