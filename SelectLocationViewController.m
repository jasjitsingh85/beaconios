//
//  SelectLocationViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/6/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SelectLocationViewController.h"
#import "LocationTracker.h"
#import "FourSquareAPIClient.h"
#import "Venue.h"
#import "Theme.h"

@interface SelectLocationViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSString *customLocation;
@end

@implementation SelectLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.venues = [NSArray new];
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.tintColor = [[ThemeManager sharedTheme] cyanColor];
    [self enableSearchBarCancelButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self searchForVenues];
}

- (void)searchForVenues
{
    CLLocation *location = [LocationTracker sharedTracker].currentLocation;
    NSString *query = self.searchBar.text ? self.searchBar.text : @"";
    [[FourSquareAPIClient sharedClient] searchVenuesNearLocation:location query:query radius:@10000 limit:@20 completion:^(id response, NSError *error) {
        if (!error) {
            [self parseVenuesFromFourSquareResponse:response];
            [self.tableView reloadData];
        }
    }];
}

//search we use the cancel button to dismiss the viewcontroller we always want it enabled.
//by default the cancel button of a search bar is only enabled when the search bar contains text
- (void)enableSearchBarCancelButton
{
    for (UIView *possibleButton in self.searchBar.subviews)
    {
        if ([possibleButton isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

- (void)parseVenuesFromFourSquareResponse:(NSDictionary *)response
{
    NSArray *venueData = response[@"groups"][0][@"items"];
    NSMutableArray *venues = [NSMutableArray new];
    for (NSDictionary *item in venueData) {
        Venue *venue = [[Venue alloc] initWithData:item];
        [venues addObject:venue];
    }
    self.venues = venues;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[self indexPathForCurrentLocation]]) {
        [self currentLocationSelected];
    }
    else if ([indexPath isEqual:[self indexPathForCustomLocation]]) {
        [self customLocationSelected];
    }
    else {
        Venue *venue = self.venues[indexPath.row - [self indexPathForFirstVenue].row];
        [self venueSelected:venue];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)currentLocationSelected
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCurrentLocation)]) {
        [self.delegate didSelectCurrentLocation];
    }
}

- (void)customLocationSelected
{
    if ([self.delegate respondsToSelector:@selector(didSelectCustomLocation:)]) {
        [self.delegate didSelectCustomLocation:self.customLocation];
    }
}

- (void)venueSelected:(Venue *)venue
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectVenue:)]) {
        [self.delegate didSelectVenue:venue];
    }
}


#pragma mark - UITableViewDataSource
- (BOOL)shouldShowCustomLocation
{
    NSInteger minCustomLocationLength = 1;
    return self.customLocation && self.customLocation.length >= minCustomLocationLength;
}

- (BOOL)shouldShowCurrentLocation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSIndexPath *)indexPathForCurrentLocation
{
    NSInteger currentLocationIndex = -1;
    if ([self shouldShowCurrentLocation]) {
        currentLocationIndex = 0;
    }
    return [NSIndexPath indexPathForRow:currentLocationIndex inSection:0];
}

- (NSIndexPath *)indexPathForCustomLocation
{
    NSInteger customLocationIndex = -1;
    if ([self shouldShowCurrentLocation] && [self shouldShowCustomLocation]) {
        customLocationIndex = 1;
    }
    else if ([self shouldShowCustomLocation]) {
        customLocationIndex = 0;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:customLocationIndex inSection:0];
    return indexPath;
}

- (NSIndexPath *)indexPathForFirstVenue
{
    NSInteger venueIndexOffset = [self shouldShowCustomLocation] + [self shouldShowCurrentLocation];
    return [NSIndexPath indexPathForRow:venueIndexOffset inSection:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.venues.count + [self shouldShowCurrentLocation] + [self shouldShowCustomLocation];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [ThemeManager regularFontOfSize:14.0];
    }
    
    if ([indexPath isEqual:[self indexPathForCurrentLocation]]) {
        cell.textLabel.text = @"Current Location";
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else if ([indexPath isEqual:[self indexPathForCustomLocation]]) {
        cell.textLabel.text = self.customLocation;
        cell.textLabel.textColor = [[ThemeManager sharedTheme] orangeColor];
    }
    else {
        NSIndexPath *firstVenueIndexPath = [self indexPathForFirstVenue];
        Venue *venue = self.venues[indexPath.row - firstVenueIndexPath.row];
        cell.textLabel.text = venue.name;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.customLocation = searchText;
    [self searchForVenues];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
