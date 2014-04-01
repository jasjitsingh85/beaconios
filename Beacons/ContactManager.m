//
//  ContactManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ContactManager.h"
#import "Contact.h"
#import "Group.h"
#import "Utilities.h"

@interface ContactManager()

@property (strong, nonatomic) NSDictionary *contactDictionary;
@property (strong, nonatomic) NSArray *groups;

@end

@implementation ContactManager

+ (ContactManager *)sharedManager
{
    static ContactManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [ContactManager new];
        
    });
    return _sharedManager;
}

- (ABAuthorizationStatus)authorizationStatus
{
    return ABAddressBookGetAuthorizationStatus();
}

- (void)requestContactPermissions:(void (^)())success failure:(void (^)(NSError *error))failure
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                if (success) {
                    success();
                }
            } else {
                if (failure) {
                    failure(nil);
                }
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        if (success) {
            success();
        }
    }
    else {
        if (failure) {
            failure(nil);
        }
    }
}

- (void)fetchAddressBookContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure
{
    if (self.contactDictionary.allValues) {
        success(self.contactDictionary.allValues);
        return;
    }
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    failure((__bridge NSError *)error);
                } else {
                    NSArray *contacts = [self addressBookContacts:addressBook];
                    NSMutableDictionary *contactDictionary = [NSMutableDictionary new];
                    for (Contact *contact in contacts) {
                        [contactDictionary setObject:contact forKey:contact.normalizedPhoneNumber];
                    }
                    self.contactDictionary = [[NSDictionary alloc] initWithDictionary:contactDictionary];
                    success(self.contactDictionary.allValues);
                }
            });
        });
    }
}

- (NSArray *)addressBookContacts:(ABAddressBookRef)addressBook
{
    NSMutableArray *contacts = [NSMutableArray new];
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int numPeople = ABAddressBookGetPersonCount(addressBook);
    for(int i = 0;i<numPeople;i++)
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
        }
        CFRelease(phoneNumbers);
        
        //only store contacts with a phone number and a name. Also don't store the user
        NSString *usersNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyPhone];
        NSString *normalizedUserNumber = [Utilities normalizePhoneNumber:usersNumber];
        contact.phoneNumber = phone;
        if (contact.phoneNumber && ![contact.fullName isEqualToString:@""] && ![contact.normalizedPhoneNumber isEqualToString:normalizedUserNumber]) {
            [contacts addObject:contact];
        }
    }
    return contacts;
}

- (void)syncContacts
{
    [self fetchAddressBookContacts:^(NSArray *contacts) {
        NSMutableArray *contactParameter = [NSMutableArray new];
        for (Contact *contact in contacts) {
            [contactParameter addObject:contact.serializedString];
        }
        NSDictionary *parameters = @{@"contact" : contactParameter};
        [[APIClient sharedClient] postPath:@"friends/" parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [self updateFriendsFromServer:nil failure:nil];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   }];
    } failure:^(NSError *error) {
    }];
}

- (void)updateName:(NSString *)name ofGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"group_id" : group.groupID, @"name" : name};
    [[APIClient sharedClient] putPath:@"contact_group/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [group updateWithData:responseObject[@"group"]];
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"group_id": group.groupID};
    [[APIClient sharedClient] deletePath:@"contact_group/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *groups = [NSMutableArray arrayWithArray:self.groups];
        NSArray *filtered = [self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"groupID = %@", group.groupID]];
        for (Group *removedGroup in filtered) {
            [groups removeObject:removedGroup];
        }
        self.groups = [NSArray arrayWithArray:groups];
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)addContacts:(NSArray *)contacts toGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [self addContacts:contacts removeContacts:@[] group:group success:success failure:failure];
}

- (void)removeContacts:(NSArray *)contacts fromGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [self addContacts:@[] removeContacts:contacts group:group success:success failure:failure];
}

