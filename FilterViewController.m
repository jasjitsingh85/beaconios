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
@property (readonly) NSInteger nowAndUpcomingToggle;


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
    
    UIButton *cancelButton = [UIButton navButtonWithTitle:@"Cancel"];
    [cancelButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIButton *applyButton = [UIButton navButtonWithTitle:@"Apply"];
    [applyButton addTarget:self action:@selector(dismissViewAndApplyFilter:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:applyButton];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    
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

- (NSInteger)nowAndUpcomingToggle
{
    return 3;
}

//- (BOOL)sectionIsCollapsed:(NSInteger)section
//{
//    return [self.collapsedSections containsObject:@(section)];
//}

//- (void)collapseSection:(NSInteger)section
//{
//    if (![self sectionIsCollapsed:section]) {
//        [self.collapsedSections addObject:@(section)];
//        NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
//        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
//        for (NSInteger i=0; i<numRowsExpanded; i++) {
//            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//        }
//        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
//
//- (void)uncollapseSection:(NSInteger)section
//{
//    if ([self sectionIsCollapsed:section]) {
//        [self.collapsedSections removeObject:@(section)];
//        NSInteger numRowsExpanded = [self tableView:self.tableView numberOfRowsInExpandedSection:section];
//        NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
//        for (NSInteger i=0; i<numRowsExpanded; i++) {
//            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//        }
//        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

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
    } else if (section == self.hotspotToggle || section == self.happyHourToggle) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 40)];
        title.adjustsFontSizeToFitWidth = YES;
        title.backgroundColor = [UIColor clearColor];
        title.font = [ThemeManager mediumFontOfSize:13.0];
        title.textColor = [UIColor blackColor];
        [view addSubview:title];
        title.text = [self tableView:tableView titleForHeaderInSection:section];
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.width - 70, 5, 100, 30)];
        switchView.on = YES;
        switchView.transform = CGAffineTransformMakeScale(0.85, .8);
        switchView.tag = section;
        switchView.onTintColor = [[ThemeManager sharedTheme] redColor];
        [switchView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:switchView];
        view.tag = section;
