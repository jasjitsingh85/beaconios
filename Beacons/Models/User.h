//
//  User.h
//  Beacons
//
//  Created by Jeff Ames on 6/2/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *phoneNumber;

/*you can not set the normalized number directly.
 It is computed when the phone number property is set*/
@property (strong, nonatomic, readonly) NSString *normalizedPhoneNumber;

- (id)initWithData:(NSDictionary *)userData;
- (id)initWithSignInData:(NSDictionary *)userData;

@end
