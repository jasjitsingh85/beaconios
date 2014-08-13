//
//  DealTableViewCell.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"

@interface DealTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UILabel *venueLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIView *descriptionBackground;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIView *venueDescriptionBackground;
@property (strong, nonatomic) UILabel *venueDescriptionLabel;

@property (strong, nonatomic) Deal *deal;

@end
