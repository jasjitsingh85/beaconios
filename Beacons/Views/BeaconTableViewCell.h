//
//  BeaconTableViewCell.h
//  Beacons
//
//  Created by Jeffrey Ames on 2/25/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon;
@interface BeaconTableViewCell : UITableViewCell

@property (strong, nonatomic) UIView *thumbnailContainerView;
@property (strong, nonatomic) UIImageView *thumbnailImageView;
@property (strong, nonatomic) UILabel *firstLine;
@property (strong, nonatomic) UILabel *secondLine;
//@property (strong, nonatomic) UILabel *distanceLabel;
//@property (strong, nonatomic) UILabel *inviteLabel;

@property (strong, nonatomic) Beacon *beacon;

@end
