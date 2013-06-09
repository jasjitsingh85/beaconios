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

- (void)beaconCellTextButtonTouched:(BeaconCell *)beaconCell;
- (void)beaconCellConfirmButtonTouched:(BeaconCell *)beaconCell;

@end
@interface BeaconCell : UICollectionViewCell

@property (weak, nonatomic) Beacon *beacon;
@property (weak, nonatomic) id<BeaconCellDelegate> delegate;

@end