- (void)addContacts:(NSArray *)contactsToAdd removeContacts:(NSArray *)contactsToRemove group:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    NSArray *add = [contactsToAdd valueForKey:@"serializedString"];
    NSArray *remove = [contactsToRemove valueForKey:@"serializedString"];
    NSDictionary *parameters = @{@"group_id": group.groupID,
                                 @"add": add,
                                 @"remove": remove};
    [[APIClient sharedClient] putPath:@"contact_group/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [group updateWithData:responseObject[@"group"]];
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (group.contacts) {
        NSMutableArray *contactParameter = [[NSMutableArray alloc] init];
        for (Contact *contact in group.contacts) {
            [contactParameter addObject:contact.serializedString];
        }
        parameters[@"contact"] = contactParameter;
    }
    parameters[@"name"] = group.name;
    [[APIClient sharedClient] postPath:@"contact_group/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [group updateWithData:responseObject[@"group"]];
        NSMutableArray *groups = [NSMutableArray arrayWithArray:self.groups];
        [groups insertObject:group atIndex:0];
        self.groups = [NSArray arrayWithArray:groups];
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getGroups:(void (^)(NSArray *groups))success failure:(void (^)(NSError *error))failure
{
    if (self.groups) {
        if (success) {
            success(self.groups);
        }
        return;
    }
    [[APIClient sharedClient] getPath:@"contact_group/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *groupsData = responseObject[@"groups"];
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        for (NSDictionary *groupData in groupsData) {
            Group *group = [[Group alloc] initWithData:groupData];
            [groups addObject:group];
        }
        self.groups = [NSArray arrayWithArray:groups];
        if (success) {
            success(self.groups);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)updateFriendsFromServer:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [[APIClient sharedClient] requestWithMethod:@"GET" path:@"friends/" parameters:nil];
    self.updateFriendsOperation = [[APIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *recommendedContacts = [[NSMutableArray alloc] init];
        NSMutableArray *recentContacts = [[NSMutableArray alloc] init];
        NSArray *contactsData = responseObject[@"contacts"];
        NSArray *usersData = responseObject[@"users"];
        NSArray *recentUsersData = responseObject[@"profile_recents"];
        NSArray *recentContactsData = responseObject[@"contacts_recents"];
        for (NSDictionary *contactData in contactsData) {
            NSString *phoneNumber = contactData[@"phone_number"];
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
            Contact *contact = self.contactDictionary[normalizedPhoneNumber];
            if (contact) {
                contact.isSuggested = YES;
                [recommendedContacts addObject:contact];
            }
        }
        for (NSDictionary *contactData in recentContactsData) {
            NSString *phoneNumber = contactData[@"phone_number"];
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
            Contact *contact = self.contactDictionary[normalizedPhoneNumber];
            if (contact) {
                contact.isSuggested = YES;
                contact.isRecent = YES;
                [recentContacts addObject:contact];
            }
        }
        for (NSDictionary *userData in usersData) {
            NSString *phoneNumber = userData[@"phone_number"];
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
            Contact *contact = self.contactDictionary[normalizedPhoneNumber];
            if (contact) {
                contact.isSuggested = YES;
                contact.isUser = YES;
                [recommendedContacts addObject:contact];
            }
        }
        for (NSDictionary *userData in recentUsersData) {
            NSString *phoneNumber = userData[@"phone_number"];
            NSString *normalizedPhoneNumber = [Utilities normalizePhoneNumber:phoneNumber];
            Contact *contact = self.contactDictionary[normalizedPhoneNumber];
            if (contact) {
                contact.isSuggested = YES;
                contact.isUser = YES;
                contact.isRecent = YES;
                [recentContacts addObject:contact];
            }
        }
        self.recentContacts = recentContacts;
        self.recommendedContacts = recommendedContacts;
    } failure:nil];
    [[APIClient sharedClient] enqueueHTTPRequestOperation:self.updateFriendsOperation];

}

@end
