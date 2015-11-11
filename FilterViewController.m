//
//  FindFriendsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FilterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "GroupsViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UIButton+HSNavButton.h"
#import <UIKit/UIKit.h>

@interface FilterViewController () <UISearchBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSMutableSet *collapsedSections;
@property (readonly) NSInteger labelHeader;
@property (readonly) NSInteger hotspotToggle;
@property (readonly) NSInteger happyHourToggle;

@end

#define selectedTransform CGAffineTransformMakeScale(1.35, 1.35)

@implementation FilterViewController

- (NSMutableSet *)collapsedSections
{
    if (!_collapsedSections) {
        _collapsedSections = [[NSMutableSet alloc] init];
    }
    return _collapsedSections;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Filter";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)labelHeader
{
    return 0;
}

- (NSInteger)hotspotToggle
{
    return 1;
}

- (NSInteger)happyHourToggle
{
    return 2;
}

- (BOOL)sectionIsCollapsed:(NSInteger)section
{
    return [self.collapsedSections containsObject:@(section)];
}

- (void)collapseSection:(NSInteger)section
{
    [self.collapsedSections addObject:@(section)];
    NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<numRowsExpanded; i++) {
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
}

- (void)uncollapseSection:(NSInteger)section
{
    [self.collapsedSections removeObject:@(section)];
    NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<numRowsExpanded; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    if (section==self.labelHeader) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 40)];
        title.adjustsFontSizeToFitWidth = YES;
        title.backgroundColor = [UIColor clearColor];
        title.font = [ThemeManager boldFontOfSize:11.0];
        title.textColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        [view addSubview:title];
        title.text = @"Filter By";
        return view;
    } else if (section == self.hotspotToggle || self.happyHourToggle) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 40)];
        title.adjustsFontSizeToFitWidth = YES;
        title.backgroundColor = [UIColor clearColor];
        title.font = [ThemeManager mediumFontOfSize:13.0];
        title.textColor = [UIColor blackColor];
        [view addSubview:title];
        title.text = [self tableView:tableView titleForHeaderInSection:section];
        //[self setSelectAllButton:button forSection:section];
        view.tag = section;
        UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
        [view addGestureRecognizer:headerTap];
        return view;
    } else {
        return nil;
    }
}

- (void)headerTapped:(UITapGestureRecognizer *)tap
{
    NSInteger section = tap.view.tag;
    if ([self sectionIsCollapsed:section]) {
        [self uncollapseSection:section];
    }
    else {
        [self collapseSection:section];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == self.hotspotToggle) {
        title = @"Hotspots";
    }
    else if (section == self.happyHourToggle) {
        title = @"Happy Hours";
    }
    return title;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if ([self sectionIsCollapsed:section]) {
        numRows = 0;
    }
    else {
        numRows = [self tableView:tableView numberOfRowsInExpandedSection:section];
    }
    return numRows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInExpandedSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == self.hotspotToggle || section == self.happyHourToggle) {
        numRows = 1;
    }
    return numRows;
}

#define TAG_NAME_LABEL 2
#define TAG_CHECK_IMAGE 3
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(160, tableView.rowHeight);
        frame.origin.x = 15;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        nameLabel.frame = frame;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [ThemeManager lightFontOfSize:14];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.tag = TAG_NAME_LABEL;
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *addFriendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriendNormal"]];
        frame = addFriendImageView.frame;
        frame.size = CGSizeMake(30, 30);
        frame.origin.x = self.view.width - 60;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        addFriendImageView.frame = frame;
        addFriendImageView.contentMode = UIViewContentModeCenter;
        addFriendImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        addFriendImageView.tag = TAG_CHECK_IMAGE;
        [cell.contentView addSubview:addFriendImageView];
    }
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:TAG_NAME_LABEL];
    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
    NSString *normalizedPhoneNumber;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
