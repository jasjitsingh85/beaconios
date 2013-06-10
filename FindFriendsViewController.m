//
//  FindFriendsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "Contact.h"
#import "Theme.h"
#import "APIClient.h"
#import "User.h"

typedef enum {
    FindFriendSectionUsers=0,
    FindFriendSectionContacts,
} FindFriendSection;

@interface FindFriendsViewController ()

@property (strong, nonatomic) NSArray *contactList;
@property (strong, nonatomic) NSArray *userList;
@property (strong, nonatomic) NSMutableDictionary *selectedContacts;
@property (strong, nonatomic) NSMutableDictionary *selectedUsers;

@end

@implementation FindFriendsViewController

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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    
    self.contactList = @[];
    self.userList = @[];
    self.selectedContacts = [NSMutableDictionary new];
    self.selectedUsers = [NSMutableDictionary new];
    [self fetchContacts:^(NSArray *contacts) {
        self.contactList = contacts;
        [self.tableView reloadData];
        [self requestFriendsOnBeacons];
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
    [self requestNonUserFollowers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Add Followers";
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
}

- (void)fetchContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure {
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    failure((__bridge NSError *)error);
                } else {
                    readAddressBookContacts(addressBook, success);
                }
            });
        });
    }
}

static void readAddressBookContacts(ABAddressBookRef addressBook, void (^completion)(NSArray *contacts)) {
    // do stuff with addressBook
    NSMutableArray *contacts = [NSMutableArray new];
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0;i<ABAddressBookGetPersonCount(addressBook);i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                             kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                            kABPersonLastNameProperty);
        
        Contact *contact = [Contact new];
        contact.firstName = firstName;
        contact.lastName = lastName;
        //store a full name for sorting in alphabetical order. If first or last name nil then use empty string
        NSString *fullName = @"";
        if (contact.firstName && contact.lastName) {
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        else if (contact.firstName) {
            fullName = contact.firstName;
        }
        else if (contact.lastName) {
            fullName = contact.lastName;
        }
        contact.fullName = fullName;
        //start fullName with a capital letter for sorting
        contact.fullName = contact.fullName.capitalizedString;
        
        NSString* phone;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                         kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            phone = (__bridge_transfer NSString*)
            ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        } else {
        }
        CFRelease(phoneNumbers);
        contact.phoneNumber = phone;
        if (contact.phoneNumber && ![contact.fullName isEqualToString:@""]) {
            [contacts addObject:contact];
        }
    }
    //sort in alphabetical order.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    NSArray *sortedContacts = [contacts sortedArrayUsingDescriptors:@[sortDescriptor]];
    completion(sortedContacts);
}

- (NSArray *)contactsWhoAreNotUsers
{
    NSMutableArray *userNumbers = [NSMutableArray new];
    for (User *user in self.userList) {
        [userNumbers addObject:user.normalizedPhoneNumber];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (normalizedPhoneNumber in %@)", userNumbers];
    NSArray *contactsNotUsers = [self.contactList filteredArrayUsingPredicate:predicate];
    return contactsNotUsers;
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == FindFriendSectionUsers) {
        title = @"Users";
    }
    else if (section == FindFriendSectionContacts) {
        title = @"Contacts";
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == FindFriendSectionUsers) {
        numRows = self.userList.count;
    }
    else if (section == FindFriendSectionContacts) {
        numRows = self.contactList.count;
    }
    return numRows;
}

#define TAG_NAME_LABEL 1
#define TAG_CHECK_IMAGE 2
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(160, 15);
        frame.origin.x = 58;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        nameLabel.frame = frame;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [ThemeManager boldFontOfSize:14];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.tag = TAG_NAME_LABEL;
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *addFriendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFriendNormal"]];
        frame = addFriendImageView.frame;
        frame.origin.x = 8;
        frame.origin.y = 0.5*(cell.contentView.frame.size.height - frame.size.height);
        addFriendImageView.frame = frame;
        addFriendImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        addFriendImageView.tag = TAG_CHECK_IMAGE;
        [cell.contentView addSubview:addFriendImageView];
    }
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:TAG_NAME_LABEL];
    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
    if (indexPath.section == FindFriendSectionUsers) {
        User *user = self.userList[indexPath.row];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    }
    else if (indexPath.section == FindFriendSectionContacts) {
        Contact *contact = self.contactList[indexPath.row];
        nameLabel.text = contact.fullName;
        
        BOOL contactSelected = [self.selectedContacts.allKeys containsObject:contact.normalizedPhoneNumber];
        addFriendImageView.image = contactSelected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = self.contactList[indexPath.row];
    BOOL contactSelected = [self.selectedContacts.allKeys containsObject:contact.normalizedPhoneNumber];
    if (contactSelected) {
        [self.selectedContacts removeObjectForKey:contact.normalizedPhoneNumber];
    }
    else {
        [self.selectedContacts setObject:contact forKey:contact.normalizedPhoneNumber];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - buttons
- (void)doneButtonTouched:(id)sender
{
    [self sendFollowersToServer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Networking
- (void)requestFriendsOnBeacons
{
    NSMutableArray *phoneNumbers = [NSMutableArray new];
    for (Contact *contact in self.contactList) {
        [phoneNumbers addObject:contact.phoneNumber];
    }
    NSDictionary *parameters = @{@"phone_number" : phoneNumbers};
    [[APIClient sharedClient] postPath:@"friends/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   //create users
                                   NSMutableArray *userList = [NSMutableArray new];
                                   for (NSDictionary *userData in responseObject) {
                                       User *user = [[User alloc] initWithData:userData];
                                       [userList addObject:user];
                                   }
                                    self.userList = [NSArray arrayWithArray:userList];
                                   //remove duplicates in contact list
                                   self.contactList = [self contactsWhoAreNotUsers];
                                   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   
                               }];
}

- (void)requestUserFollowers
{
    NSDictionary *parameters = @{@"type" : @"users"};
    [[APIClient sharedClient] getPath:@"friends/broadcast/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)requestNonUserFollowers
{
    NSDictionary *parameters = @{@"type" : @"contacts"};
    [[APIClient sharedClient] getPath:@"friends/broadcast/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)sendFollowersToServer
{
    if (!self.selectedContacts.count) {
        return;
    }
    NSMutableArray *nonUserFollows = [NSMutableArray new];
    for (Contact *contact in self.selectedContacts.allValues) {
        NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
        [nonUserFollows addObject:contactString];
    }
    NSDictionary *parameters = @{@"userid" : @[],
                                 @"contact" : nonUserFollows};
    [[APIClient sharedClient] postPath:@"friends/broadcast/" parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   
                               }];
}

@end
