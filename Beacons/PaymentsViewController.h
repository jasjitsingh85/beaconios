//
//  Header.h
//  Beacons
//
//  Created by Jasjit Singh on 4/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Braintree/Braintree.h>
#import "Deal.h"
#import "Venue.h"

@class BeaconProfileViewController;

@interface PaymentsViewController: UIViewController <BTDropInViewControllerDelegate> {
    BeaconProfileViewController *_beaconProfileViewController;
}

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) NSNumber *beaconID;
@property (nonatomic, strong) BeaconProfileViewController *beaconProfileViewController;
@property (nonatomic, assign) BOOL onlyAddPayment;

- (id) initWithClientToken: (NSString *)clientToken ;
- (void) openPaymentModalWithDeal: (Deal *)deal;
- (void) openPaymentModalToAddPayment;

@end
