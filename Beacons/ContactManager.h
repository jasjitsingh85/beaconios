//
//  ContactManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "APIClient.h"

@class Group;
@interface ContactManager : NSObject

@property (strong, nonatomic) AFHTTPRequestOperation *updateFriendsOperation;
@property (strong, nonatomic) NSArray *recommendedContacts;
@property (strong, nonatomic) NSArray *recentContacts;
@property (readonly) ABAuthorizationStatus authorizationStatus;

+ (ContactManager *)sharedManager;
- (void)requestContactPermissions:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)fetchAddressBookContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure;
- (void)getGroups:(void (^)(NSArray *groups))success failure:(void (^)(NSError *error))failure;
- (void)postGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)deleteGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)addContacts:(NSArray *)contacts toGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)removeContacts:(NSArray *)contacts fromGroup:(Group *)group success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)syncContacts;

@end
