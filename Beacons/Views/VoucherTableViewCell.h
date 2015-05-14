//
//  VoucherTableViewCell.h
//  Beacons
//
//  Created by Jasjit Singh on 5/14/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

@class Voucher;
@interface VoucherTableViewCell : UITableViewCell

@property (strong, nonatomic) UIView *thumbnailContainerView;
@property (strong, nonatomic) UIImageView *thumbnailImageView;
@property (strong, nonatomic) UILabel *firstLine;
@property (strong, nonatomic) UILabel *secondLine;
//@property (strong, nonatomic) UILabel *distanceLabel;
//@property (strong, nonatomic) UILabel *inviteLabel;

@property (strong, nonatomic) Voucher *voucher;

@end