//        UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
//        [view addGestureRecognizer:headerTap];
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.width, .5f)];
        topBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
        [view addSubview:topBorder];
        
        if (self.happyHourToggle) {
            UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 40, view.width, .5f)];
            bottomBorder.backgroundColor = [[ThemeManager sharedTheme] darkGrayColor];
            [view addSubview:bottomBorder];
        }
        
        return view;
    } else if (section == self.nowAndUpcomingToggle) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        view.backgroundColor = [UIColor clearColor];
        UIButton *nowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nowButton.size = CGSizeMake(150, 30);
        nowButton.x = self.view.width/2 - 149.5;
        nowButton.y = 10;
        nowButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
        nowButton.layer.borderWidth = 1;
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:nowButton.bounds
                                         byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerTopLeft)
                                               cornerRadii:CGSizeMake(2.0, 2.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = nowButton.bounds;
        maskLayer.path = maskPath.CGPath;
        nowButton.layer.mask = maskLayer;
        nowButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
        [nowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nowButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [nowButton setTitle:@"NOW" forState:UIControlStateNormal];
        nowButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
        [nowButton addTarget:self action:@selector(nowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *upcomingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        upcomingButton.size = CGSizeMake(150, 30);
        upcomingButton.x = self.view.width/2 - .5;
        upcomingButton.y = 10;
        upcomingButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
        upcomingButton.layer.borderWidth = 1;
        UIBezierPath *maskPathUpcoming;
        maskPathUpcoming = [UIBezierPath bezierPathWithRoundedRect:upcomingButton.bounds
                                                 byRoundingCorners:(UIRectCornerBottomRight|UIRectCornerTopRight)
                                                       cornerRadii:CGSizeMake(2.0, 2.0)];
        CAShapeLayer *maskLayerUpcoming = [[CAShapeLayer alloc] init];
        maskLayerUpcoming.frame = upcomingButton.bounds;
        maskLayerUpcoming.path = maskPathUpcoming.CGPath;
        upcomingButton.layer.mask = maskLayerUpcoming;
        upcomingButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
        [upcomingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [upcomingButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [upcomingButton setTitle:@"UPCOMING" forState:UIControlStateNormal];
        upcomingButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
        [upcomingButton addTarget:self action:@selector(upcomingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *middleBorder = [[UIView alloc] initWithFrame:CGRectMake(self.view.width/2 - .25, 11, 1, upcomingButton.frame.size.height - 2)];
        middleBorder.backgroundColor = [UIColor whiteColor];
        
        [view addSubview:nowButton];
        [view addSubview:upcomingButton];
        [view addSubview:middleBorder];
        return view;
    } else {
        return nil;
    }
}

//- (void)headerTapped:(UITapGestureRecognizer *)tap
//{
//    NSInteger section = tap.view.tag;
//    [self collapseOrUncollapseSection:section];
//}

//-(void)collapseOrUncollapseSection:(NSInteger)section
//{
//    if ([self sectionIsCollapsed:section]) {
//        [self uncollapseSection:section];
//    }
//    else {
//        [self collapseSection:section];
//    }
//}

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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
//    if ([self sectionIsCollapsed:section]) {
//        numRows = 0;
//    }
//    else {
//        numRows = [self tableView:tableView numberOfRowsInExpandedSection:section];
//    }
    return numRows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInExpandedSection:(NSInteger)section
{
//    NSInteger numRows = 0;
//    if (section == self.hotspotToggle || section == self.happyHourToggle) {
//        numRows = 1;
//    }
//    return numRows;
    return 0;
}

#define TAG_NAME_LABEL 2
#define TAG_CHECK_IMAGE 3
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        UIButton *nowButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        nowButton.size = CGSizeMake(150, 30);
//        nowButton.x = self.view.width/2 - 149.5;
//        nowButton.y = 5;
//        nowButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
//        nowButton.layer.borderWidth = 1;
//        UIBezierPath *maskPath;
//        maskPath = [UIBezierPath bezierPathWithRoundedRect:nowButton.bounds
//                                         byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerTopLeft)
//                                               cornerRadii:CGSizeMake(2.0, 2.0)];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = nowButton.bounds;
//        maskLayer.path = maskPath.CGPath;
//        nowButton.layer.mask = maskLayer;
//        nowButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
//        [nowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [nowButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        [nowButton setTitle:@"NOW" forState:UIControlStateNormal];
//        nowButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        nowButton.tag = indexPath.section;
//        [nowButton addTarget:self action:@selector(nowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIButton *upcomingButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        upcomingButton.size = CGSizeMake(150, 30);
//        upcomingButton.x = self.view.width/2 - .5;
//        upcomingButton.y = 5;
//        upcomingButton.layer.borderColor = [[ThemeManager sharedTheme] redColor].CGColor;
//        upcomingButton.layer.borderWidth = 1;
//        UIBezierPath *maskPathUpcoming;
//        maskPathUpcoming = [UIBezierPath bezierPathWithRoundedRect:upcomingButton.bounds
//                                         byRoundingCorners:(UIRectCornerBottomRight|UIRectCornerTopRight)
//                                               cornerRadii:CGSizeMake(2.0, 2.0)];
//        CAShapeLayer *maskLayerUpcoming = [[CAShapeLayer alloc] init];
//        maskLayerUpcoming.frame = upcomingButton.bounds;
//        maskLayerUpcoming.path = maskPathUpcoming.CGPath;
//        upcomingButton.layer.mask = maskLayerUpcoming;
//        upcomingButton.backgroundColor = [[ThemeManager sharedTheme] redColor];
//        [upcomingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [upcomingButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        [upcomingButton setTitle:@"UPCOMING" forState:UIControlStateNormal];
//        upcomingButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        upcomingButton.tag = indexPath.section;
//        [upcomingButton addTarget:self action:@selector(upcomingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIView *middleBorder = [[UIView alloc] initWithFrame:CGRectMake(self.view.width/2 - .25, 6, 1, upcomingButton.frame.size.height - 2)];
//        middleBorder.backgroundColor = [UIColor whiteColor];
//        
//        [cell.contentView addSubview:nowButton];
//        [cell.contentView addSubview:upcomingButton];
//        [cell.contentView addSubview:middleBorder];
//    }
//    return cell;
//}

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}

-(void)nowButtonTapped:(UIButton *)nowButton {
    
//    if (nowButton.tag == self.hotspotToggle) {
    self.now = !self.now;
    [self updateButton:nowButton onState:self.now];
//    } else if (nowButton.tag == self.happyHourToggle) {
//        self.isHappyHourNow = !self.isHappyHourNow;
//        [self updateButton:nowButton onState:self.isHappyHourNow];
//    }
}

-(void)upcomingButtonTapped:(UIButton *)upcomingButton {
    
//    if (upcomingButton.tag == self.hotspotToggle) {
    self.upcoming = !self.upcoming;
    [self updateButton:upcomingButton onState:self.upcoming];
//    } else if (upcomingButton.tag == self.happyHourToggle) {
//        self.isHappyHourUpcoming = !self.isHappyHourUpcoming;
//        [self updateButton:upcomingButton onState:self.isHappyHourUpcoming];
//    }
}

-(void)updateButton:(UIButton *)button onState:(BOOL)active
{
    if (active) {
        button.backgroundColor = [[ThemeManager sharedTheme] redColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    }
}

- (void)updateSwitchAtIndexPath:(UISwitch *)_switch{
    if ([_switch isOn]) {
        if (_switch.tag == self.hotspotToggle) {
            self.isHotspotToggleOn = YES;
        } else if (_switch.tag == self.happyHourToggle) {
            self.isHappyHourToggleOn = YES;
        }
    } else {
        if (_switch.tag == self.hotspotToggle) {
            self.isHotspotToggleOn = NO;
        } else if (_switch.tag == self.happyHourToggle) {
            self.isHappyHourToggleOn = NO;
        }
    }
//    [self reloadRowsAndSections];
    
}

//-(void)reloadRowsAndSections
//{
//    if (self.isHotspotToggleOn) {
//        [self uncollapseSection:self.hotspotToggle];
//    } else {
//        [self collapseSection:self.hotspotToggle];
//    }
//    
//    if (self.isHappyHourToggleOn) {
//        [self uncollapseSection:self.happyHourToggle];
//    } else {
//        [self collapseSection:self.happyHourToggle];
//    }
//    
//}

-(void)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissViewAndApplyFilter:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kApplyFilterNotification object:self userInfo:nil];
    }];
}

@end
