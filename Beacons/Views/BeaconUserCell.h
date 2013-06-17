//
//  BeaconConfirmedCell.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon,
User,
Contact;
@interface BeaconUserCell : UITableViewCell

@property (weak, nonatomic) Beacon *beacon;
@property (weak, nonatomic) User *user;
@property (weak, nonatomic) Contact *contact;
@property (assign, nonatomic) BOOL isAttending;

@end
