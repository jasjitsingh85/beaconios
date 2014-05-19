//
//  SetBeaconViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/28/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Beacon, SetBeaconViewController;

@protocol SetBeaconViewControllerDelegate <NSObject>
@optional
- (void)setBeaconViewController:(SetBeaconViewController *)setBeaconViewController didCancelBeacon:(Beacon *)beacon;
- (void)setBeaconViewController:(SetBeaconViewController *)setBeaconViewController didUpdateBeacon:(Beacon *)beacon;
- (void)setBeaconViewController:(SetBeaconViewController *)setBeaconViewController didCreateBeacon:(Beacon *)beacon;

@end

@interface SetBeaconViewController : UIViewController

@property (weak, nonatomic) id<SetBeaconViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL editMode;
@property (strong, nonatomic) Beacon *beacon;

- (void)preloadWithRecommendation:(NSNumber *)recommendationID;
- (void)preloadWithDescription:(NSString *)description venueName:(NSString *)venueName coordinate:(CLLocationCoordinate2D)coordinate;
- (void)updateDescriptionPlaceholder;

@end
