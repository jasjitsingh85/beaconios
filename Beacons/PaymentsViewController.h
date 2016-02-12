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
#import "SponsoredEvent.h"
#import "EventStatus.h"

@class RedemptionViewController;

@protocol RegistrationViewControllerDelegate <NSObject>

- (void)finishPermissions;

@end

@interface PaymentsViewController: UIViewController <BTDropInViewControllerDelegate> {
    RedemptionViewController *_RedemptionViewController;
}

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) NSNumber *beaconID;
@property (nonatomic, strong) RedemptionViewController *redemptionViewController;
@property (nonatomic, assign) BOOL onlyAddPayment;
@property (nonatomic, assign) BOOL inRegFlow;
@property (assign) id <RegistrationViewControllerDelegate> delegate;

- (id) initWithClientToken: (NSString *)clientToken ;
- (void) openPaymentModalWithDeal: (Deal *)deal;
- (void) openPaymentModalToAddPayment;
- (void) openPaymentModalForOpenTab;
- (void) openPaymentModalWithEvent:(EventStatus *)eventStatus;

@end
