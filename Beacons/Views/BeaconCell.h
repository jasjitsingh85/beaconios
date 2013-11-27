//
//  BeaconCell.h
//  Beacons
//
//  Created by Jeff Ames on 6/1/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon, BeaconCell;

@protocol BeaconCellDelegate <NSObject>
@optional
- (void)beaconCellTextButtonTouched:(BeaconCell *)beaconCell;
- (void)beaconCellDirectionsButtonTouched:(BeaconCell *)beaconCell;
- (void)beaconCellInfoButtonTouched:(BeaconCell *)beaconCell;
- (void)beaconCellConfirmButtonTouched:(BeaconCell *)beaconCell confirmed:(BOOL)confirmed;
- (void)beaconCellInviteMoreButtonTouched:(BeaconCell *)beaconCell;
- (void)beaconCellCreateBeaconButtonTouched:(BeaconCell *)beaconCell;

@end
@interface BeaconCell : UICollectionViewCell

@property (weak, nonatomic) Beacon *beacon;
@property (weak, nonatomic) id<BeaconCellDelegate> delegate;
@property (strong, nonatomic) UIColor *primaryColor;
@property (strong, nonatomic) UIColor *secondaryColor;

- (void)configureForBeacon:(Beacon *)beacon atIndexPath:(NSIndexPath *)indexPath;
@end
