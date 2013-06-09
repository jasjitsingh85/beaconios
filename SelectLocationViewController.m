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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    [searchBar resignFirstResponder];
}

#pragma mark - keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification;
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
@end
