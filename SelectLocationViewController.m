//
//  SelectLocationViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/6/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "SelectLocationViewController.h"
#import <FormatterKit/TTTLocationFormatter.h>
#import "LocationTracker.h"
#import "FourSquareAPIClient.h"
#import "Venue.h"
#import "Theme.h"
#import "NavigationBarTitleLabel.h"
#import "Utilities.h"

@interface SelectLocationViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSString *customLocation;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (assign, nonatomic) BOOL keyboardShown;
@property (strong, nonatomic) TTTLocationFormatter *locationFormatter;
@property (strong, nonatomic) NSString *currentLocationAddress;
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
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.venues = [NSArray new];
    self.headerView.backgroundColor = [[ThemeManager sharedTheme] redColor];
    self.tableView.rowHeight = 71;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    
    self.locationFormatter = [[TTTLocationFormatter alloc] init];
    self.locationFormatter.unitSystem = TTTImperialSystem;
    
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[LocationTracker sharedTracker].currentLocation.coordinate.latitude longitude:[LocationTracker sharedTracker].currentLocation.coordinate.longitude];
    [Utilities reverseGeoCodeLocation:location completion:^(NSString *addressString, NSError *error) {
        self.currentLocationAddress = addressString;
        jadispatch_main_qeue(^{
            [self.tableView reloadData];
        });
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self searchForVenues];
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"Pick a Place"];
}

- (void)searchForVenues
{
    CLLocation *location = [LocationTracker sharedTracker].currentLocation;
    NSString *query = self.searchBar.text ? self.searchBar.text : @"";
    [[FourSquareAPIClient sharedClient] searchVenuesNearLocation:location query:query radius:@30000 limit:@20 completion:^(id response, NSError *error) {
        if (!error) {
            [self parseVenuesFromFourSquareResponse:response];
            [self.tableView reloadData];
        }
    }];
}

- (void)parseVenuesFromFourSquareResponse:(NSDictionary *)response
{
    NSArray *venueData = response[@"venues"];
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
    else if ([indexPath isEqual:[self indexPathForToBeDetermined]]) {
        [self toBeDeterminedSelected];
    }
    else {
        Venue *venue = self.venues[indexPath.row - [self indexPathForFirstVenue].row];
        [self venueSelected:venue];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)currentLocationSelected
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCurrentLocation)]) {
        [self.delegate didSelectCurrentLocation];
    }
}

- (void)customLocationSelected
{
    if ([self.delegate respondsToSelector:@selector(didSelectCustomLocation:withName:)]) {
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:[LocationTracker sharedTracker].currentLocation.coordinate radius:50000 identifier:@"Region"];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder geocodeAddressString:self.customLocation inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error || !placemarks.count) {
                [self.delegate didSelectCustomLocation:nil withName:self.customLocation];
            }
            else {
                CLPlacemark *placemark = placemarks[0];
                [self.delegate didSelectCustomLocation:placemark.location withName:self.customLocation];
            }
        }];
    }
}

- (void)toBeDeterminedSelected
{
    if ([self.delegate respondsToSelector:@selector(didSelectToBeDetermined)]) {
        [self.delegate didSelectToBeDetermined];
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
    return !self.searchBar.text || !self.searchBar.text.length;
}

- (BOOL)shouldShowToBeDetermined
{
    return !self.searchBar.text || !self.searchBar.text.length;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSIndexPath *)indexPathForCurrentLocation
{
    NSInteger currentLocationIndex = -1;
    currentLocationIndex += [self shouldShowCurrentLocation];
    return [NSIndexPath indexPathForRow:currentLocationIndex inSection:0];
}

- (NSIndexPath *)indexPathForCustomLocation
{
    NSInteger customLocationIndex = -1;
    if ([self shouldShowCustomLocation]) {
        customLocationIndex = [self shouldShowCurrentLocation] + [self shouldShowToBeDetermined];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:customLocationIndex inSection:0];
    return indexPath;
}

- (NSIndexPath *)indexPathForToBeDetermined
{
    NSInteger toBeDeterminedIndex = -1;
    if ([self shouldShowToBeDetermined]) {
        toBeDeterminedIndex = [self shouldShowCurrentLocation];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:toBeDeterminedIndex inSection:0];
    return indexPath;
}

- (NSIndexPath *)indexPathForFirstVenue
{
    NSInteger venueIndexOffset = [self shouldShowCustomLocation] + [self shouldShowCurrentLocation] + [self shouldShowToBeDetermined];
    return [NSIndexPath indexPathForRow:venueIndexOffset inSection:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.venues.count + [self shouldShowCurrentLocation] + [self shouldShowCustomLocation] + [self shouldShowToBeDetermined];
}

#define TAG_NAME 1
#define TAG_ADDRESS 2
#define TAG_DISTANCE 3
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, self.tableView.frame.size.width - 20, 13)];
        nameLabel.font = [ThemeManager boldFontOfSize:12.0];
        nameLabel.tag = TAG_NAME;
        [cell addSubview:nameLabel];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0.5*(self.tableView.rowHeight - 13), self.tableView.frame.size.width - 20, 13)];
        addressLabel.font = [ThemeManager lightFontOfSize:12];
        addressLabel.tag = TAG_ADDRESS;
        [cell addSubview:addressLabel];
        
        UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.tableView.rowHeight - 13 - 13, self.tableView.frame.size.width - 20, 13)];
        distanceLabel.font = [ThemeManager lightFontOfSize:12];
        distanceLabel.tag = TAG_DISTANCE;
        [cell addSubview:distanceLabel];
    }
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:TAG_NAME];
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:TAG_ADDRESS];
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:TAG_DISTANCE];
    if ([indexPath isEqual:[self indexPathForCurrentLocation]]) {
        nameLabel.text = @"Current Location";
        nameLabel.textColor = [UIColor blueColor];
        if (self.currentLocationAddress) {
            addressLabel.text = self.currentLocationAddress;
        }
        distanceLabel.text = @"0 ft";
    }
    else if ([indexPath isEqual:[self indexPathForToBeDetermined]]) {
        nameLabel.text = @"To Be Decided";
        nameLabel.textColor = [[ThemeManager sharedTheme] redColor];
        distanceLabel.text = nil;
        addressLabel.text = @"(You can update this later)";
    }
    else if ([indexPath isEqual:[self indexPathForCustomLocation]]) {
        nameLabel.text = self.customLocation;
        nameLabel.textColor = [[ThemeManager sharedTheme] redColor];
        distanceLabel.text = @"";
        addressLabel.text = @"";
    }
    else {
        NSIndexPath *firstVenueIndexPath = [self indexPathForFirstVenue];
        Venue *venue = self.venues[indexPath.row - firstVenueIndexPath.row];
        nameLabel.text = venue.name;
        nameLabel.textColor = [UIColor blackColor];
        addressLabel.text = venue.address;
        distanceLabel.text = [self.locationFormatter stringFromDistance:venue.distance];
    }
    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.customLocation = searchText;
    [self searchForVenues];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchForVenues];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardShown = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardShown = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
    self.tableView.contentInset = UIEdgeInsetsZero;
}
@end
