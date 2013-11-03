//
//  ContactManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ContactManager : NSObject

@property (strong, nonatomic) NSArray *recommendedContacts;
@property (strong, nonatomic) NSArray *recentContacts;

+ (ContactManager *)sharedManager;
- (void)fetchAddressBookContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure;
- (void)syncContacts;

@end
