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

@interface FindFriendsViewController ()

@property (strong, nonatomic) NSArray *contactList;
@property (strong, nonatomic) NSMutableDictionary *selectedContacts;

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
    self.contactList = @[];
    self.selectedContacts = [NSMutableDictionary new];
    [self fetchContacts:^(NSArray *contacts) {
        self.contactList = contacts;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
        self.contactList = [self.contactList sortedArrayUsingDescriptors:@[sortDescriptor]];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        
        NSString* phone;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                         kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            phone = (__bridge_transfer NSString*)
            ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        } else {
        }
        CFRelease(phoneNumbers);
        contact.phone = phone;
        if (contact.phone) {
            [contacts addObject:contact];
        }
    }
    contacts = [NSArray arrayWithArray:contacts];
    completion(contacts);
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Friends From Contacts";
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactList.count;
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
    Contact *contact = self.contactList[indexPath.row];
    nameLabel.text = contact.fullName;
    
    UIImageView *addFriendImageView = (UIImageView *)[cell.contentView viewWithTag:TAG_CHECK_IMAGE];
    BOOL contactSelected = [self.selectedContacts.allKeys containsObject:contact.phone];
    addFriendImageView.image = contactSelected ? [UIImage imageNamed:@"addFriendSelected"] : [UIImage imageNamed:@"addFriendNormal"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = self.contactList[indexPath.row];
    BOOL contactSelected = [self.selectedContacts.allKeys containsObject:contact.phone];
    if (contactSelected) {
        [self.selectedContacts removeObjectForKey:contact.phone];
    }
    else {
        [self.selectedContacts setObject:contact forKey:contact.phone];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - buttons
- (void)doneButtonTouched:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
