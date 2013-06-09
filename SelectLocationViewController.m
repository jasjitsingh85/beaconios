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
    [self enableSearchBarCancelButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self searchForVenues];
}

- (void)searchForVenues
{
    CLLocation *location = [LocationTracker sharedTracker].locationManager.location;
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
        Venue *venue = [Venue new];
        venue.name = item[@"name"];
        [venues addObject:venue];
    }
    self.venues = venues;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self currentLocationSelected];
    }
    else {
        Venue *venue = self.venues[indexPath.row - 1];
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

- (void)venueSelected:(Venue *)venue
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectVenue:)]) {
        [self.delegate didSelectVenue:venue];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [ThemeManager regularFontOfSize:14.0];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Current Location";
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else {
        Venue *venue = self.venues[indexPath.row - 1];
        cell.textLabel.text = venue.name;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchForVenues];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
