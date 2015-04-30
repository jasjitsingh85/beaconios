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

@interface PaymentsViewController: UIViewController <BTDropInViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) NSNumber *beaconID;

- (id) initWithClientToken: (NSString *)clientToken ;
- (void) openPaymentModalWithDeal: (Deal *)deal;

@end
