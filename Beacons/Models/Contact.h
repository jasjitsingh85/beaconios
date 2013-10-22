//
//  Contact.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface Contact : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *phoneNumber;
@property (assign, nonatomic) BOOL isUser;
@property (assign, nonatomic) BOOL isSuggested;
@property (assign, nonatomic) BOOL isRecent;
@property (strong, nonatomic) NSNumber *contactID;

/*you can not set the normalized number directly.
 It is computed when the phone number property is set*/
@property (strong, nonatomic, readonly) NSString *normalizedPhoneNumber;

- (id)initWithData:(NSDictionary *)data;
- (id)initWithUser:(User *)user;

@end
