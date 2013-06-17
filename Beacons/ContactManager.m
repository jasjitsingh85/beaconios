//
//  ContactManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ContactManager.h"
#import "Contact.h"
#import "Utilities.h"
#import "APIClient.h"

@interface ContactManager()

@property (strong, nonatomic) NSDictionary *contactDictionary;

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

- (void)fetchContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure
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
                    success(contacts);
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
    [self fetchContacts:^(NSArray *contacts) {
        NSMutableArray *contactParameter = [NSMutableArray new];
        for (Contact *contact in contacts) {
            NSString *contactString = [NSString stringWithFormat:@"{\"name\":\"%@\", \"phone\":\"%@\"}", contact.fullName, contact.phoneNumber];
            [contactParameter addObject:contactString];
        }
        NSDictionary *parameters = @{@"contact" : contactParameter};
        [[APIClient sharedClient] postPath:@"friends/" parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   }];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"sync fail" message:@"fetch fail" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }];
}

@end
